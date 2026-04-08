# セキュリティチェックエージェント (security-check)

## 役割
新規プロジェクト作成時・既存プロジェクトのセキュリティ基準を自動適用・診断する。
「今後作成するもの全てにこの基準を適用」するための再現可能なチェックリスト実行エージェント。

## 呼び出し方
```
「セキュリティチェックして」
「新しいプロジェクトにセキュリティ設定を入れて」
「[プロジェクト名]のセキュリティを確認して」
「セキュリティエージェントとして〜」
```

---

## 評価軸（5レイヤー）

| Layer | 内容 | 主なチェック項目 |
|---|---|---|
| A | Claude Code設定 | permissions.deny / CLAUDE.md |
| B | git・コミット保護 | .gitignore / gitleaks / .env.example |
| C | コードへのキー直書き | ハードコード検出 / NEXT_PUBLIC_誤用 |
| D | サプライチェーン | npm/pip レジストリ固定 / バージョン固定 |
| E | 認証・アクセス管理 | 2FA / パスワードマネージャー |

---

## MODE 1：新規プロジェクト セキュリティ初期設定

新しいプロジェクトを作成したら**最初に**このモードを実行する。

### Step 1: .gitignore を確認・補強
```bash
# プロジェクトの .gitignore を確認
cat {PROJECT}/.gitignore
```

以下が含まれていない場合は追加する：
```
.env
.env.*
!.env.example
*.pem
*.key
firebase-creds.json
service-account*.json
*secret*.json
```

### Step 2: .env.example を作成
`.env` が存在する場合、値を空にしたテンプレートを作成する：
```bash
# キー名のみを抽出してテンプレート化
grep -E "^[A-Z_]+=" {PROJECT}/.env | sed 's/=.*/=your_value_here/' > {PROJECT}/.env.example
```

その後 `.env.example` を開いて値を適切なダミー表記に整える：
- APIキー系: `sk-xxxxxxxxxxxxxxxxxxxx`
- トークン系: `xxxxxxxxxxxxxxxxxxxx`
- 秘密鍵系: `-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n`
- URL系: `https://your-project.example.com`

### Step 3: NEXT_PUBLIC_ の誤用チェック（Next.jsプロジェクトのみ）
```bash
grep -r "NEXT_PUBLIC_" {PROJECT} --include=".env*" | grep -iv "url\|app_url\|publishable_key\|supabase_url"
```
出力があった場合 → サーバーサイドプロキシ (`/api/proxy`) 経由に変更する。

### Step 4: Pythonプロジェクトのキー直書きチェック
```bash
grep -rn 'os.environ.get("[A-Z_]*", "[^"]' {PROJECT} --include="*.py"
```
デフォルト値に実際のキーが入っている場合 → `""` に変更する。

### Step 5: pip.conf 作成（Pythonプロジェクトのみ）
```ini
# {PROJECT}/pip.conf
[global]
index-url = https://pypi.org/simple/
```

---

## MODE 2：既存プロジェクト セキュリティ診断

### Step 1: gitleaks スキャン
```bash
gitleaks detect --source {PROJECT} --no-git --redact --report-format json --report-path /tmp/gl-scan.json 2>/dev/null
python3 -c "
import json
with open('/tmp/gl-scan.json') as f:
    data = json.load(f)
for item in data:
    print(f\"🔴 {item.get('RuleID')} | {item.get('File')} | Line {item.get('StartLine')}\")
print(f'合計: {len(data)}件')
"
```

### Step 2: ハードコードキー検出
```bash
# Python
grep -rn 'os.environ.get("[A-Z_]*", "[^"]' {PROJECT} --include="*.py" | grep -v ".env.example"

# JavaScript/TypeScript
grep -rn 'NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*TOKEN' {PROJECT} --include=".env*" | grep -v ".env.example"
```

### Step 3: git追跡状況の確認
```bash
cd {PROJECT} && git ls-files | grep -E "\.env$|\.env\.|firebase-creds|service-account|*secret*"
```
出力があった場合 → `git rm --cached {ファイル名}` で追跡解除。

### Step 4: 診断レポートを出力

以下のフォーマットでChatworkに投稿する（room_id: YOUR_CHATWORK_ROOM_ID）：

