###### MANJARO ZSH SETUP ######################################################################################################
## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500
#export EDITOR=/usr/bin/nano
#export VISUAL=/usr/bin/nano
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word


## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

## Alias section 
alias cp="cp -i"                                                # Confirm before overwriting something
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB
alias gitu='git add . && git commit && git push'

# Theming section  
autoload -U compinit colors zcalc
compinit -d
colors

# enable substitution for prompt
setopt prompt_subst

# Prompt (on left side) similar to default bash prompt, or redhat zsh prompt with colors
 #PROMPT="%(!.%{$fg[red]%}[%n@%m %1~]%{$reset_color%}# .%{$fg[green]%}[%n@%m %1~]%{$reset_color%}$ "
# Maia prompt
PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b " # Print some system information when the shell is first started
# Print a greeting message when shell is started
echo $USER@$HOST  $(uname -srm) $(lsb_release -rcs)
## Prompt on right side:
#  - shows status of git when in git repository (code adapted from https://techanic.net/2012/12/30/my_git_prompt_for_zsh.html)
#  - shows exit status of previous command (if previous command finished with an error)
#  - is invisible, if neither is the case

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"                              # plus/minus     - clean repo
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"             # A"NUM"         - ahead by "NUM" commits
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"           # B"NUM"         - behind by "NUM" commits
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"     # lightning bolt - merge conflict
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"       # red circle     - untracked files
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"     # yellow circle  - tracked files modified
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"        # green circle   - staged changes present = ready for "git push"

parse_git_branch() {
  # Show Git branch/tag, or name-rev if on detached head
  ( git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD ) 2> /dev/null
}

parse_git_state() {
  # Show different symbols as appropriate for various Git repository states
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi
  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi
  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_string() {
  local git_where="$(parse_git_branch)"
  
  # If inside a Git repository, print its branch and state
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
  
  # If not inside the Git repo, print exit codes of last command (only if it failed)
  [ ! -n "$git_where" ] && echo "%{$fg[red]%} %(?..[%?])"
}

# Right prompt with exit status of previous command if not successful
 #RPROMPT="%{$fg[red]%} %(?..[%?])" 
# Right prompt with exit status of previous command marked with ✓ or ✗
 #RPROMPT="%(?.%{$fg[green]%}✓ %{$reset_color%}.%{$fg[red]%}✗ %{$reset_color%})"


# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r


## Plugins section: Enable fish style features
# Use syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down

case $(basename "$(cat "/proc/$PPID/comm")") in
  login)
    	RPROMPT="%{$fg[red]%} %(?..[%?])" 
    	alias x='startx ~/.xinitrc'      # Type name of desired desktop after x, xinitrc is configured for it
    ;;
  urxvt)
    	RPROMPT='$(git_prompt_string)'
    	# Use autosuggestion
    	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    	ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ;;
  konsole|qterminal)
    	RPROMPT='$(git_prompt_string)'
    ;;   
  'tmux: server')
  	if $(ps -p$PPID| grep -q -e konsole -e qterminal); then
    	RPROMPT='$(git_prompt_string)'
    else
        RPROMPT='$(git_prompt_string)'
		## Base16 Shell color themes.
		#possible themes: 3024, apathy, ashes, atelierdune, atelierforest, atelierhearth,
		#atelierseaside, bespin, brewer, chalk, codeschool, colors, default, eighties, 
		#embers, flat, google, grayscale, greenscreen, harmonic16, isotope, londontube,
		#marrakesh, mocha, monokai, ocean, paraiso, pop (dark only), railscasts, shapesifter,
		#solarized, summerfruit, tomorrow, twilight
		#theme="eighties"
		#Possible variants: dark and light
		#shade="dark"
		#BASE16_SHELL="/usr/share/zsh/scripts/base16-shell/base16-$theme.$shade.sh"
		#[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
		# Use autosuggestion
		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  		ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  	fi
    ;;
  *)
  	if $(ps -p$PPID| grep -q -e konsole -e qterminal); then
    	RPROMPT='$(git_prompt_string)'
    else
        RPROMPT='$(git_prompt_string)'
		# Use autosuggestion
		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  		ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  	fi
    ;;
esac

eval `keychain --eval colosus-moovel`

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bash:$HOME/bin:/usr/local/bin:$PATH

