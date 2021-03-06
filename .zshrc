source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Aliases
function git(){hub "$@"}
alias dc="docker-compose"
alias dss="docker-sync-stack"

# Nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Python
alias brew="PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin brew"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
eval "$(pyenv init -)"


# R言語利用のためzshのrを無効にする
disable r

# vcs_info 設定
RPROMPT=""
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz colors

zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' formats '(%s)-[%b]' '%c%u %m'
  zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"    # %c で表示する文字列
  zstyle ':vcs_info:git:*' unstagedstr "-"  # %u で表示する文字列
fi

if is-at-least 4.3.11; then
  zstyle ':vcs_info:git+set-message:*'hooks \
    git-hook-begin \
    git-untracked \
    git-push-status \
    git-nomerge-branch \
    git-stash-count

    function +vi-git-hook-begin() {
      if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
        return 1
      fi
      return 0
    }

    function +vi-git-untracked() {
      if [[ "$1" != "1" ]]; then
        return 0
      fi
      if command git status --porcelain 2> /dev/null \
        | awk '{print $1}' \
        | command grep -F '??' > /dev/null 2>&1 ; then
        hook_com[unstaged]+='?'
      fi
    }

  function +vi-git-push-status() {
    if [[ "$1" != "1" ]]; then
      return 0
    fi
    if [[ "${hook_com[branch]}" != "master" ]]; then
      return 0
    fi
    local ahead
    ahead=$(command git rev-list origin/master..master 2>/dev/null \
      | wc -l \
      | tr -d ' ')

    if [[ "$ahead" -gt 0 ]]; then
      # misc (%m) に追加
      hook_com[misc]+="(p${ahead})"
    fi
  }

  function +vi-git-nomerge-branch() {
    if [[ "$1" != "1" ]]; then
      return 0
    fi

    if [[ "${hook_com[branch]}" == "master" ]]; then
      return 0
    fi

    local nomerged
    nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$nomerged" -gt 0 ]] ; then
        hook_com[misc]+="(m${nomerged})"
    fi
  }

  function +vi-git-stash-count() {
    if [[ "$1" != "1" ]]; then
      return 0
    fi

    local stash
    stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${stash}" -gt 0 ]]; then
      hook_com[misc]+=":S${stash}"
    fi
  }
fi

function _update_vcs_info_msg() {
  local -a messages
  local prompt
  LANG=en_US.UTF-8 vcs_info

  if [[ -z ${vcs_info_msg_0_} ]]; then
    prompt=""
  else
    [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
    [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
    [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )
    prompt="${(j: :)messages}"
  fi
  RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg

