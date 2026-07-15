# ~/.config/zsh/history.zsh
#
# History configuration and shell options.

# --- History ---
mkdir -p "$XDG_STATE_HOME/zsh"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

# Store timestamps with history entries.
setopt EXTENDED_HISTORY

# Keep history clean by removing duplicates.
# (HIST_IGNORE_ALL_DUPS supersedes HIST_IGNORE_DUPS, so the latter was
# dropped. HIST_EXPIRE_DUPS_FIRST is also skipped: it only matters when
# there are duplicate lines left to expire preferentially over old
# unique ones, but HIST_IGNORE_ALL_DUPS already strips duplicates as
# they occur, so there's nothing left for it to act on.)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Ignore commands that begin with a space.
setopt HIST_IGNORE_SPACE

# Normalize whitespace in saved history.
setopt HIST_REDUCE_BLANKS

# Share history between all running shells.
# (SHARE_HISTORY implies INC_APPEND_HISTORY, so the latter was dropped.)
setopt SHARE_HISTORY

# Enable advanced globbing features.
setopt EXTENDED_GLOB
setopt NOCASEGLOB
setopt NUMERIC_GLOB_SORT

# Quality-of-life improvements.
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
