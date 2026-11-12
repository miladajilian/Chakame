#!/usr/bin/env bash
# PostToolUse hook: format the Swift file Claude just edited or wrote.
# No-op when swiftformat isn't installed or the file isn't Swift.
file=$(/usr/bin/python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[[ "$file" == *.swift && -f "$file" ]] || exit 0
command -v swiftformat >/dev/null 2>&1 || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" && swiftformat --quiet "$file" >/dev/null 2>&1 || true
exit 0
