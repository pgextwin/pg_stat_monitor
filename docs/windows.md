# Windows installation and verification — pg_stat_monitor

Status: **v2.4.0-windows.1 published for PostgreSQL 14–18** after the required Windows CI and Release verification. [Published release](https://github.com/pgextwin/pg_stat_monitor/releases/tag/v2.4.0-windows.1).

Upstream: https://github.com/percona/pg_stat_monitor/tree/2de2db763db9f590cd28159741c36b41f66eb985

The extension requires shared_preload_libraries='pg_stat_monitor' and a PostgreSQL restart; it uses hooks and shared memory. It must pass real query bucketing tests.

1. Validate full native Windows x64 CI for PG14 (if still maintained) through PG18.
2. Verify exact license bytes and immutable upstream SHA.
3. Validate `CREATE EXTENSION pg_stat_monitor` and scenarios in `config/test-contract.json`.
4. For deployment, stop the server before replacing libraries; install the ZIP contents into the matching PostgreSQL root and restart for preload modules.
5. Run the documented SQL tests and repeat on an isolated production-equivalent Windows environment.

Do not interpret CI coverage as a production compatibility guarantee; verify shared preload and actual query bucketing on a production-equivalent environment before deployment. Upgrades, rollback, interaction with other extensions and backup/restore require separate testing.

All published binary artifacts must carry source provenance, exact PostgreSQL major, checksums, SBOM and vulnerability report.
