# pg_stat_monitor Windows 導入・検証ガイド

**状態：[v2.4.0-windows.1](https://github.com/pgextwin/pg_stat_monitor/releases/tag/v2.4.0-windows.1)をPG14〜18向けに公開済み。** 全majorのWindows CI・機能テスト・成果物検証を経て公開しました。

上流：https://github.com/percona/pg_stat_monitor/tree/2de2db763db9f590cd28159741c36b41f66eb985

shared_preload_libraries に pg_stat_monitor を追加してサーバーを再起動する必要があります。共有メモリとクエリフックの実機テストが必須です。
PG14 は 2026-11-12 を超えて維持しません。ZIP の対応 major、SQL ファイル、ライセンス、SBOM・Grype・出自を確認してください。実運用前に対象環境で共有メモリ・事前ロード・実クエリの記録と互換性を検証してください。
