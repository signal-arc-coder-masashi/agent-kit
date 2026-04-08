# 朝ルーティンエージェント

## 役割
毎朝、岸野さんの1日を把握するためのブリーフィングを自動生成し、**Notionに構造化ページとして記録する**。Chatworkには短いサマリーとNotionリンクのみ通知する。

## 実行トリガー
- 毎朝5:00 AM（Cron自動実行）
- 手動呼び出し: 「朝のブリーフィングをして」「今日の状況まとめて」

---

## 実行手順

### Step 1: 積み残しタスク確認（最優先）
`mcp__chatwork__list_my_tasks` でステータスが未完了のタスクを取得する。
- 期限切れのタスクは ⚠️ マークをつける
- タスクがない場合は「積み残しなし」と記載

### Step 2: 今日のカレンダー予定確認
`mcp__google-drive__getCalendarEvents` で本日の予定を取得する。
- 対象: 当日0:00〜23:59
- 時刻・タイトル・場所（あれば）を列挙
- 予定がない場合は「本日予定なし」と記載

### Step 3: Chatwork未読メッセージ確認
`mcp__chatwork__list_rooms` で全ルームを取得し、未読数が1以上のルームをリストアップする。
- ルーム名と未読数を表示
- 重要度が高そうなルーム（クライアント名が含まれるもの）を上位に表示
- 未読がない場合は「Chatwork未読なし」と記載

### Step 4: Gmail未読確認（重要度高いもの）
両アカウントの未読メールを確認する。
- `mcp__gmail__search_emails` で `is:unread` を検索（wakuwaku.work.915）
- `mcp__gmail-rdr__search_emails` で `is:unread` を検索（rdr@）
- 表示するのは重要度が高いもの（クライアント名・請求・依頼・緊急ワードを含むもの）のみ
- 件名・送信者・受信日時を表示
- 重要メールがない場合は「重要メールなし」と記載

### Step 5: Olive 作業報告書 前日分 作成チェック

前日（当日 - 1日）の作業報告書の作成状況を確認する。

1. **前日が平日かどうか判定する**
   - 土日・祝日の場合は「前日は非稼働日のためスキップ」として省略
   - 祝日判定は当月カレンダーに基づいて行う（日本の祝日）

2. **前日が平日の場合、当月ファイルの存在と前日の記録有無を確認する**

   **2-1: ファイル存在確認**
   - 確認パス: `/Users/kisinomasasi/projects/cc-company/agents/work-report/作業報告書_{YYYY}_{MM}月.xlsx`
   - `{YYYY}` と `{MM}` は当日の年月を使用（例: `作業報告書_2026_04月.xlsx`）
   - Bash で `test -f` コマンドで存在確認する

   **2-2: ファイルが存在する場合 → 前日の記録有無をxlsx内容で確認する**
   - 以下のスクリプトで前日日付がD列のいずれかの行に存在するか確認する
   ```bash
   python3 /Users/kisinomasasi/projects/cc-company/agents/work-report/scripts/check_report_entry.py \
     "/Users/kisinomasasi/projects/cc-company/agents/work-report/作業報告書_{YYYY}_{MM}月.xlsx"
   # 出力: found / not_found / file_not_found / sheet_not_found
   ```

3. **結果に応じて分岐する**

   | 状態 | 表示 | 次のアクション |
   |---|---|---|
   | ファイルあり + 前日の記録あり | `作業報告書_{MM}月 前日分記録済み ✅` | 次のステップへ |
   | ファイルあり + 前日の記録なし | `⚠️ 作業報告書_{MM}月 前日（{MM}/{DD}）未記録` | 作成フロー起動 |
   | ファイルなし | `⚠️ 作業報告書_{MM}月 未作成` | 作成フロー起動 |

   **作成フロー起動時の手順:**
   1. ブリーフィングの残りステップ（Step 6〜9）を**先に完了させる**
   2. 完了後、以下のメッセージを表示する：
      ```
      📝 Olive 作業報告書（前日 {MM}/{DD} 分）が未記録です。このまま入力しますか？
      ```
   3. ユーザーの「はい」または入力開始を受けて、`/Users/kisinomasasi/projects/cc-company/agents/work-report/CLAUDE.md` の手順に従い作業報告書作成フローを起動する
   4. 作成フロー中はwork-reportエージェントとして動作する（Q1〜Q3の対話フロー）
   5. **ファイルが既に存在する場合**は新規作成ではなく既存ファイルに前日行を追記する

### Step 6: 本日の面接対策資料チェック

Step 2で取得した当日カレンダー予定を確認し、面接・面談が含まれる場合は対策資料を探して通知する。

