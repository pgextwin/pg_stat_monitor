[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PgRoot,[Parameter(Mandatory=$true)][string]$UpstreamDir)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$module='pg_stat_monitor'
$pgconfig=Join-Path $PgRoot 'bin/pg_config.exe'
$pgversion=(& $pgconfig --version).Trim()
if($LASTEXITCODE -ne 0 -or $pgversion -notmatch '^PostgreSQL\s+(14|15|16|17|18)\.') {throw "Unsupported pg_config: $pgversion"}
$vswhere=Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Microsoft Visual Studio/Installer/vswhere.exe'
if(-not(Test-Path $vswhere)){throw "Visual Studio locator unavailable: $vswhere"}
$vsroot=[string](& $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1)
if([string]::IsNullOrWhiteSpace($vsroot)){throw 'MSVC x64 toolchain unavailable'}
$devcmd=Join-Path $vsroot.Trim() 'Common7/Tools/VsDevCmd.bat'
if(-not(Test-Path $devcmd)){throw "VsDevCmd missing: $devcmd"}
$exports=@('Pg_magic_func','_PG_init')
$actualFunctionCount=0
foreach($file in Get-ChildItem $UpstreamDir -Recurse -Filter '*.c' -File){
    if($file.Name -eq 'sqlscan.c'){continue}
    $source=[IO.File]::ReadAllText($file.FullName,[Text.Encoding]::UTF8)
    foreach($match in [regex]::Matches($source,'PG_FUNCTION_INFO_V1\(\s*([A-Za-z_]\w*)\s*\)')){
        $name=$match.Groups[1].Value
        $exports+=@($name,"pg_finfo_$name")
        $actualFunctionCount++
    }
}
if($actualFunctionCount -lt 5){throw "Suspicious PG_FUNCTION_INFO_V1 export count: $actualFunctionCount"}
$exports=@($exports | Sort-Object -Unique)
$defpath=Join-Path $UpstreamDir "$module.pgextwin.def"
(@("LIBRARY $module","EXPORTS") + @($exports | ForEach-Object {"    $_"})) | Set-Content $defpath -Encoding ascii
# MSVC cannot preprocess a conditional directive embedded inside a
# function-like call's argument list (upstream hash_query.c, PG19-only path).
# We ship PG14–18 only; this disposable checkout substitutes the identical
# pre-PG19 branch. Refuse to patch if the immutable upstream source changes.
$hashPath=Join-Path $UpstreamDir 'src/hash_query.c'
$hashSource=[IO.File]::ReadAllText($hashPath,[Text.Encoding]::UTF8)
$hashPattern='(?s)dsa\s*=\s*dsa_create_in_place\(\s*pgsm->raw_dsa_area\s*,\s*pgsm_query_area_size\(\)\s*,\s*#if\s+PG_VERSION_NUM\s*>=\s*190000\s+LWLockNewTrancheId\("pg_stat_monitor_dsa"\)\s*,\s*0\);\s*#else\s+LWLockNewTrancheId\(\)\s*,\s*0\);\s*#endif'
$matchesFound=[regex]::Matches($hashSource,$hashPattern)
if($matchesFound.Count -ne 1){throw "Expected one guarded pre-PG19 dsa call, found $($matchesFound.Count)"}
$replacement='dsa = dsa_create_in_place(pgsm->raw_dsa_area, pgsm_query_area_size(), LWLockNewTrancheId(), 0);'
$hashSource=[regex]::Replace($hashSource,$hashPattern,$replacement)
[IO.File]::WriteAllText($hashPath,$hashSource,[Text.UTF8Encoding]::new($false))
Write-Host 'Rewrote only the PG14–18 DSA call in disposable source for MSVC.'
# The upstream Meson file is a PostgreSQL in-tree contrib fragment, not a
# standalone project. Use a generated temporary Meson project in this checkout.
# This is a reproducible, explicit MSVC adaptation (no vendored source fork).
$pgMajor=[int]([regex]::Match($pgversion,'^PostgreSQL\\s+(\\d+)\\.')).Groups[1].Value
if($pgMajor -le 15){
    $sourcePath=Join-Path $UpstreamDir 'src/pg_stat_monitor.c'
    $content=[IO.File]::ReadAllText($sourcePath,[Text.Encoding]::UTF8)
    $header='#include <sys/resource.h>'
    if(([regex]::Matches($content,[regex]::Escape($header)).Count) -ne 1){throw 'Unexpected upstream resource header'}
    $replacement="#if PG_VERSION_NUM < 160000"+[Environment]::NewLine+'#include "rusagestub.h"'+[Environment]::NewLine+'#else'+[Environment]::NewLine+$header+[Environment]::NewLine+'#endif'
    $content=$content.Replace($header,$replacement)
    [IO.File]::WriteAllText($sourcePath,$content,[Text.UTF8Encoding]::new($false))
}
$meson=@'
project('pg_stat_monitor', 'c', version: '2.4.0')
pg_config = find_program('pg_config', required: true)
pgincludedir = run_command(pg_config, '--includedir', check: true).stdout().strip()
pgserverdir = run_command(pg_config, '--includedir-server', check: true).stdout().strip()
pglibdir = run_command(pg_config, '--libdir', check: true).stdout().strip()
postgres_lib = meson.get_compiler('c').find_library('postgres', dirs: pglibdir, required: true)
shared_module('pg_stat_monitor',
  files('src/pg_stat_monitor.c','src/hash_query.c','src/guc.c'),
  include_directories: [pgserverdir / 'port/win32_msvc', pgserverdir / 'port/win32', pgserverdir, pgincludedir, 'src'],
  dependencies: postgres_lib,
  vs_module_defs: 'pg_stat_monitor.pgextwin.def',
  c_args: ['/DWIN32', '/Zc:preprocessor'],
  link_args: ['ws2_32.lib'],
  name_prefix: '',
  install: false
)
'@
[IO.File]::WriteAllText((Join-Path $UpstreamDir 'meson.build'),$meson,[Text.UTF8Encoding]::new($false))

