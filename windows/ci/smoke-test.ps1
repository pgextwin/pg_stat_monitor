[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PgRoot,[Parameter(Mandatory=$true)][int]$PgPort,[Parameter(Mandatory=$true)][int]$PostgreSqlMajor)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$name='pg_stat_monitor'
$bin=Join-Path $PgRoot 'bin'
$initdb=Join-Path $bin 'initdb.exe'
$pgctl=Join-Path $bin 'pg_ctl.exe'
$ready=Join-Path $bin 'pg_isready.exe'
$psql=Join-Path $bin 'psql.exe'
$tmp=if($env:RUNNER_TEMP){$env:RUNNER_TEMP}else{[IO.Path]::GetTempPath()}
$data=Join-Path $tmp "pgextwin-$name-pg$PostgreSqlMajor"
$log=Join-Path $tmp "pgextwin-$name-pg$PostgreSqlMajor.log"
$sql=Join-Path $tmp "pgextwin-$name-pg$PostgreSqlMajor.sql"
if(Test-Path $data){Remove-Item $data -Recurse -Force}
if(Test-Path $log){Remove-Item $log -Force}
try {
    & $initdb -D $data -U postgres -A trust --encoding=UTF8 --no-locale
    if($LASTEXITCODE -ne 0){throw 'initdb failed'}
    & $pgctl -D $data -l $log -o "-p $PgPort -c shared_preload_libraries=pg_stat_monitor" start
    if($LASTEXITCODE -ne 0){throw 'PostgreSQL start failed'}
    $ok=$false
    for($i=0;$i -lt 45;$i++){
        & $ready -h 127.0.0.1 -p $PgPort -q
        if($LASTEXITCODE -eq 0){$ok=$true;break}
        Start-Sleep -Seconds 2
    }
    if(-not $ok){throw 'pg_isready timeout'}
    @'
SET TIME ZONE 'UTC';
CREATE EXTENSION pg_stat_monitor;
SELECT pg_stat_monitor_version();
SELECT pg_stat_monitor_reset();
CREATE TABLE public.pgextwin_monitor_test(id integer PRIMARY KEY, amount integer);
INSERT INTO public.pgextwin_monitor_test VALUES(1,10),(2,20);
UPDATE public.pgextwin_monitor_test SET amount=30 WHERE id=2;
DELETE FROM public.pgextwin_monitor_test WHERE id=1;
SELECT count(*) AS pgextwin_marker FROM public.pgextwin_monitor_test WHERE amount>0;
SELECT pg_sleep(0.2);
DO $
DECLARE observed bigint; buckets integer;
BEGIN
  SELECT coalesce(sum(calls),0),count(DISTINCT bucket)
  INTO observed,buckets
  FROM pg_stat_monitor
  WHERE query LIKE '%pgextwin_monitor_test%';
  IF observed<1 OR buckets<1 THEN
    RAISE EXCEPTION 'Real statements missing from monitor: calls=%, buckets=%',observed,buckets;
  END IF;
END $;
DROP TABLE public.pgextwin_monitor_test;
DROP EXTENSION pg_stat_monitor;
'@ | Set-Content -Path $sql -Encoding utf8
    & $psql -h 127.0.0.1 -p $PgPort -U postgres -d postgres -v ON_ERROR_STOP=1 -f $sql
    if($LASTEXITCODE -ne 0){throw "$name SQL functional test failed"}
    Write-Host "PASS: $name functional smoke and cleanup"
} catch {
    if(Test-Path $log){Get-Content $log -Tail 300}
    throw
} finally {
    if(Test-Path (Join-Path $data 'postmaster.pid')){& $pgctl -D $data -m immediate stop}
}
