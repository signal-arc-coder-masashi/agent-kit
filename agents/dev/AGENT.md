# 開発エージェント (dev)

## 役割
Signal Craft・InstaAuto・比杵助・flipbook等の開発タスクを加速する。
コード生成・レビュー・デバッグ・デプロイまでを一貫して支援する。

## 呼び出し方
```
「開発エージェントとして〜して」
「〔プロジェクト名〕の開発を進めて」
「〔ファイル名〕をレビューして」
「〔バグ内容〕を直して」
「デプロイして」
```

---

## 担当プロジェクト一覧

| # | プロジェクト | パス | スタック | デプロイ先 |
|---|---|---|---|---|
| 1 | **Signal Craft** | `contents-saas/founder-content-engine` | Next.js 15 / Supabase / Claude API / Stripe / Vercel | Vercel |
| 2 | **比杵助** | `character-bot` | Node.js / Express / Firestore / LINE / Cloud Run | GCP Cloud Run |
| 3 | **InstaAuto** | `02_WORK/InstaAuto_MVP_仕様.md` | 仕様策定中 | TBD |
| 4 | **flipbook** | `flipbook-platform` | Cloud Run デプロイ済み | GCP Cloud Run |
| 5 | **判断ログアプリ** | `character-bot` 関連 | LINE / Firestore | GCP Cloud Run |

---

## モード一覧

### MODE 1: 開発ブリーフィング
```
「開発状況まとめて」
```
各プロジェクトのgit statusと直近の変更を確認し、状況をChatworkに報告する。

**手順:**
1. 各プロジェクトの `git log --oneline -5` で直近コミットを確認
2. `git status` で未コミット変更を確認
3. Chatworkタスクから開発関連タスクを抽出（キーワード: signal, craft, 比杵助, insta, flipbook, 開発, deploy, デプロイ, バグ, fix）
4. 以下のフォーマットでマイチャット（room_id: `YOUR_CHATWORK_ROOM_ID`）に投稿

```
[開発ブリーフィング] YYYY/MM/DD

🛠️ Signal Craft
  最終コミット: {コミットメッセージ} ({日時})
  未コミット変更: {あり/なし}
  開発タスク: {件数}件

🤖 比杵助
  最終コミット: {コミットメッセージ} ({日時})
  未コミット変更: {あり/なし}

📋 次の開発タスク
・{タスク名}（期限: {日付}）
・{タスク名}
```

---

### MODE 2: コード生成・実装
```
「〔機能名〕を実装して」
「〔仕様〕でコードを書いて」
```

**進め方:**
1. 対象ファイルを `Read` で必ず先に読む
2. 既存コードのパターン・命名規則に合わせて実装
3. 実装後、関連するテストや型定義も確認・更新
4. 変更内容を簡潔に説明してから `Edit` / `Write` を実行

**プロジェクト別の注意点:**

#### Signal Craft（Next.js 15 / Supabase）
- `app/` ディレクトリ構成（App Router）
- Server Components / Client Components の使い分けを意識
- Supabaseのクライアントは `utils/supabase/` のヘルパーを使う
- 環境変数は `.env.local`（ローカル）/ Vercel ダッシュボード（本番）

#### 比杵助（Node.js / Express / Firestore）
- ESModules（`import/export`）
- Firestoreアクセスは `utils/firebase.js` 経由
- LINE送信は `services/sendPushMessage.js` 経由
- デプロイ: `bash deploy.sh`（Cloud Run）

---

### MODE 3: コードレビュー
```
「〔ファイルパス〕をレビューして」
「このコードの問題点を教えて」
```

**レビュー観点:**
- バグ・ロジックエラー
- セキュリティ（SQLインジェクション・XSS・認証漏れ）
- パフォーマンス（N+1・不要なAPI呼び出し）
- 可読性・命名
- 既存パターンとの一貫性

---

### MODE 4: デバッグ
```
「〔エラーメッセージ〕が出てる」
「〔機能〕が動かない」
```

**手順:**
1. エラーメッセージ・スタックトレースを確認
2. 関連ファイルを `Read` で読む
3. 原因を特定してから修正案を提示
4. 修正後、再現手順を確認

---

### MODE 5: デプロイ
```
「Signal Craftをデプロイして」
「比杵助をデプロイして」
```

#### Signal Craft → Vercel
```bash
cd /Users/kisinomasasi/projects/contents-saas/founder-content-engine
git add -A && git commit -m "deploy: {内容}"
git push origin main
# Vercelが自動デプロイ
```

#### 比杵助 → Cloud Run
```bash
cd /Users/kisinomasasi/projects/character-bot
bash deploy.sh
```

#### flipbook → Cloud Run
```bash
cd /Users/kisinomasasi/projects/flipbook-platform
# デプロイコマンドを確認してから実行
```

---

## 開発ルール

### 共通
- コードを読まずに提案しない。必ず先に `Read` する
- 変更は最小限。必要な箇所だけ触る
- セキュリティ上のリスク（APIキー露出・認証漏れ等）は必ず警告する
- 環境変数はコードに直書きしない

### コミットメッセージ規則
```
feat: 新機能
fix: バグ修正
refactor: リファクタリング
style: スタイル変更
docs: ドキュメント
deploy: デプロイ関連
```

### デプロイ前チェック
- [ ] `git status` で意図しないファイルが含まれていないか
- [ ] 環境変数の変更が必要な場合、本番側（Vercel / env.yaml）も更新済みか
- [ ] APIキー・シークレットがコードに含まれていないか

---

## プロジェクトパス早見表

```
/Users/kisinomasasi/projects/
├── contents-saas/founder-content-engine/   # Signal Craft
├── character-bot/                           # 比杵助・判断ログ
├── flipbook-platform/                       # 電子カタログ
├── portfolio-site/                          # ポートフォリオ
└── cc-company/                              # エージェント管理
```

---

## 品質基準
- 実装前に必ずファイルを読む（Read first）
- 1回の呼び出しで完結させる
- 変更ファイルは必ずユーザーに提示してから実行する
- デプロイは明示的な指示があった場合のみ実行する
