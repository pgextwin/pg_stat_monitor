# Windows pilot — pg_stat_monitor

Status: **engineering only / release blocked until green full matrix**.

Upstream: https://github.com/percona/pg_stat_monitor/tree/2de2db763db9f590cd28159741c36b41f66eb985

The extension requires shared_preload_libraries='pg_stat_monitor' and a PostgreSQL restart; it uses hooks and shared memory. It must pass real query bucketing tests.

1. Validate full native Windows x64 CI for PG14 (if still maintained) through PG18.
2. Verify exact license bytes and immutable upstream SHA.
3. Validate `CREATE EXTENSION pg_stat_monitor` and scenarios in `config/test-contract.json`.
4. For deployment, stop the server before replacing libraries; install the ZIP contents into the matching PostgreSQL root and restart for preload modules.
5. Run the documented SQL tests and repeat on an isolated production-equivalent Windows environment.

Do not install a pilot ZIP into production and do not treat unexecuted tests as passes. Upgrades, rollback, interaction with other extensions and backup/restore require separate testing.

All published binary artifacts must carry source provenance, exact PostgreSQL major, checksums, SBOM and vulnerability report.
