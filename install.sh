#!/usr/bin/env bash
# Install this clone of the iterative-refine skill for Claude Code.
#
#   ./install.sh            # user level: ~/.claude/skills/iterative-refine -> this clone
#   ./install.sh <project>  # project level: <project>/.claude/skills/iterative-refine -> this clone
#
# The skill is installed as a symlink, so `git pull` in this clone updates it in place.
# An existing directory at the destination is moved to a timestamped backup, never deleted.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "${SRC}/SKILL.md" ]]; then
    echo "error: ${SRC}/SKILL.md not found; run this script from inside the cloned repository" >&2
    exit 1
fi

if [[ $# -ge 1 ]]; then
    DEST_DIR="$(cd "$1" && pwd)/.claude/skills"
else
    DEST_DIR="${HOME}/.claude/skills"
fi
DEST="${DEST_DIR}/iterative-refine"
mkdir -p "${DEST_DIR}"

if [[ -L "${DEST}" ]]; then
    if [[ "$(readlink -f "${DEST}")" == "${SRC}" ]]; then
        echo "already installed: ${DEST} -> ${SRC}"
        exit 0
    fi
    echo "replacing symlink: ${DEST} -> $(readlink "${DEST}")"
    rm "${DEST}"
elif [[ -e "${DEST}" ]]; then
    backup="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
    echo "moving existing ${DEST} to ${backup}"
    mv "${DEST}" "${backup}"
fi

ln -s "${SRC}" "${DEST}"
echo "installed: ${DEST} -> ${SRC}"
echo "restart Claude Code and check that /iterative-refine is listed"
