#!/usr/bin/env bash
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# -- general -------------------------------------------------------------------

set -g default-terminal "screen-256color" # colors!
setw -g xterm-keys on
set -s escape-time 10                     # faster command sequences
set -sg repeat-time 600                   # increase repeat timeout
set -s focus-events on

# set -g prefix2 C-a                        # GNU-Screen compatible prefix
# bind C-a send-prefix -2

set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
setw -q -g utf8 on

set -g history-limit 5000                 # boost history

# reload configuration
bind r source-file ~/.tmux.conf \; display '~/.tmux.conf sourced'


# -- display -------------------------------------------------------------------

set -g base-index 1           # start windows numbering at 1
setw -g pane-base-index 1     # make pane numbering consistent with windows

setw -g automatic-rename on   # rename window to reflect current program
set -g renumber-windows on    # renumber windows when a window is closed

set -g set-titles on          # set terminal title

set -g display-panes-time 800 # slightly longer pane indicators display time
set -g display-time 1000      # slightly longer status messages display time

set -g status-interval 10     # redraw status line every 10 seconds

# clear both screen and history
bind -n C-l send-keys C-l \; run 'sleep 0.1' \; clear-history

# activity
set -g monitor-activity on
set -g visual-activity off


# -- navigation ----------------------------------------------------------------

# create session
bind C-c new-session

# find session
bind C-f command-prompt -p find-session 'switch-client -t %%'

# split current window horizontally
bind - split-window -v
# split current window vertically
bind _ split-window -h

# pane navigation
bind -r h select-pane -L  # move left
bind -r j select-pane -D  # move down
bind -r k select-pane -U  # move up
bind -r l select-pane -R  # move right
bind > swap-pane -D       # swap current pane with the next one
bind < swap-pane -U       # swap current pane with the previous one

# maximize current pane
bind + run 'echo #{current_dir}/lib.sh | sh -s _maximize_pane "#{session_name}" #D'

# pane resizing
bind -r H resize-pane -L 2
bind -r J resize-pane -D 2
bind -r K resize-pane -U 2
bind -r L resize-pane -R 2

# window navigation
unbind n
unbind p
bind -r C-h previous-window # select previous window
bind -r C-l next-window     # select next window
bind Tab last-window        # move to last active window

# toggle mouse
# bind m run "cut -c3- ~/.tmux.conf | sh -s _toggle_mouse"


# -- urlview -------------------------------------------------------------------

# bind U run "cut -c3- ~/.tmux.conf | sh -s _urlview #{pane_id}"


# -- facebook pathpicker -------------------------------------------------------

# bind F run "cut -c3- ~/.tmux.conf | sh -s _fpp #{pane_id}"


# -- list choice (tmux < 2.4) --------------------------------------------------

# vi-choice is gone in tmux >= 2.4
run -b 'tmux bind -t vi-choice h tree-collapse 2> /dev/null || true'
run -b 'tmux bind -t vi-choice l tree-expand 2> /dev/null || true'
run -b 'tmux bind -t vi-choice K start-of-list 2> /dev/null || true'
run -b 'tmux bind -t vi-choice J end-of-list 2> /dev/null || true'
run -b 'tmux bind -t vi-choice H tree-collapse-all 2> /dev/null || true'
run -b 'tmux bind -t vi-choice L tree-expand-all 2> /dev/null || true'
run -b 'tmux bind -t vi-choice Escape cancel 2> /dev/null || true'


# -- edit mode (tmux < 2.4) ----------------------------------------------------

# vi-edit is gone in tmux >= 2.4
run -b 'tmux bind -ct vi-edit H start-of-line 2> /dev/null || true'
run -b 'tmux bind -ct vi-edit L end-of-line 2> /dev/null || true'
run -b 'tmux bind -ct vi-edit q cancel 2> /dev/null || true'
run -b 'tmux bind -ct vi-edit Escape cancel 2> /dev/null || true'


# -- copy mode -----------------------------------------------------------------

bind Enter copy-mode # enter copy mode

