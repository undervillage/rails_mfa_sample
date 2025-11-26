# Rails MFA Sample

Ruby 4.0 / Rails 8.1 + Devise + TOTP (MFA) のサンプルです。Docker Compose を前提にした最小構成で、サインアップ後にQRコードでMFAを登録し、連続2コード検証で完了するフローを持ちます。

## 前提
- Ruby 4.0.0.preview2
- Bundler 2.7.2
- Docker / Docker Compose
- MySQL 8.x

## セットアップ手順
1. 依存を取得（必要なら Bundler をインストール）
   ```bash
   gem install bundler:2.7.2    # 初回のみ
   bundle _2.7.2_ install
   ```
   Docker で行う場合はビルド時に Bundler を入れる設定済みです（Dockerfile）。

2. DB の作成・マイグレーション
   ```bash
   bundle _2.7.2_ exec rails db:create db:migrate
   # サンプルユーザーが不要なら db:seed は省略可
   # bundle _2.7.2_ exec rails db:seed
   ```

3. サーバー起動
   - ローカル: `bundle _2.7.2_ exec rails s -b 0.0.0.0 -p 3404`
   - Docker Compose:
     ```bash
     docker compose up -d db
     docker compose up
     ```
     MySQL はコンテナ名 `db`、内部ポート 3306。外部公開は 3367 にマッピング。

## 使い方（MFA フロー）
1. サインアップページでメール・パスワードを登録。
2. 直後に表示される OTP セットアップ画面で QR を認証アプリに読み込み。
3. 生成されたワンタイムコードを「現在のコード」と「次の時間枠のコード」の2回入力して確認。
4. 成功すると自動ログインし、ダッシュボードへ遷移。
5. 次回以降のログインは、メール + パスワード + ワンタイムコード（現在のコード）を入力。

## 環境変数・設定
- `DATABASE_URL`：MySQL 接続先（Docker では `mysql2://root:password@db:3306/mfa_development?ssl_mode=DISABLED` を設定）。
- `OTP_ISSUER`：TOTP の issuer 名。未設定時は `MfaSample`。
- `RAILS_ENV`：必要に応じて `development` / `production` を指定。

## 補足
- サインアウトは DELETE メソッドのみ許可。リンクには `method: :delete`（または `data-turbo-method: :delete`）を使用してください。
- MFA 再登録やリカバリコードのフローは未実装です。運用要件に応じて追加してください。
