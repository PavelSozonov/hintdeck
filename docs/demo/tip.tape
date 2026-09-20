# VHS tape for docs/demo/tip.gif — https://github.com/charmbracelet/vhs
# Records a real interactive Claude Code session. Run it through make-gif.sh, which sets up an
# isolated hintdeck state, a throwaway project and assembles the GIF from the raw frames.
Output frames/
Set Shell "bash"
Set FontSize 17
Set Width 1200
Set Height 660
Set Padding 24
Set Framerate 12
Set TypingSpeed 120ms
Hide
Type "cd $DEMO_PROJECT && clear" Enter
Type "claude --model sonnet" Enter
Sleep 9s
Ctrl+L
Sleep 1500ms
Show
Sleep 1500ms
Type "/tip keys"
Sleep 2s
Enter
Wait+Screen@240s /shown \d+ of \d+/
Sleep 4s