run -b 'tmux bind -t vi-copy v begin-selection 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi v send -X begin-selection 2> /dev/null || true'
run -b 'tmux bind -t vi-copy C-v rectangle-toggle 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi C-v send -X rectangle-toggle 2> /dev/null || true'
run -b 'tmux bind -t vi-copy y copy-selection 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi y send -X copy-selection-and-cancel 2> /dev/null || true'
run -b 'tmux bind -t vi-copy Escape cancel 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi Escape send -X cancel 2> /dev/null || true'
run -b 'tmux bind -t vi-copy H start-of-line 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi H send -X start-of-line 2> /dev/null || true'
run -b 'tmux bind -t vi-copy L end-of-line 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi L send -X end-of-line 2> /dev/null || true'

# copy to X11 clipboard
if -b 'command -v xsel > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xsel -i -b"'
if -b '! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xclip -i -selection clipboard >/dev/null 2>&1"'
# copy to macOS clipboard
if -b 'command -v pbcopy > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | pbcopy"'
if -b 'command -v reattach-to-user-namespace > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | reattach-to-user-namespace pbcopy"'
# copy to Windows clipboard
if -b 'command -v clip.exe > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | clip.exe"'
if -b '[ -c /dev/clipboard ]' 'bind y run -b "tmux save-buffer - > /dev/clipboard"'


# -- buffers -------------------------------------------------------------------

bind b list-buffers  # list paste buffers
bind p paste-buffer  # paste from the top paste buffer
bind P choose-buffer # choose which buffer to paste from


# -- user defined overrides ----------------------------------------------------

source -q ~/.tmux.conf.local


# -- 8< ------------------------------------------------------------------------

# run 'cut -c3- ~/.tmux.conf | sh -s _apply_configuration'

# -- windows & pane creation ---------------------------------------------------

# new window retains current path, possible values are:
#   - true
#   - false (default)
tmux_conf_new_window_retain_current_path=false

# new pane retains current path, possible values are:
#   - true (default)
#   - false
tmux_conf_new_pane_retain_current_path=true

# new pane tries to reconnect ssh sessions (experimental), possible values are:
#   - true
#   - false (default)
tmux_conf_new_pane_reconnect_ssh=false

# prompt for session name when creating a new session, possible values are:
#   - true
#   - false (default)
tmux_conf_new_session_prompt=false


# -- display -------------------------------------------------------------------

# RGB 24-bit colour support (tmux >= 2.2), possible values are:
#  - true
#  - false (default)
# set -g default-terminal "xterm-256color" # colors!
set -g default-terminal "tmux-256color" # colors!
tmux_conf_24b_colour=true

# default theme
#tmux_conf_theme_colour_1="#080808"    # dark gray
#tmux_conf_theme_colour_2="#303031"    # gray
#tmux_conf_theme_colour_3="#8a8a8a"    # light gray
#tmux_conf_theme_colour_4="#00afff"    # light blue
#tmux_conf_theme_colour_5="#ffff00"    # yellow
#tmux_conf_theme_colour_6="#080808"    # dark gray
#tmux_conf_theme_colour_7="#e4e4e4"    # white
#tmux_conf_theme_colour_8="#080808"    # dark gray
#tmux_conf_theme_colour_9="#ffff00"    # yellow
#tmux_conf_theme_colour_10="#ff00af"   # pink
#tmux_conf_theme_colour_11="#5fff00"   # green
#tmux_conf_theme_colour_12="#8a8a8a"   # light gray
#tmux_conf_theme_colour_13="#e4e4e4"   # white
#tmux_conf_theme_colour_14="#080808"   # dark gray
#tmux_conf_theme_colour_15="#080808"   # dark gray
#tmux_conf_theme_colour_16="#d70000"   # red
#tmux_conf_theme_colour_17="#e4e4e4"   # white

# gruvbox light
black="#3c3836"
gray="#bdae93"
light_gray="#ebdbb2"
blue="#076678"
red="#9d0006"
white="#fbf1c7"
yellow="#d79921"
purple="#8f3f71"
aqua="#427b58"

