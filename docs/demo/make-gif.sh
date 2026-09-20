#!/bin/bash
# Re-records docs/demo/tip.gif from a real Claude Code session.
# Needs: vhs, ffmpeg, a logged-in `claude`, and the tip skill installed (plugin or ~/.claude/skills).
#
# Notes
# - The session runs on an isolated hintdeck state (HINTDECK_STATE_DIR) in English, so recording
#   does not touch your own shown history.
# - The demo project must already be trusted by Claude Code, otherwise the trust dialog is what
#   gets recorded: run `claude` there once before recording.
# - The GIF is assembled with ffmpeg from raw frames rather than by vhs itself (vhs 0.12 fails
#   silently with ffmpeg 9). MASK hides the plan name in the banner, CROP_H drops the footer row.
set -euo pipefail
cd "$(dirname "$0")"
WORK="$(mktemp -d)"
export DEMO_PROJECT="${DEMO_PROJECT:-$HOME/hintdeck-demo/my-app}"
export HINTDECK_STATE_DIR="$WORK/state" HINTDECK_LANG=en
MASK="${MASK:-drawbox=x=436:y=66:w=160:h=28:color=0x171717:t=fill}"
CROP_H="${CROP_H:-606}"

mkdir -p "$HINTDECK_STATE_DIR" && : > "$HINTDECK_STATE_DIR/lang-offered"
if [ ! -d "$DEMO_PROJECT" ]; then
  mkdir -p "$DEMO_PROJECT/src" && ( cd "$DEMO_PROJECT" && git init -q -b main \
    && printf 'def main():\n    print("hello")\n' > src/app.py && printf '# my-app\n' > README.md )
  echo "Created $DEMO_PROJECT — run 'claude' there once to accept the trust dialog, then re-run." >&2
  exit 1
fi

cp tip.tape "$WORK/tip.tape" && ( cd "$WORK" && vhs tip.tape >/dev/null )
ffmpeg -v error -y -f lavfi -i "color=c=0x171717:s=1200x660:r=12" \
  -framerate 12 -i "$WORK/frames/frame-text-%05d.png" -framerate 12 -i "$WORK/frames/frame-cursor-%05d.png" \
  -filter_complex "[0][1]overlay=(W-w)/2:(H-h)/2:shortest=1[a];[a][2]overlay=(W-w)/2:(H-h)/2:shortest=1[b];[b]${MASK},crop=1200:${CROP_H}:0:0,tpad=stop_mode=clone:stop_duration=5,split[s0][s1];[s0]palettegen=max_colors=64:stats_mode=diff[p];[s1][p]paletteuse=dither=none:diff_mode=rectangle" \
  -loop 0 tip.gif
rm -rf "$WORK"
echo "wrote $(pwd)/tip.gif — review every frame for personal details before committing"
