# pg_stat_monitor — Windows x64 バイナリ

[English](README.md) | 日本語

[pg_stat_monitor](https://github.com/percona/pg_stat_monitor)の**非公式Windows x64バイナリ**です。時間帯ごとのクエリ統計を収集する拡張機能です。

## ダウンロードと対応環境

[最新の公開Release](https://github.com/pgextwin/pg_stat_monitor/releases/latest)から入手できます。[過去のReleases](https://github.com/pgextwin/pg_stat_monitor/releases)も確認できます。PostgreSQL **14〜18**向けの公開状況は[pgextwinカタログ](https://pgextwin.github.io/website/ja/)を参照してください。利用中のPostgreSQLメジャーバージョンに一致するZIPを選んでください。PostgreSQL 14のコミュニティサポートは2026年11月12日に終了します。

## インストール

1. PostgreSQL環境をバックアップし、[上流の導入要件](https://github.com/percona/pg_stat_monitor)を確認します。
2. 既存ファイルの置き換え前にPostgreSQLを停止します。該当するZIPのlib/とshare/extension/以下のファイルを、PostgreSQLの同名ディレクトリへコピーします。
3. 上流ドキュメントに従い、postgresql.confのshared_preload_librariesへpg_stat_monitorを追加してPostgreSQLを起動します。
4. 利用するデータベースでCREATE EXTENSION pg_stat_monitor;を実行します。

ReleaseのSHA256SUMS.txtでダウンロードしたファイルを照合してください。SPDX形式のSBOM、脆弱性レポート、署名付き証明の有無はReleaseで確認できます。本番導入前に検証環境で動作を確認してください。

## ライセンスと問い合わせ先

SQLの使い方、設定、権限、制限事項は[上流のpg_stat_monitor](https://github.com/percona/pg_stat_monitor)を参照してください。本バイナリは上流公式による配布ではありません。再配布条件は同梱のライセンスをご確認ください。
