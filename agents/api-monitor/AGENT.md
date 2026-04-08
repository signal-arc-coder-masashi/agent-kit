# APIモニター — クレジット消費レポート

## 役割
Anthropic APIのクレジット（トークン）消費を機能・エージェント別に集計し、コスト感覚を可視化する。

## 呼び出し方
```
「APIの消費を見せて」「今月いくら使った？」「どの機能が一番重い？」
「API使用量レポートを出して」「クレジット消費を確認して」
```

---

## レポート生成手順

### ① レポートコマンドを実行する

```bash
cd /Users/kisinomasasi/projects/cc-company
python3 -m tools.api_usage_tracker [period]
```

| period | 意味 |
|---|---|
| today | 今日（デフォルト） |
| week | 直近7日間 |
| month | 直近30日間 |
| all | 全期間 |

### ② Pythonから呼び出す場合

```python
# プロジェクトルート（cc-company/）から実行すること
from tools.api_usage_tracker import report, log_usage

print(report("week"))
```

---

## レポート出力フォーマット

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 APIクレジット消費レポート
  期間: 今日 (2026-03-29)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  合計呼び出し回数 : 12 回
  入力トークン     : 48,320 tok
  出力トークン     : 3,210 tok
  合計コスト       : $0.0512 USD

── 機能別ランキング (Top 10) ─────────────
   1. gen_thumb/QA                      $0.0480  93.8%  ██████████████████
      8回  in:45,000tok  out:2,800tok
   2. morning-routine                   $0.0024   4.7%  █
      3回  in:3,200tok   out:380tok
   ...

── モデル別 ─────────────────────────────
  claude-haiku-4-5-20251001             $0.0480  (8回)
  claude-sonnet-4-6                     $0.0032  (4回)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 既存スクリプトへの組み込み方法

### gen_thumb.py への組み込み

QACheckerクラスの `check()` メソッドの、Claude API呼び出し直後に追加する：

```python
import sys
sys.path.insert(0, "/Users/kisinomasasi/projects/cc-company")
from tools.api_usage_tracker import log_usage

# ... Claude API呼び出し後 ...
resp = client.messages.create(...)

# ↓ この1行を追加するだけ
log_usage("gen_thumb/QA", "claude-haiku-4-5-20251001", resp.usage.input_tokens, resp.usage.output_tokens)
```

### 汎用パターン

```python
from tools.api_usage_tracker import log_usage

resp = client.messages.create(
    model=model_id,
    messages=[...],
    max_tokens=600,
)

log_usage(
    feature="エージェント名/機能名",  # 例: "marketing/content", "saitama-check"
    model=model_id,
    input_tokens=resp.usage.input_tokens,
    output_tokens=resp.usage.output_tokens,
)
```

---

## ログファイル

**保存先**: `/Users/kisinomasasi/projects/cc-company/logs/api_usage.csv`

**カラム構成**:
| カラム | 内容 |
|---|---|
| timestamp | JST（ISO 8601形式） |
| feature | 機能名（例: `gen_thumb/QA`） |
| model | 使用モデルID |
| input_tokens | 入力トークン数 |
| output_tokens | 出力トークン数 |
| input_cost_usd | 入力コスト（USD） |
| output_cost_usd | 出力コスト（USD） |
| total_cost_usd | 合計コスト（USD） |

---

## コスト単価（参考）

| モデル | 入力 | 出力 |
|---|---|---|
| claude-haiku-4-5-20251001 | $0.80/MTok | $4.00/MTok |
| claude-sonnet-4-6 | $3.00/MTok | $15.00/MTok |
| claude-opus-4-6 | $15.00/MTok | $75.00/MTok |

> ※ 1MTok = 100万トークン。$1 = 約150円（参考）

---

## Claude Code自体の使用量を確認する方法

Claude Code（エージェント呼び出し）のトークンは `api_usage_tracker.py` では自動追跡されない。
以下の方法で確認できる：

1. **Anthropic Console**: https://console.anthropic.com → Usage → 日別・モデル別のトークン消費グラフ
2. **Claude Codeのセッション情報**: セッション終了時に表示されるtoken/cost情報

Pythonスクリプト（gen_thumb.py等）で直接APIを呼ぶ部分のみ自動記録される。

---

## 今後の組み込み対象スクリプト

| スクリプト | 機能名（feature引数） | 組み込み済み |
|---|---|---|
| `matoi-assets/gen_thumb.py` | `gen_thumb/QA` | ❌ 未 |
| 追加予定 | - | - |