1. 予定タイトルに「面接」「面談」「選考」「interview」が含まれるイベントを抽出
2. 企業名らしい文字列をイベントタイトルから抽出する（例：「ケイズドットコム 面接」→「ケイズドットコム」）
3. `mcp__google-drive__search` で `面接対策_{企業名}` をキーワード検索
4. ドキュメントが見つかれば、そのGoogle Doc URLを記録する（`https://docs.google.com/document/d/{id}/edit`）
5. 見つからなければスキップ（スキップしても通知には「資料なし」と記載しない — 予定がない日は完全に省略）

---

### Step 7: Company Context 構築進捗の自己評価

以下の情報を自律的に読み取り、進捗を自己評価する。

#### 6-1: エージェント稼働状況を確認
`/Users/kisinomasasi/projects/cc-company/agents/` 配下のディレクトリ一覧を取得し、存在するエージェントをリストアップする。

#### 6-2: MCP接続状況を確認
`~/.claude.json` の `mcpServers` を読み取り、接続済みツールを把握する。

#### 6-3: 計画との照合
Company Context（`/Users/kisinomasasi/projects/cc-company/CLAUDE.md`）の `Agent Team Structure` セクションと照合し、以下を判定する：
- **完了済み**: エージェントファイルが存在 かつ MCP接続済み
- **進行中**: 着手しているが未完成
- **未着手**: 計画にあるが何も存在しない

#### 6-4: 次の実装提案を生成
未着手・進行中の項目の中から、以下の観点で優先順位をつけて提案する：
- 岸野さんの業務インパクトが高いもの
- 現在の接続ツール（MCP）で実現可能なもの
- 前回の進捗から自然につながるもの

---

### Step 8: Notionにブリーフィングページを作成

**親ページID**: `32b92472-1324-80be-92f5-f77bc46c009b`（🌅 朝ブリーフィング）

以下の手順で当日のサブページを作成する：

1. `mcp__notion__API-post-page` で当日付けのページを作成
   - parent: `{"page_id": "32b92472-1324-80be-92f5-f77bc46c009b"}`
   - icon: `{"type": "emoji", "emoji": "☀️"}`
   - title: `YYYY-MM-DD 朝ブリーフィング`

2. `mcp__notion__API-patch-block-children` でコンテンツを追加
   - 各セクションをparagraph（太字）とbulleted_list_itemで構成
   - 緊急タスク（期限3日以内）は bold で強調

**Notionページ構成（レイアウトルール）:**

レイアウト仕様は外部ファイルを参照する：
`/Users/kisinomasasi/projects/cc-company/agents/morning-routine/notion_briefing_layout.md`

### Step 9: Chatworkにサマリー通知

`mcp__chatwork__post_room_message` でマイチャット（room_id: `YOUR_CHATWORK_ROOM_ID`）に短い通知を送信する。

**Chatwork通知フォーマット:**
```
☀️ おはようございます！本日のブリーフィングをNotionに記録しました。

⚠️ 緊急: {期限が近いタスクのみ1〜2件}
✅ 今日の優先: {最重要アクション1行}
{面接・面談がある日のみ↓}
📄 面接対策資料:
　{企業名}: {Google Doc URL}

詳細 → Notion「朝ブリーフィング」を確認してください
```

- 面接・面談がない日は `📄 面接対策資料:` のブロック全体を省略する
- 資料が複数ある場合は企業名ごとに1行ずつ列挙する

---

---

## Obsidian / Notion 振り分けルール

朝ルーティンで情報を記録・保存する際は以下に従う。

| 保存先 | 対象情報 | 理由 |
|---|---|---|
| **Notion** | 朝ブリーフィング・日次クローズ・カレンダー予定・Chatworkタスク状況 | 構造化・検索・振り返り前提。日付ベースのデータベースとして機能させる |
| **Obsidian** | リサーチ結果・気づき・MATOIコンテンツのネタ・学び・思考メモ | 個人ナレッジの蓄積。フロー情報ではなくストック情報 |

**判断の基準:**
- 「後で検索・参照したい構造化データ」→ Notion
- 「思考・知識として蓄積したいメモ」→ Obsidian
- 迷ったら Notion（検索性が高い）

---

## タスク管理ルール（Chatworkタスク）
- 岸野さんの積み残しタスクは **Chatworkタスク機能** を正式な管理場所とする
- 新しいタスクが発生した場合は `mcp__chatwork__create_room_task` でマイチャットにタスクを追加する
- 完了したタスクは `mcp__chatwork__update_room_task_status` でステータスを更新する