export PATH=$PATH:~/tools
export PATH=$PATH:~/git/flutter/bin
export PATH=$HOME/bash:$HOME/bin:/usr/local/bin:$PATH
export ANDROID_SDK=:~/android/sdk
export ANDROID_STUDIO=:~/android/android-studio
export ANDROID_STUDIO_BETA=:~/android/android-studio-beta
export PATH="$PATH:$ANDROID_SDK/tools"
export PATH="$PATH:$ANDROID_SDK/tools/bin"
export PATH="$PATH:$ANDROID_SDK/platform-tools"
export PATH="$PATH:$ANDROID_STUDIO/bin"
export PATH="$PATH:$ANDROID_STUDIO_BETA/bin"
export PATH=${PATH}:~/.config/composer/vendor/bin
export PATH=${PATH}:~/tools/ktlint

export NVM_DIR="${XDG_CONFIG_HOME/:-$HOME/.}nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

alias h=history
alias g=git
alias c=clear
alias cl="wc -l"
alias typos="aspell --home-dir=$HOME --personal=.aspell --dont-backup -t -c $1"

# Emulate Mac commands.
alias pbcopy="xclip -selection c"
alias pbpaste="xclip -o"
alias open="command xdg-open" # Command to open in parallel and do not have any logs.
alias xargs="xargs --no-run-if-empty"

# Pidcat alias since we need to install this one manually.
alias pidcat="python $HOME/.pidcat/pidcat.py"

# Copy last command from Terminal into the clipboard.
alias l="fc -ln -1 | sed '1s/^[[:space:]]*//' | awk 1 ORS=\"\" | pbcopy"

function clean {
  local current_gradle_version=$(gw --version | grep Gradle | awk '{print $2}')

  echo "\033[0;32mNuking daemons other than $current_gradle_version\033[0m"
  find ~/.gradle/daemon -maxdepth 1 | tail -n+2 | grep -v $current_gradle_version | xargs rm -rv

  echo "\033[0;32mNuking notifications other than $current_gradle_version\033[0m"
  find ~/.gradle/notifications -maxdepth 1 | tail -n+2 | grep -v $current_gradle_version | xargs rm -rv

  echo "\033[0;32mNuking caches other than $current_gradle_version\033[0m"
  find ~/.gradle/caches -maxdepth 1 | tail -n+2 | ack "[\d\.]{3,5}" | grep -v $current_gradle_version | xargs rm -rv

  echo "\033[0;32mNuking all files in ~/.gradle that have not been accessed in the last 30 days\033[0m"
  find ~/.gradle -type f -atime +30 -delete

  echo "\033[0;32mNuking all empty directories in ~/.gradle/\033[0m"
  find ~/.gradle -mindepth 1 -type d -empty -delete

  echo "\033[0;32mNuking all files in ~/.m2 that have not been accessed in the last 30 days\033[0m"
  find ~/.m2 -type f -atime +30 -delete

  echo "\033[0;32mNuking all empty directories in ~/.m2/\033[0m"
  find ~/.m2 -mindepth 1 -type d -empty -delete

  echo "\033[0;32mSystem dependent clean up\033[0m"
  sysclean
}

# https://github.com/robbyrussell/oh-my-zsh/issues/433
alias rake='noglob rake'

# http://unix.stackexchange.com/questions/130958/scp-wildcard-not-working-in-zsh
setopt nonomatch

# https://github.com/mattjj/my-oh-my-zsh/blob/master/history.zsh
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.

# Finding and doing things.

f() { find . -type f -name $1 -and -not -path "*/build/tmp/*" -and -not -path "*/build/intermediates/*" -and -not -path "*/build/generated/*" -and -not -path "*/build/classes/*" }
fd() { find . -type d -name $1 -and -not -path "*/build/tmp/*" -and -not -path "*/build/intermediates/*" -and -not -path "*/build/generated/*" -and -not -path "*/build/classes/*" }
fs() { subl $(f $1) }
as() { ack -l $1 | xargs subl }
fsod() { f $1 | sed "s/$1//" | xargs open }
frm() { rm -rf $(f $1) }

# Nuke empty directories
function ned {
  find . -mindepth 1 -type d -empty -delete
}