tmux_conf_theme_colour_1="$light_gray"
tmux_conf_theme_colour_2="$gray"
tmux_conf_theme_colour_3="$black"
tmux_conf_theme_colour_4="$blue"
tmux_conf_theme_colour_5="$yellow"
tmux_conf_theme_colour_6="$black"
tmux_conf_theme_colour_7="$white"
tmux_conf_theme_colour_8="$black"
tmux_conf_theme_colour_9="$yellow"
tmux_conf_theme_colour_10="$purple"
tmux_conf_theme_colour_11="$aqua"
tmux_conf_theme_colour_12="$white"
tmux_conf_theme_colour_13="$white"
tmux_conf_theme_colour_14="$black"
tmux_conf_theme_colour_15="$aqua"
tmux_conf_theme_colour_16="$red"
tmux_conf_theme_colour_17="$light_gray"

# default theme (ansi)
#tmux_conf_theme_colour_1="colour0"
#tmux_conf_theme_colour_2="colour8"
#tmux_conf_theme_colour_3="colour8"
#tmux_conf_theme_colour_4="colour14"
#tmux_conf_theme_colour_5="colour11"
#tmux_conf_theme_colour_6="colour0"
#tmux_conf_theme_colour_7="colour15"
#tmux_conf_theme_colour_8="colour0"
#tmux_conf_theme_colour_9="colour11"
#tmux_conf_theme_colour_10="colour13"
#tmux_conf_theme_colour_11="colour10"
#tmux_conf_theme_colour_12="colour8"
#tmux_conf_theme_colour_13="colour15"
#tmux_conf_theme_colour_14="colour0"
#tmux_conf_theme_colour_15="colour0"
#tmux_conf_theme_colour_16="colour1"
#tmux_conf_theme_colour_17="colour15"

# window style
tmux_conf_theme_window_fg="default"
tmux_conf_theme_window_bg="default"

# highlight focused pane (tmux >= 2.1), possible values are:
#   - true
#   - false (default)
tmux_conf_theme_highlight_focused_pane=false

# focused pane colours:
tmux_conf_theme_focused_pane_bg="$tmux_conf_theme_colour_2"

# pane border style, possible values are:
#   - thin (default)
#   - fat
tmux_conf_theme_pane_border_style=thin

# pane borders colours:
tmux_conf_theme_pane_border="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"

# pane indicator colours (when you hit <prefix> + q)
tmux_conf_theme_pane_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_pane_active_indicator="$tmux_conf_theme_colour_4"

# status line style
tmux_conf_theme_message_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_attr="bold"

# status line command style (<prefix> : Escape)
tmux_conf_theme_message_command_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_command_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_command_attr="bold"

# window modes style
tmux_conf_theme_mode_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_mode_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_mode_attr="bold"

# status line style
tmux_conf_theme_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_status_attr="none"

# terminal title
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_terminal_title="#h ❐ #S ● #I #W"

# window status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_attr="none"
tmux_conf_theme_window_status_format="#I #W"
#tmux_conf_theme_window_status_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_format="#I #W#{?window_bell_flag,🔔,}#{?window_zoomed_flag,🔍,}"

# window current status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_current_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_current_bg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_current_attr="bold"
tmux_conf_theme_window_status_current_format="#I #W"
#tmux_conf_theme_window_status_current_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_current_format="#I #W#{?window_zoomed_flag,🔍,}"

# window activity status style
tmux_conf_theme_window_status_activity_fg="default"
tmux_conf_theme_window_status_activity_bg="default"
tmux_conf_theme_window_status_activity_attr="underscore"

# window bell status style
tmux_conf_theme_window_status_bell_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_window_status_bell_bg="default"
tmux_conf_theme_window_status_bell_attr="blink,bold"

# window last status style
tmux_conf_theme_window_status_last_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_last_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_last_attr="none"

# status left/right sections separators
# tmux_conf_theme_left_separator_main=""
# tmux_conf_theme_left_separator_sub="|"
# tmux_conf_theme_right_separator_main=""
# tmux_conf_theme_right_separator_sub="|"
tmux_conf_theme_left_separator_main="#(printf \"\\uE0B0\")"  # /!\ you don't need to install Powerline
tmux_conf_theme_left_separator_sub="#(printf \"\\uE0B1\")"   #   you only need fonts patched with
tmux_conf_theme_right_separator_main="#(printf \"\\uE0B2\")" #   Powerline symbols or the standalone
tmux_conf_theme_right_separator_sub="#(printf \"\\uE0B3\")"  #   PowerlineSymbols.otf font, see README.md

