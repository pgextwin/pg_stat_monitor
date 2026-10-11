# pg_stat_monitor — Windows x64 バイナリ（pgextwin）

[English](README.md) | 日本語

上流[Percona pg_stat_monitor](https://github.com/percona/pg_stat_monitor) **2.4.0**（固定コミット `2de2db763db9f590cd28159741c36b41f66eb985`）の非公式Windows x64向けコミュニティ製バイナリです。

**現在の公開Release：** [v2.4.0-windows.1](https://github.com/pgextwin/pg_stat_monitor/releases/tag/v2.4.0-windows.1)。PostgreSQL **14〜18**向けのZIPを配布しています。対応するPGメジャー専用ZIPを選び、[pgextwin Pages](https://pgextwin.github.io/website/ja/)でSHA256・SPDX SBOM・Grype・証明情報を確認してください。上流公式のWindows配布ではありません。

利用には`shared_preload_libraries = 'pg_stat_monitor'`の設定とPostgreSQLの再起動、および`CREATE EXTENSION pg_stat_monitor`が必要です。Windows CIでは事前ロードして起動し、実際のクエリが時間区間別統計に記録されること、拡張バージョンとクエリカウンター、終了時の後処理を検証しています。**サーバーログ検証とアップグレード経路は現行CIでは未検証**です。[Windows導入・検証ガイド](docs/windows_ja.md)も参照してください。

PostgreSQL 14の新規ビルドは公式EOLの**2026-11-12**まで対象とし、公開済み成果物は履歴として残します。上流更新だけを理由に無検証でReleaseを公開しません。
