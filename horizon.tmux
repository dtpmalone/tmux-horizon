#!/usr/bin/env bash

TMUX_HORIZON_COLOR_THEME_FILE=horizon.conf
TMUX_HORIZON_STATUS_CONTENT_FILE="horizon-status-content.conf"
TMUX_HORIZON_STATUS_CONTENT_NO_PATCHED_FONT_FILE="horizon-status-content-no-patched-font.conf"
TMUX_HORIZON_STATUS_CONTENT_OPTION="@tmux_horizon_show_status_content"
TMUX_HORIZON_NO_PATCHED_FONT_OPTION="@tmux_horizon_no_patched_font"
_current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

__cleanup() {
  unset -v TMUX_HORIZON_COLOR_THEME_FILE TMUX_HORIZON_VERSION
  unset -v TMUX_HORIZON_STATUS_CONTENT_FILE TMUX_HORIZON_STATUS_CONTENT_NO_PATCHED_FONT_FILE
  unset -v TMUX_HORIZON_STATUS_CONTENT_OPTION TMUX_HORIZON_NO_PATCHED_FONT_OPTION
  unset -v _current_dir
  unset -f __load __cleanup
}

__load() {
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

__load
__cleanup
