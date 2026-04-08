# agent-kit

Claude Code 用 AI エージェントチーム。
どの Mac・どの環境にも `bash install.sh` 1コマンドで展開できる。

---

## セットアップ

```bash
git clone <this-repo> agent-kit
cd agent-kit
bash install.sh
```

完了後、`cd agent-kit` して `claude` を起動すれば即動作。

---

## 構造

```
agent-kit/
├── install.sh              # セットアップ（1コマンド）
├── uninstall.sh            # クリーン削除
├── CLAUDE.template.md      # ルーター定義（プレースホルダー版）
├── CLAUDE.md               # install.sh が生成（gitignore）
│
├── agents/                 # 全エージェント（19種）
│   ├── ceo/                # 総合判断・優先順位
│   ├── morning-routine/    # 朝ルーティン
│   ├── daily-close/        # 日次クローズ
│   ├── check-in/           # 中間確認
│   ├── pm/                 # プロジェクト進捗
│   ├── dev/                # 開発・コード
│   ├── research/           # リサーチ
│   ├── marketing/          # 投稿・マーケ
│   ├── content-engine/     # コンテンツ戦略
│   ├── security-check/     # セキュリティ
│   ├── api-monitor/        # API使用量
│   ├── conversion-designer/# LP・CTA・導線
│   ├── decision-simulator/ # 意思決定
│   ├── growth-analyst/     # KPI・グロース
│   ├── interview-prep/     # 面接対策
│   ├── knowledge-architect/# ナレッジ統合
│   ├── resume-update/      # 職務経歴書
│   ├── sales-architect/    # 営業・提案書
│   └── work-report/        # 作業報告書
│
├── skills/                 # スキル（install.sh が ~/.claude/skills/ にシンリンク）
│   ├── session-close/      # セッション終了・Obsidian保存
│   └── code-review/        # 4軸コードレビュー
│
└── reference/              # 参照データ（gitignore）
    ├── context.md          # 個人・プロジェクト情報（各自記入）
    └── clients.md          # クライアント一覧（各自記入）
```

---

## 使い方

日本語で話しかけるだけ。キーワードで自動的に適切なエージェントが起動する。

| キーワード例 | 起動エージェント |
|---|---|
| おはよう / 朝ルーティン | morning-routine |
| CEOに相談 / 優先順位 | ceo |
| 開発 / コード / バグ | dev |
| 調べて / リサーチ | research |
| クローズ / 日報 | daily-close |
| セキュリティチェック | security-check |

---

## 新環境への移設手順

1. このリポジトリをクローンまたはコピー
2. `reference/context.md` を自分の情報で記入
3. `reference/clients.md` を自分のクライアント情報で作成
4. `bash install.sh` を実行

---

## アンインストール

```bash
bash uninstall.sh
```

シンリンクと生成ファイルのみ削除。フォルダ本体は残る。
