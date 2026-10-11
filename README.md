# pg_stat_monitor — Windows x64 binaries (pgextwin)

[日本語](README_ja.md) | English

This repository publishes unofficial Windows x64 binaries of [Percona pg_stat_monitor](https://github.com/percona/pg_stat_monitor) **2.4.0**, pinned to upstream commit `2de2db763db9f590cd28159741c36b41f66eb985`.

**Current published release:** [v2.4.0-windows.1](https://github.com/pgextwin/pg_stat_monitor/releases/tag/v2.4.0-windows.1), for PostgreSQL **14–18**. Download the ZIP that matches your PostgreSQL major. SHA256 hashes, SPDX SBOMs, Grype reports and attestations are listed in the [pgextwin Catalog](https://pgextwin.github.io/website/en/). These community builds are not an upstream-official Windows distribution.

Using pg_stat_monitor **requires** `shared_preload_libraries = 'pg_stat_monitor'` followed by a PostgreSQL restart, along with `CREATE EXTENSION pg_stat_monitor`. The Windows CI verifies startup with preload, a real query being recorded in time buckets, extension version and query counters, and shutdown cleanup. Server-log assertions and extension upgrades are **not covered** by the current Test Contract. See [Windows installation and verification guidance](docs/windows.md).

PostgreSQL 14 remains eligible for new builds only through its community EOL **2026-11-12**, while existing published binaries remain historical downloads. Publication still requires validated artifacts; upstream updates alone do not automatically trigger a public Release.
