#!/usr/bin/env bash
# agent-kit install.sh
# 実行するだけでセットアップ完了: bash install.sh

set -e

AGENT_KIT_PATH="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " agent-kit セットアップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " インストール先: $AGENT_KIT_PATH"
echo ""

# Step 1: CLAUDE.md を生成（テンプレートのプレースホルダーを実際のパスに置換）
echo "[1/4] CLAUDE.md を生成中..."
sed "s|{{AGENT_KIT_PATH}}|$AGENT_KIT_PATH|g" \
  "$AGENT_KIT_PATH/CLAUDE.template.md" > "$AGENT_KIT_PATH/CLAUDE.md"
echo "      → $AGENT_KIT_PATH/CLAUDE.md"

# Step 2: スキルをシンリンク
echo "[2/4] スキルをセットアップ中..."
mkdir -p "$SKILLS_DIR"

for skill_dir in "$AGENT_KIT_PATH/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
  fi

  ln -s "$skill_dir" "$target"
  echo "      → ~/.claude/skills/$skill_name (symlink)"
done

# Step 3: Slack MCP の設定
echo "[3/4] Slack MCP を設定中..."
ENV_FILE="$AGENT_KIT_PATH/.env"

# .env から SLACK_BOT_TOKEN / SLACK_TEAM_ID を読み込む
SLACK_BOT_TOKEN=""
SLACK_TEAM_ID=""
if [ -f "$ENV_FILE" ]; then
  SLACK_BOT_TOKEN=$(grep "^SLACK_BOT_TOKEN=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
  SLACK_TEAM_ID=$(grep "^SLACK_TEAM_ID=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
fi

# トークンが未設定なら対話入力
if [ -z "$SLACK_BOT_TOKEN" ]; then
  echo ""
  echo "      Slack Bot Token を入力してください（スキップ: Enter）:"
  read -r SLACK_BOT_TOKEN
fi
if [ -z "$SLACK_TEAM_ID" ]; then
  echo "      Slack Team ID を入力してください（スキップ: Enter）:"
  read -r SLACK_TEAM_ID
fi

if [ -n "$SLACK_BOT_TOKEN" ] && [ -n "$SLACK_TEAM_ID" ]; then
  mkdir -p "$CLAUDE_DIR"

  # settings.json が存在しない場合は最小構成で作成
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{"mcpServers":{}}' > "$SETTINGS_FILE"
  fi

  # python3 で mcpServers に slack エントリを追加（既存設定を壊さない）
  python3 - <<PYEOF
import json, sys

path = "$SETTINGS_FILE"
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault("mcpServers", {})["slack"] = {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-slack"],
    "env": {
        "SLACK_BOT_TOKEN": "$SLACK_BOT_TOKEN",
        "SLACK_TEAM_ID": "$SLACK_TEAM_ID"
    }
}

with open(path, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)

print("      → Slack MCP を settings.json に追加しました")
PYEOF
else
  echo "      → Slack トークン未入力のためスキップ（後から .env に設定可）"
fi

# Step 4: 確認
echo "[4/4] 検証中..."
if [ -f "$AGENT_KIT_PATH/CLAUDE.md" ]; then
  echo "      ✓ CLAUDE.md 生成済み"
fi

agent_count=$(find "$AGENT_KIT_PATH/agents" -name "AGENT.md" | wc -l | tr -d ' ')
echo "      ✓ エージェント: ${agent_count} 個"

skill_count=$(find "$AGENT_KIT_PATH/skills" -name "SKILL.md" | wc -l | tr -d ' ')
echo "      ✓ スキル: ${skill_count} 個"

if python3 -c "
import json
cfg = json.load(open('$SETTINGS_FILE'))
assert 'slack' in cfg.get('mcpServers', {})
" 2>/dev/null; then
  echo "      ✓ Slack MCP: 設定済み"
else
  echo "      - Slack MCP: 未設定（.env に SLACK_BOT_TOKEN / SLACK_TEAM_ID を記入後、再実行してください）"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " セットアップ完了！"
echo ""
echo " 使い方:"
echo "   1. cd $AGENT_KIT_PATH"
echo "   2. claude を起動"
echo "   3. 日本語で話しかけるだけ"
echo ""
echo " Slack を後から設定する場合:"
echo "   .env に以下を記入して bash install.sh を再実行"
echo "   SLACK_BOT_TOKEN=xoxb-..."
echo "   SLACK_TEAM_ID=T..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
