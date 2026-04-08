#!/usr/bin/env bash
# agent-kit install.sh
# 実行するだけでセットアップ完了: bash install.sh

set -e

AGENT_KIT_PATH="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " agent-kit セットアップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " インストール先: $AGENT_KIT_PATH"
echo ""

# Step 1: CLAUDE.md を生成（テンプレートのプレースホルダーを実際のパスに置換）
echo "[1/3] CLAUDE.md を生成中..."
sed "s|{{AGENT_KIT_PATH}}|$AGENT_KIT_PATH|g" \
  "$AGENT_KIT_PATH/CLAUDE.template.md" > "$AGENT_KIT_PATH/CLAUDE.md"
echo "      → $AGENT_KIT_PATH/CLAUDE.md"

# Step 2: スキルをシンリンク
echo "[2/3] スキルをセットアップ中..."
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

# Step 3: 確認
echo "[3/3] 検証中..."
if [ -f "$AGENT_KIT_PATH/CLAUDE.md" ]; then
  echo "      ✓ CLAUDE.md 生成済み"
fi

agent_count=$(find "$AGENT_KIT_PATH/agents" -name "AGENT.md" | wc -l | tr -d ' ')
echo "      ✓ エージェント: ${agent_count} 個"

skill_count=$(find "$AGENT_KIT_PATH/skills" -name "SKILL.md" | wc -l | tr -d ' ')
echo "      ✓ スキル: ${skill_count} 個"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " セットアップ完了！"
echo ""
echo " 使い方:"
echo "   1. cd $AGENT_KIT_PATH"
echo "   2. claude を起動"
echo "   3. 日本語で話しかけるだけ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
