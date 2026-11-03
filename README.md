# pg_stat_monitor — Windows x64

[日本語](README_ja.md) | English

This repository provides **unofficial Windows x64 binaries** for [pg_stat_monitor](https://github.com/percona/pg_stat_monitor). Time-bucketed PostgreSQL query statistics.

## Download and compatibility

Get the [latest published Release](https://github.com/pgextwin/pg_stat_monitor/releases/latest) or [browse all Releases](https://github.com/pgextwin/pg_stat_monitor/releases). Published packages for PostgreSQL **14–18** are listed in the [pgextwin catalog](https://pgextwin.github.io/website/en/). Download the ZIP matching your PostgreSQL major version. PostgreSQL 14 community support ends November 12, 2026; historical downloads may remain available.

## Installation

1. Back up your PostgreSQL environment and check [upstream installation requirements](https://github.com/percona/pg_stat_monitor).
2. Stop PostgreSQL before replacing files. Extract the ZIP for your PostgreSQL major and copy the packaged lib/ and share/extension/ files into the matching PostgreSQL installation directories.
3. Add pg_stat_monitor to shared_preload_libraries in postgresql.conf, following the upstream documentation. Start or restart PostgreSQL.
4. Run CREATE EXTENSION pg_stat_monitor; in the database where the extension is needed.

Verify downloaded files using SHA256SUMS.txt from the Release. Review the Release for SPDX SBOMs, vulnerability reports and signed attestations. Test in a non-production environment before deployment.

## License and support

Consult [upstream pg_stat_monitor](https://github.com/percona/pg_stat_monitor) for SQL usage, settings, permissions, and limitations. pgextwin is an independent community package and is not an official upstream distribution. Refer to the included license.