# status left/right content:
#   - separate main sections with "|"
#   - separate subsections with ","
#   - built-in variables are:
#     - #{battery_bar}
#     - #{battery_hbar}
#     - #{battery_percentage}
#     - #{battery_status}
#     - #{battery_vbar}
#     - #{circled_session_name}
#     - #{hostname_ssh}
#     - #{hostname}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{loadavg}
#     - #{mouse}
#     - #{pairing}
#     - #{prefix}
#     - #{root}
#     - #{synchronized}
#     - #{uptime_y}
#     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
#     - #{uptime_h}
#     - #{uptime_m}
#     - #{uptime_s}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_status_left=" ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized} #{cpu_percentage} #{cpu_temp} #{ram_percentage}#{?battery_status, #{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage}, }| %R , %d %b | #{username}#{root}@#{hostname} "

# status left style
tmux_conf_theme_status_left_fg="$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_7,$tmux_conf_theme_colour_8"
tmux_conf_theme_status_left_bg="$tmux_conf_theme_colour_9,$tmux_conf_theme_colour_10,$tmux_conf_theme_colour_11"
tmux_conf_theme_status_left_attr="bold,none,none"

# status right style
tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_13,$tmux_conf_theme_colour_14"
tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_17"
tmux_conf_theme_status_right_attr="none,none,bold"

# pairing indicator
tmux_conf_theme_pairing="⚇"                 # U+2687
tmux_conf_theme_pairing_fg="none"
tmux_conf_theme_pairing_bg="none"
tmux_conf_theme_pairing_attr="none"

# prefix indicator
tmux_conf_theme_prefix="⌨"                  # U+2328
tmux_conf_theme_prefix_fg="none"
tmux_conf_theme_prefix_bg="none"
tmux_conf_theme_prefix_attr="none"

# mouse indicator
tmux_conf_theme_mouse="🐁"                   # U+D83D
tmux_conf_theme_mouse_fg="none"
tmux_conf_theme_mouse_bg="none"
tmux_conf_theme_mouse_attr="none"

# root indicator
tmux_conf_theme_root="!"
tmux_conf_theme_root_fg="none"
tmux_conf_theme_root_bg="none"
tmux_conf_theme_root_attr="bold,blink"

# synchronized indicator
tmux_conf_theme_synchronized="⚏"            # U+268F
tmux_conf_theme_synchronized_fg="none"
tmux_conf_theme_synchronized_bg="none"
tmux_conf_theme_synchronized_attr="none"

# battery bar symbols
tmux_conf_battery_bar_symbol_full="◼"
tmux_conf_battery_bar_symbol_empty="◻"
#tmux_conf_battery_bar_symbol_full="♥"
#tmux_conf_battery_bar_symbol_empty="·"

# battery bar length (in number of symbols), possible values are:
#   - auto
#   - a number, e.g. 5
tmux_conf_battery_bar_length="auto"

# battery bar palette, possible values are:
#   - gradient (default)
#   - heat
#   - "colour_full_fg,colour_empty_fg,colour_bg"
tmux_conf_battery_bar_palette="gradient"
#tmux_conf_battery_bar_palette="#d70000,#e4e4e4,#000000"   # red, white, black

# battery hbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - "colour_low,colour_half,colour_full"
tmux_conf_battery_hbar_palette="gradient"
#tmux_conf_battery_hbar_palette="#d70000,#ff5f00,#5fff00"  # red, orange, green

# battery vbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - "colour_low,colour_half,colour_full"
tmux_conf_battery_vbar_palette="gradient"
#tmux_conf_battery_vbar_palette="#d70000,#ff5f00,#5fff00"  # red, orange, green