$python=(Get-Command python.exe -ErrorAction Stop).Source
& $python -m pip install --disable-pip-version-check --quiet 'meson==1.8.3' 'ninja==1.11.1.4'
if($LASTEXITCODE -ne 0){throw 'Unable to install pinned build tools'}
$tmp=if($env:RUNNER_TEMP){$env:RUNNER_TEMP}else{[IO.Path]::GetTempPath()}
$builddir=Join-Path $tmp "$module-pgextwin-build"
if(Test-Path $builddir){Remove-Item $builddir -Recurse -Force}
$cmd=Join-Path $tmp "$module-pgextwin-build.cmd"
@"
@echo off
call "$devcmd" -arch=x64 -host_arch=x64
if errorlevel 1 exit /b %errorlevel%
set "PATH=$PgRoot\bin;%PATH%"
"$python" -m mesonbuild.mesonmain setup "$builddir" "$UpstreamDir" --backend ninja --buildtype=plain
if errorlevel 1 exit /b %errorlevel%
"$python" -m mesonbuild.mesonmain compile -C "$builddir"
if errorlevel 1 exit /b %errorlevel%
"@ | Set-Content $cmd -Encoding ascii
& cmd.exe /d /c $cmd
if($LASTEXITCODE -ne 0){throw "$module MSVC/Meson build failed: $LASTEXITCODE"}
$dll=Get-ChildItem $builddir -Recurse -Filter "$module.dll" -File | Select-Object -First 1
if($null -eq $dll){throw "$module.dll not generated"}
$out=Join-Path $UpstreamDir "$module.dll"
Copy-Item $dll.FullName $out -Force
$dumpcmd=Join-Path $tmp "$module-pgextwin-audit.cmd"
@"
@echo off
call "$devcmd" -arch=x64 -host_arch=x64 >nul
if errorlevel 1 exit /b %errorlevel%
dumpbin /nologo /exports "$out"
if errorlevel 1 exit /b %errorlevel%
dumpbin /nologo /dependents "$out"
"@ | Set-Content $dumpcmd -Encoding ascii
$dump=@(& cmd.exe /d /c $dumpcmd)
if($LASTEXITCODE -ne 0){throw 'dumpbin export/dependency audit failed'}
$dumptext=$dump -join [Environment]::NewLine
foreach($required in $exports){
    if($dumptext -notmatch "(?m)\b$([regex]::Escape($required))\b"){throw "DLL missing expected symbol $required"}
}
Write-Host "PASS: $module MSVC build + $($exports.Count) exports + dependencies"
