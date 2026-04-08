#!/usr/bin/env bash
# agent-kit uninstall.sh
# シンリンクと生成ファイルを削除する

set -e

AGENT_KIT_PATH="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " agent-kit アンインストール"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# スキルのシンリンクを削除
echo "[1/2] スキルのシンリンクを削除中..."
for skill_dir in "$AGENT_KIT_PATH/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
    echo "      → ~/.claude/skills/$skill_name を削除"
  fi
done

# 生成された CLAUDE.md を削除
echo "[2/2] 生成ファイルを削除中..."
if [ -f "$AGENT_KIT_PATH/CLAUDE.md" ]; then
  rm "$AGENT_KIT_PATH/CLAUDE.md"
  echo "      → CLAUDE.md を削除"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " アンインストール完了"
echo " （agent-kit フォルダ自体は残っています）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