# Git things.
o() {
  remote="${$(git config --get remote.origin.url)}"
  cleanRemote=${${${${remote/git\@/}/.git/}/:/\/}/https:\/\//}
  browser "https://$cleanRemote"
}

dmb() {
  git fetch -p && git branch -vv | ack ': gone' | awk '{print $1}' | grep -v "*" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | xargs -n 1 git branch -D
}

gpr() {
  git fetch origin pull/$1/head:$1 && git checkout $1
}

dab() {
  git branch | grep -v '*' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | xargs git branch -D
}

function git_current_branch {
  echo $(git branch | sed -n '/\* /s///p' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
}

pb() {
  g pho $(git_current_branch)
}

phf() {
  g phf origin $(git_current_branch)
}

function pnb() {
  # Push the current branch.
  g phou $(git_current_branch)

  local last_commit_message=`git log -n 1 --pretty=format:'%s'`

  # Let's try to get a possible ticket by a convention of AB-0123456789:
  local jira_ticket_number=$(echo $last_commit_message | awk '/[A-Z]{2,3}-[0-9]+:/ {print $1}')

  # Remove the :
  local jira_ticket=${jira_ticket_number/:/}

  if [ ! "$jira_ticket" ];then
    title=$(printf "$last_commit_message\n\n$1")
  else
    title=$(printf "$last_commit_message\n\nhttps://moovel.atlassian.net/browse/$jira_ticket\n\n$1")
  fi

  hub pull-request -m $title -F -
}

# Clear pull prune.
function cpp {
  green=`tput setaf 2`
  reset=`tput sgr0`

  for i in */; do
    cd $i

    is_git_directory=$(find . -maxdepth 1 -type d -name ".git" | wc -l)

    if [ $is_git_directory -gt 0 ] ; then
      echo "${green}Clear Pull Pruning $i${reset}"

      git checkout master

      number_of_upstreams=$(git remote | ack -c upstream)

      if [ $number_of_upstreams -gt 0 ] ; then
        # We are in a fork.
        git fa
        git mum
        pb
      else
        # Normal repository that we have access too.
        git up
      fi

      git remote prune origin
      dmb
    fi

    cd ~- # Go to previous directory without echoing.
  done
}

alias od="g dw --no-color > t && subl t"

# Speedread the current content of the clipboard.
function speedread-clipboard {
  pbpaste | speedread -w 500
}

# Gradle.
alias gw="gradle"
alias gws="gradle --stop"
alias gwcb="gradle clean build"
alias gwcbx="gradle clean build -x test"
alias gwcbi="gradle clean build installDebug"
alias gwcbu="gradle clean build uploadArchives"
alias gwcbux="gradle clean build uploadArchives -x test"
alias gwcbuxxx="gradle clean build uploadArchives -x test -x lint -x ktlint -x detekt"
alias gwcdl="gradle lintDebug"
alias gwdu="gradle dependencyUpdates"

gwtc() {
  gw testDebug --tests "*$1*"
}

# Ack shorthands.
alias ay="ack --yaml"
alias ayi="ack --yaml -i"
alias ax="ack --xml"
alias axi="ack --xml -i"
alias ak="ack --kotlin"
alias aki="ack --kotlin -i"
alias aj="ack --java"
alias aji="ack --java -i"
alias ag="ack --groovy"
alias agi="ack --groovy -i"

# Compress iamges.
alias ci="find . -name '*.png' -and -not -name '*.9.png' -exec pngquant --skip-if-larger --speed 1 -f --ext .png 256 {} \;"

# T my favorite.
alias et="chmod +x t && ./t"

# Print Library Version from gradle.properties.
alias lv="ack VERSION_NAME gradle.properties | sed -En \"s/VERSION_NAME=//p\""

# Android.
function androidtakescreenshot() {
  local file_path="/sdcard/$(date +%s).png"

  adb shell screencap -p $file_path
  adb pull $file_path
  adb shell rm $file_path
}

function androidoverdraw() {
  local is_shown=$(adb shell getprop debug.hwui.overdraw)

  if [[ "$is_shown" == "show" ]]; then
    adb shell setprop debug.hwui.overdraw false
  else
    adb shell setprop debug.hwui.overdraw show
  fi
}

function adbInstall(){
  adb isntall 
}

function androidtoggletouches() {
  local show_touches=$(adb shell settings get system show_touches)

  if [[ "$show_touches" == 1 ]]; then
    adb shell settings put system show_touches 0
  else
    adb shell settings put system show_touches 1
  fi
}

function 

function androidlayoutbounds() {
  local is_shown=$(adb shell getprop debug.layout)

  if [[ "$is_shown" == "true" ]]; then
    adb shell setprop debug.layout hidden
  else
    adb shell setprop debug.layout true
  fi
}

#Start from home
cd
