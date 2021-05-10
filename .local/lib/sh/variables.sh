LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

GREP_OPTIONS="--color=auto"

HISTSIZE=32768 # Larger bash history (allow 2^15 entries; default is 500)
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help" # Make some commands not show up in history

HOMEBREW_NO_ANALYTICS=1;

# 10 second wait if you do something that will delete everything.
setopt RM_STAR_WAIT