# symbols used to indicate whether battery is charging or discharging
tmux_conf_battery_status_charging="↑"       # U+2191
tmux_conf_battery_status_discharging="↓"    # U+2193
#tmux_conf_battery_status_charging="🔌"     # U+1F50C
#tmux_conf_battery_status_discharging="🔋"  # U+1F50B

# clock style (when you hit <prefix> + t)
# you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
tmux_conf_theme_clock_colour="$tmux_conf_theme_colour_4"
tmux_conf_theme_clock_style="24"


# -- clipboard -----------------------------------------------------------------

# in copy mode, copying selection also copies to the OS clipboard
#   - true
#   - false (default)
# on macOS, this requires installing reattach-to-user-namespace, see README.md
# on Linux, this requires xsel or xclip
tmux_conf_copy_to_os_clipboard=true


# -- user customizations -------------------------------------------------------
# this is the place to override or undo settings

# increase history size
#set -g history-limit 10000

# start with mouse mode enabled
set -g mouse on

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
#set -g status-keys vi
#set -g mode-keys vi

# increase panes display time a bit more than the 800 default provided by oh-my-zsh
set -g display-panes-time 1000

# use C-q as tmux binding
set -gu prefix2
unbind C-a
unbind C-b
set -g prefix C-q                        # GNU-Screen compatible prefix
bind C-q send-prefix

# move status line to top
set -g status-position bottom

# other keybinding
bind | split-window -h

# -- tpm -----------------------------------------------------------------------

# while I don't use tpm myself, many people requested official support so here
# is a seamless integration that automatically installs plugins in parallel

# whenever a plugin introduces a variable to be used in 'status-left' or
# 'status-right', you can use it in 'tmux_conf_theme_status_left' and
# 'tmux_conf_theme_status_right' variables.

# by default, launching tmux will update tpm and all plugins
#   - true (default)
#   - false
tmux_conf_update_plugins_on_launch=true

# by default, reloading the configuration will update tpm and all plugins
#   - true (default)
#   - false
tmux_conf_update_plugins_on_reload=true

# /!\ do not add set -g @plugin 'tmux-plugins/tpm'
# /!\ do not add run '~/.tmux/plugins/tpm/tpm'

# to enable a plugin, use the 'set -g @plugin' syntax:
# visit https://github.com/tmux-plugins for available plugins
#set -g @plugin 'tmux-plugins/tmux-copycat'
set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @cpu_temp_unit 'F'
#set -g @plugin 'tmux-plugins/tmux-resurrect'
#set -g @plugin 'tmux-plugins/tmux-continuum'
#set -g @continuum-restore 'on'


# -- custom variables ----------------------------------------------------------

# to define a custom #{foo} variable, define a POSIX shell function between the
# '# EOF' and the '# "$@"' lines. Please note that the opening brace { character
# must be on the same line as the function name otherwise the parse won't detect
# it.
#
# then, use #{foo} in e.g. the 'tmux_conf_theme_status_left' or the
# 'tmux_conf_theme_status_right' variables.

# # /!\ do not remove the following line
# EOF
#
# weather() {
#   curl -m 1 wttr.in?format=3 2>/dev/null
#   sleep 900 # sleep for 15 minutes, throttle network requests whatever the value of status-interval
# }
#
# online() {
#   ping -c 1 1.1.1.1 >/dev/null 2>&1 && printf '✔' || printf '✘'
# }
#
# "$@"
# # /!\ do not remove the previous line
#
# ========= Vim <3 Tmux ============
#
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
| grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

is_fzf="ps -o state= -o comm= -t '#{pane_tty}' \
  | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?fzf$'"

bind -n C-h run "($is_vim && tmux send-keys C-h) || \
                          tmux select-pane -L"

bind -n C-j run "($is_vim && tmux send-keys C-j)  || \
                         ($is_fzf && tmux send-keys C-j) || \
                         tmux select-pane -D"

bind -n C-k run "($is_vim && tmux send-keys C-k) || \
                          ($is_fzf && tmux send-keys C-k)  || \
                          tmux select-pane -U"

bind -n C-l run  "($is_vim && tmux send-keys C-l) || \
                          tmux select-pane -R"
