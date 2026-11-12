#!/usr/bin/env bash
# Prints an xcodebuild -destination for an available iPhone simulator.
# Prefers a booted iPhone, otherwise the first iPhone on the newest iOS runtime.
# Override with: SIM_ID=<udid> or SIM="iPhone 17" (newest runtime with that name).
set -euo pipefail

if [[ -n "${SIM_ID:-}" ]]; then
  echo "platform=iOS Simulator,id=${SIM_ID}"
  exit 0
fi

xcrun simctl list devices available -j | /usr/bin/python3 -I -c '
import json, os, sys, re
want = os.environ.get("SIM", "")
data = json.load(sys.stdin)["devices"]
def ver(rt):
    m = re.search(r"iOS-(\d+)-(\d+)", rt)
    return (int(m.group(1)), int(m.group(2))) if m else None
runtimes = sorted((r for r in data if ver(r)), key=ver, reverse=True)
phones = [d for r in runtimes for d in data[r] if d["name"].startswith("iPhone")]
if want:
    phones = [d for d in phones if d["name"] == want]
booted = [d for d in phones if d["state"] == "Booted"]
pick = (booted or phones or [None])[0]
if not pick:
    sys.exit("No available iPhone simulator found" + (f" named {want!r}" if want else ""))
print("platform=iOS Simulator,id=" + pick["udid"])
'
