#!/usr/bin/env bash

set -e

TMUX_HORIZON_COLOR_THEME_FILE=horizon.conf
TMUX_HORIZON_STATUS_CONTENT_FILE="horizon-status-content.conf"
TMUX_HORIZON_STATUS_CONTENT_NO_PATCHED_FONT_FILE="horizon-status-content-no-patched-font.conf"
TMUX_HORIZON_STATUS_CONTENT_OPTION="@tmux_horizon_show_status_content"
TMUX_HORIZON_NO_PATCHED_FONT_OPTION="@tmux_horizon_no_patched_font"
_current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

__cleanup () {
  unset -v TMUX_HORIZON_COLOR_THEME_FILE TMUX_HORIZON_VERSION
  unset -v TMUX_HORIZON_STATUS_CONTENT_FILE TMUX_HORIZON_STATUS_CONTENT_NO_PATCHED_FONT_FILE
  unset -v TMUX_HORIZON_STATUS_CONTENT_OPTION TMUX_HORIZON_NO_PATCHED_FONT_OPTION
  unset -v _current_dir
  unset -f __load __cleanup __bacon tmux_option
}

__load () {
  tmux source-file "$_current_dir/$TMUX_HORIZON_COLOR_THEME_FILE"

  local status_content=$(tmux show-option -gqv "$TMUX_HORIZON_STATUS_CONTENT_OPTION")
  local no_patched_font=$(tmux show-option -gqv "$TMUX_HORIZON_NO_PATCHED_FONT_OPTION")

  if [ "$status_content" != "0" ]; then
    if [ "$no_patched_font" != "1" ]; then
      tmux source-file "$_current_dir/$TMUX_HORIZON_STATUS_CONTENT_FILE"
    else
      tmux source-file "$_current_dir/$TMUX_HORIZON_STATUS_CONTENT_NO_PATCHED_FONT_FILE"
    fi
  fi
}

tmux_option() {
    local -r value=$(tmux show-option -gqv "$1")
    local -r default="$2"

    if [ -n "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

__bacon () {
  local -r H_PLACEHOLDER="\#\{hori_bacon\}"
  local -r H_CURRENT_SESSION="$(tmux display-message -p '#S' )"
  local -r H_CURRENT_WINDOW="$(tmux display-message -p '#I' )"
  local H_WINDOWS=$(tmux list-windows -t "$CURRENT_SESSION" -F '#{window_index}:#{window_name}' )
  local H_RESULT=""

  SAVEIFS=$IFS
  IFS=$'\n'
  H_WINDOWS=($H_WINDOWS)
  IFS=$SAVEIFS

  for (( i=0; i<${#H_WINDOWS[@]}; i++ ))
  do
    local H_WIN_INDEX H_WIN_NAME
    local IS_ACTIVE=0

    IFS=':' read -r -a H_WIN <<< "${H_WINDOWS[$i]}"

    if (( "${H_WIN[0]}" == "$H_CURRENT_WINDOW" )); then
      IS_ACTIVE=1
    fi
    
    case "${H_WIN[0]}" in
      0)
        H_WIN_INDEX=$'\uf8a0'
        ;;
      1)
        H_WIN_INDEX=$'\uf8a3'
        ;;
      2)
        H_WIN_INDEX=$'\uf8a6'
        ;;
      3)
        H_WIN_INDEX=$'\uf8a9'
        ;;
      4)
        H_WIN_INDEX=$'\uf8ac'
        ;;
      5)
        H_WIN_INDEX=$'\uf8af'
        ;;
      6)
        H_WIN_INDEX=$'\uf8b2'
        ;;
      7)
        H_WIN_INDEX=$'\uf8b5'
        ;;
      8)
        H_WIN_INDEX=$'\uf8b8'
        ;;
      9)
        H_WIN_INDEX=$'\uf8bb'
        ;;
      *)
        H_WIN_INDEX="${H_WIN[0]}"
        ;;
    esac

    if (( IS_ACTIVE == 1 )); then
      H_RESULT+="#[fg=blue]"
    else
      H_RESULT+="#[fg=white]"
    fi
    
    H_RESULT+="$H_WIN_INDEX ${H_WIN[1]}"
    if (( $i < ${#H_WINDOWS[@]}-1 )); then
      H_RESULT+="    "
    fi
  done

  # echo "PRE-RESULT: $H_RESULT"

  local -r H_STATUS_RIGHT="$(tmux_option 'status-right')"
  # echo "STATUS-RIGHT: $H_STATUS_RIGHT"
  # echo "RESULT:       ${H_RESULT}"
  # echo "-->           ${H_STATUS_RIGHT/$H_PLACEHOLDER/$H_RESULT}"
  tmux set-option -g "status-right" "${H_STATUS_RIGHT/$H_PLACEHOLDER/$H_RESULT}"
}

__load
__bacon
__cleanup
