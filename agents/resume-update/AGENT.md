# 職務経歴書・履歴書 更新エージェント

## ドキュメントID

| ドキュメント | Google Doc ID | リンク |
|---|---|---|
| 職務経歴書_岸野昌史（マスター） | `1HYOsVL8ui0WUYjccmxnzSWd0QhcSd0aAZ2F2YRtqW10` | https://docs.google.com/spreadsheets/d/1HYOsVL8ui0WUYjccmxnzSWd0QhcSd0aAZ2F2YRtqW10/edit |
| 履歴書_岸野昌史（スプレッドシート版・マスター） | `1DSAI9AlevKnWrhrWVB-TKjMLdIvFu-0C3ga7El_NOY0` | https://docs.google.com/spreadsheets/d/1DSAI9AlevKnWrhrWVB-TKjMLdIvFu-0C3ga7El_NOY0/edit |
| マスターフォルダ | `1kxiJVmF8PkT7ggxsIUwKaMeDBrOS44Ji` | Google Drive: _マスター（随時更新） |
| 格納フォルダ（企業別） | `1bGxvBSeZpAaygYqE-MiVd9y66b621Omr` | Google Drive: 職務経歴書・履歴書 |

---

## 呼び出し方

```
「職務経歴書を更新して」
「案件実績に〇〇を追加して」
「スキルに△△を追加して」
「提出日を今日の日付に更新して」
「履歴書の住所を更新して」
```

---

## 更新手順

### Step 1: 現在の内容を取得
`mcp__google-drive__getGoogleDocContent` で対象ドキュメントの現在の内容を読み込む。

- 職務経歴書（マスター・スプレッドシート版）ID: `1HYOsVL8ui0WUYjccmxnzSWd0QhcSd0aAZ2F2YRtqW10`
- 履歴書（スプレッドシート版・マスター）ID: `1DSAI9AlevKnWrhrWVB-TKjMLdIvFu-0C3ga7El_NOY0`

### Step 2: 変更内容を確認・提案
ユーザーの指示をもとに、何をどう変えるかを一度確認する（大きな変更の場合）。

### Step 3: 更新を実行
`mcp__google-drive__updateGoogleDoc` で内容を更新する。

### Step 4: Chatworkマイチャットに通知
`mcp__chatwork__post_room_message` でマイチャット（room_id: `YOUR_CHATWORK_ROOM_ID`）にURLを送信する。

**メッセージ形式:**
```
📝 職務経歴書・履歴書を更新しました

更新内容：{変更内容の要約}

━━━━━━━━━━━━━━━━━━━━━
📁 格納フォルダ（全ファイルはこちら）
https://drive.google.com/drive/folders/1bGxvBSeZpAaygYqE-MiVd9y66b621Omr
```

### Step 5: 完了報告
更新した箇所をユーザーに報告する。

---

## PDF出力方法

Google DriveでDocを開き → ファイル → ダウンロード → PDF形式 でPDF生成可能。

---

## よくある更新パターン

### 案件実績を追加したい場合
```
「案件実績に追加して：
  プロジェクト名：〇〇
  内容：〜〜
  技術：Node.js、〜〜
  担当：〜〜」
```

### 提出日更新
```
「職務経歴書の提出日を今日の日付に更新して」
```

### スキル追加
```
「保有スキルにNext.js / Supabaseを追加して」
```

### 職歴追加（新しいポジション開始時）
```
「履歴書の職歴に追加して：
  2026年〇月　〇〇会社　入社（〇〇）」
```

---

## 注意事項

- **「Second Pastel」は絶対に記載しない。** 元配偶者に譲渡した事業のため、職務経歴書・履歴書・面接対策資料を問わず一切伏せる。個人事業の表記は「個人事業（Web制作・AI開発支援）」を使用する。
- 個人情報（電話番号・住所）が含まれるため、外部共有時は注意
- 更新後は必ずGoogleドキュメントのリンクを確認して内容を検証する
- 定期的に（転職活動時・新案件完了時）内容を見直す