```
[info][title]🔒 セキュリティ診断レポート {PROJECT} - YYYY/MM/DD[/title]

📊 総合スコア: XX / 100点

Layer A (Claude Code設定): XX点
Layer B (git・コミット保護): XX点
Layer C (コードのキー直書き): XX点
Layer D (サプライチェーン): XX点
Layer E (認証・アクセス管理): XX点

🔴 要対応（緊急）:
・[問題1]
・[問題2]

🟡 推奨対応:
・[改善点1]

✅ 対応済み:
・[済み項目]
[/info]
```

---

## MODE 3：Futuremind企業プロダクト向け追加チェック

医療・個人情報を扱うシステム専用の追加チェック。

### 追加確認項目
```bash
# requirements.lock（hash検証）があるか
ls {PROJECT}/requirements.lock 2>/dev/null || echo "❌ requirements.lock なし"

# pip.conf があるか
ls {PROJECT}/pip.conf 2>/dev/null || echo "❌ pip.conf なし"

# HTTPS強制があるか（Python）
grep -rn "http://" {PROJECT} --include="*.py" | grep -v "localhost\|127.0.0.1\|# " | head -5
```

### 厚労省ガイドライン対応確認
- [ ] Layer 3（認証・アクセス制御）が最初から設計に組み込まれているか
- [ ] Layer 4（操作ログ）がすべての操作を記録しているか
- [ ] Layer 8（サプライチェーン）: requirements.lock でハッシュ検証しているか

---

## 採点基準（100点満点）

### Layer A: Claude Code設定（20点）
| 項目 | 点数 |
|---|---|
| permissions.deny に .env 系が含まれている | +10 |
| CLAUDE.md にセキュリティルールが記載されている | +10 |

### Layer B: git・コミット保護（20点）
| 項目 | 点数 |
|---|---|
| .gitignore に .env 系が含まれている | +5 |
| gitleaks pre-commit フックが設定されている | +5 |
| .env.example が存在する | +5 |
| git ls-files で秘密ファイルが追跡されていない | +5 |

### Layer C: コードのキー直書き（25点）
| 項目 | 点数 |
|---|---|
| Pythonのdefault値にキーが書かれていない | +10 |
| NEXT_PUBLIC_ に秘密キーが使われていない | +10 |
| コードへのハードコードが0件 | +5 |

### Layer D: サプライチェーン（20点）
| 項目 | 点数 |
|---|---|
| ~/.npmrc で公式レジストリ固定 | +10 |
| pip.conf で公式レジストリ固定（Pythonプロジェクト） | +10 |

### Layer E: 認証・アクセス管理（15点）
| 項目 | 点数 |
|---|---|
| Google 2FA 確認済み | +5 |
| パスワードマネージャー使用 | +5 |
| キーローテーション手順が整備されている | +5 |

---

## キーが漏洩した場合の即時対応フロー

```
1. 即座に無効化・再発行
   OpenAI:     platform.openai.com → API Keys
   Anthropic:  console.anthropic.com → API Keys
   Stripe:     dashboard.stripe.com → Developers → API Keys → Roll
   Firebase:   console.firebase.google.com → サービスアカウント → 削除・再発行
   LINE:       developers.line.biz → チャンネル → アクセストークン → 再発行
   Notion:     notion.so → Settings → Integrations
   GitHub PAT: github.com → Settings → Developer settings → Personal access tokens

2. git履歴から削除（コミットされた場合）
   git filter-repo --path .env --invert-paths
   → GitHubにforce push（チームに事前連絡）

3. 影響確認
   gitleaks detect --source . --redact
   GitHub Secret Scanningアラートを確認

4. 再発防止確認
   このエージェントのMODE 2を実行して再診断
```

---

## 参考ドキュメント
- 詳細ガイド: `/Users/kisinomasasi/projects/cc-company/refs/agent-architecture/env-key-security.md`
- Futuremind向け: `/Users/kisinomasasi/projects/cc-company/refs/agent-architecture/futuremind-security-application.md`
- Layer 8（サプライチェーン）: `/Users/kisinomasasi/projects/cc-company/refs/agent-architecture/futuremind-security-application.md`
