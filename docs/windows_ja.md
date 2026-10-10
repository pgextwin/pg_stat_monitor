# pg_stat_monitor Windows パイロット

**状態：技術検証中。全 PostgreSQL major の機能テスト・成果物検査が成功するまで公開禁止。**

上流：https://github.com/percona/pg_stat_monitor/tree/2de2db763db9f590cd28159741c36b41f66eb985

shared_preload_libraries に pg_stat_monitor を追加してサーバーを再起動する必要があります。共有メモリとクエリフックの実機テストが必須です。
PG14 は 2026-11-12 を超えて維持しません。ZIP の対応 major、SQL ファイル、ライセンス、SBOM・Grype・出自を確認してください。現時点では本番環境への導入を推奨しません。
