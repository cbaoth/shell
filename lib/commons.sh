# ~/lib/commons.sh: Common shell function library

# all functions are written in a way that they work on both, zsh and bash

# Author:   Andreas Weyer <dev@cbaoth.de>
# Keywords: zsh bash shell-script functions

# just in case thi script is re-loaded
typeset +r CL_SCRIPT_PATH CL_SCRIPT_FILE CL_TIMESTAMP_FORMAT
# constants
typeset -r CL_SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
typeset -r CL_SCRIPT_FILE="$(basename "$0")"
# used given date format for print/log messages
typeset -r CL_TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%S%z"  # full timestamp

# {{{ = LIBRARIES ============================================================
# include shell script library SCRIPT_FILE searching in:
# SCRIPT_PATH, SCRIPT_PATH/lib/, SCRIPT_PATH/../lib/, ~/lib/, /lib/, /usr/lib/
# if not fount, print error message (optionaly custom ERROR_MSG) and return 1
cl::include_lib() {
  if [[ -z "${2:-}" ]]; then
    printf "Usage: %s\n" "$(cl::func_name) SCRIPT_PATH SCRIPT_FILE [ERROR_MSG..]"
    return 1
  fi

  local -r script_path="$1"
  local -r script_file="$2"
  shift 2
  local -r error_message="${@:-}"

  if (( ${DEBUG_LVL:-0} >= 2 )) && [[ ! -d "${script_path}" ]]; then
    printf "DBG(2): SCRIPT_PATH [%s] not found" "${script_path}"
  fi

  if [[ -f "${script_path}/${script_file}" ]]; then
    source "${script_path}/${script_file}" || return 1
  elif [[ -f "${script_path}/lib/${script_file}" ]]; then
    source "${script_path}/lib/${script_file}" || return 1
  elif [[ -f "${script_path}/../lib/${script_file}" ]]; then
    source "${script_path}/../lib/${script_file}" || return 1
  elif [[ -f "$HOME/lib/${script_file}" ]]; then
    source "$HOME/lib/${script_file}" || return 1
  elif [[ -f "/lib/${script_file}" ]]; then
    source "/lib/${script_file}" || return 1
  elif [[ -f "/usr/lib/${script_file}" ]]; then
    source "/usr/${script_file}" || return 1
  else
    if [[ -n "${error_message}" ]]; then
      printf "%s\n" "${error_message}" >&2
    else
      printf "ERROR: Script [%s] not found in any known lib path\n" \
        "${script_file}" >&2
    fi
    return 1
  fi
  return 0
}

# include termfx.sh lib
#set -o allexport
#if ! cl::include_lib "${CL_SCRIPT_PATH}" termfx.sh \
#       "WARNING: Script [termfx.sh] not found, text effects disabled"; then
#  cl::fx() { :; } # implement dummy method so everygint still works
#fi
#set +o allexport
# }}} = LIBRARIES ============================================================


# {{{ = TEXT FX ==============================================================
declare -A +r FX_MAP  # +r just in case this cript is re-loaded, see -r below
# foreground colors
FX_MAP[black]="$(tput setaf 0)"
FX_MAP[red]="$(tput setaf 1)"
FX_MAP[green]="$(tput setaf 2)"
FX_MAP[yellow]="$(tput setaf 3)"
FX_MAP[blue]="$(tput setaf 4)"
FX_MAP[magnta]="$(tput setaf 5)"
FX_MAP[cyan]="$(tput setaf 6)"
FX_MAP[white]="$(tput setaf 7)"
FX_MAP[black+]="$(tput setaf 8)"
FX_MAP[red+]="$(tput setaf 9)"
FX_MAP[green+]="$(tput setaf 10)"
FX_MAP[yellow+]="$(tput setaf 11)"
FX_MAP[blue+]="$(tput setaf 12)"
FX_MAP[magnta+]="$(tput setaf 13)"
FX_MAP[cyan+]="$(tput setaf 14)"
FX_MAP[white+]="$(tput setaf 15)"
# backgrud colors
FX_MAP[b_black]="$(tput setab 0)"
FX_MAP[b_red]="$(tput setab 1)"
FX_MAP[b_green]="$(tput setab 2)"
FX_MAP[b_yellow]="$(tput setab 3)"
FX_MAP[b_blue]="$(tput setab 4)"
FX_MAP[b_magnta]="$(tput setab 5)"
FX_MAP[b_cyan]="$(tput setab 6)"
FX_MAP[b_white]="$(tput setab 7)"
FX_MAP[b_black+]="$(tput setab 8)"
FX_MAP[b_red+]="$(tput setab 9)"
FX_MAP[b_green+]="$(tput setab 10)"
FX_MAP[b_yellow+]="$(tput setab 11)"
FX_MAP[b_blue+]="$(tput setab 12)"
FX_MAP[b_magnta+]="$(tput setab 13)"
FX_MAP[b_cyan+]="$(tput setab 14)"
FX_MAP[b_white+]="$(tput setab 15)"
# text effects
FX_MAP[b]="$(tput bold)" # bold
FX_MAP[d]="$(tput dim)" # dim
FX_MAP[u]="$(tput smul)" # underline
FX_MAP[u-]="$(tput rmul)" # underline off
FX_MAP[i]="$(tput rev)" # reversed
FX_MAP[s]="$(tput smso)" # standout
FX_MAP[s-]="$(tput rmso)" # standout off
FX_MAP[r]="$(tput sgr0)" # reset
# bad practice (thus oftentimes not supported)
FX_MAP[blink]="$(tput blink)"
FX_MAP[invisible]="$(tput invis)"
declare -r FX_MAP

# convenient way to set one or more terimnal text effects at once
cl::fx() {
  local -r _usage="cl::fx STYLE.."
  local _help
  ! IFS='' read -r -d '' _help <<EOF
Usage: $_usage

Styles:
  Text Colors (0-7):
    black, red, green, yellow, blue, magenta, cyan, white

  Text Colors Light (8-15):
    black+, red+, green+, yellow+, blue+, magenta+, cyan+, white+

  Background Colors (0-7):
    b_black, b_red, b_green, b_yellow, b_blue, b_magenta, b_cyan,
    b_white

  Background Colors Light (8-15):
    b_black+, b_red+, b_green+, b_yellow+, b_blue+, b_magenta+,
    b_cyan+, b_white+

  Text Effects:
    b    bold
    d    dim
    u    underline start
    u-   underline stop
    i    reversed (invert back and foreground color)
    s    standout start
    s-   standout stop
    r    reset styles (set default style)

  Others (considered bad practice, oftentimes not supported):
    blink, invisible

Example:
  printf "%%sERROR:%%s %%sunderlined%%s back to normal\\\\n" \\
    "\$(cl::fx b red+ b_white+)" \\
    "\$(cl::fx r)" \\
    "\$(cl::fx b u red)" \\
    "\$(cl::fx r)"
EOF
  local -r _help

  # parse arguments
  if [[ -z "${1:-}" ]]; then
    printf "Usage: %s\n" "${$_usage}"
    return 1
  fi
  if [[ "$1" =~ ^(-h|--help)$ ]]; then
    printf "${_help}"
    return 0
  fi

  # process arguments
  for s in "$@"; do
    printf "%s" "${FX_MAP[$s]}"
  done
}

# execute multiple tput commands at once, ignore and return gracefully if tput
# not available
cl::tputs() {
  if [[ -z "${1:-}" ]]; then
    printf "Usage: cl::tputs STYLE.."
    return 1
  fi
  if ! command -v tput >& /dev/null; then
    return 0  # tput command not found
  fi

  # send individual commands to tput
  #paste -sd "\n" - <<<"$@"
  IFS=$'\n' printf "%s\n" "$@"  | tput -S
}

# print 256-color table
cl::color_table() {
  for i in {0..255}; do
    printf '\e[1m\e[37m\e[48;5;%dm%03d\e[0m ' "$i" "$i"
    if (( i >= 16 )) && (( $(( i % 6 )) == 3 )) || (( i == 15 )); then
      printf '\n'
    fi
  done
}
# }}} = TEXT FX ==============================================================


# {{{ = FUNC FUNCTIONS =======================================================
# get function name (for bash and zsh)
cl::func_name() {
  printf "%s" "${FUNCNAME[1]-${funcstack[2]}}"
}

# get function caller name (for bash and zsh)
cl::func_caller() {
  printf "%s" "${FUNCNAME[2]-${funcstack[3]}}"
}
# }}} = FUNC FUNCTIONS =======================================================

# {{{ = PRINT FUNCTONS =======================================================
# print usage in format: "Usage: USAGE.."
# alternative: ${1?"Usage: $0 [msg]"} (but less nice)
cl::p_usg() {
  if [[ -z "${1:-}" ]]; then
    printf "Usage: %s\n" "$(cl::func_name) USAGE.."
    return 1
  fi

  printf "Usage: %s\n" "$@"
}

# print an info message in format: "> MSG.."
cl::p_msg() {
  if [[ -z "${1:-}" ]]; then
    cl::p_usg "$(cl::func_name) MSG.."
    return 1
  fi

  printf "> %s\n" "$@"
}

# print error message in format "> ERROR : [msg]..", Usage: p_err [msg]
cl::p_err() {
  local timestamp
  # timestamp option set?
  if [[ -n "${1:-}" && "$1" =~ (-t|--timestamp) ]]; then
    timestamp=${CL_TIMESTAMP_FORMAT:+"$(date +"${CL_TIMESTAMP_FORMAT}")"}
    shift
  fi
  readonly timestamp
  # sufficient arguments?
  if [[ -z "${1:-}" ]]; then
    cl::p_usg "$(cl::func_name) [-t|--timestamp] MSG.."
    return 1
  fi

  # print error message
  printf "%s%sERROR:%s %s%s%s\n" \
    "${timestamp:+${timestamp} }" "$(cl::fx white b_red b)" \
    "$(cl::fx r)" "$(cl::fx u)" \
    "$@" "$(cl::fx r)" >&2
}

# print error message in format "> WARNING: [msg]..", Usage: p_war [msg]
cl::p_war() {
  local timestamp
  # timestamp option set?
  if [[ -n "${1:-}" && "$1" =~ (-t|--timestamp) ]]; then
    timestamp=${CL_TIMESTAMP_FORMAT:+"$(date +"${CL_TIMESTAMP_FORMAT}")"}
    shift
  fi
  readonly timestamp
  # sufficient arguments?
  if [[ -z "${1:-}" ]]; then
    echo "cl::p_war [-t|--timestamp] MSG.."
    return 1
  fi

  # print warning message
  printf "%s%sWARNING:%s %s\n" \
    "${timestamp:+${timestamp} }" "$(cl::fx black b_yellow)" \
    "$(cl::fx r)" "$@"
}

# print debug message in format "> DEBUG({lvl}): [msg].."
# env DEBUG_LVL supercedes [dbg_lvl] (first arg.) if DEBUG_LVL > dbg_lvl
# set dbg_lvl to 0 if DEBUG_LVL should be used exclusively
cl::p_dbg() {
  local timestamp
  # timestamp option set?
  if [[ -n "${1:-}" && "$1" =~ (-t|--timestamp) ]]; then
    timestamp=${CL_TIMESTAMP_FORMAT:+"$(date +"${CL_TIMESTAMP_FORMAT}")"}
    shift
  fi
  readonly timestamp
  # sufficient arguments?
  if [[ -z "$3" ]]; then
    echo "Usage: cl::p_dbg [-t|--timestamp] DBG_LVL SHOW_AT_LVL MSG.."
    return 1
  fi
  # parse arguments
  local dbg_lvl="$(( ${DEBUG_LVL:-0} > $1 ? ${DEBUG_LVL:-0} : $1 ))"
  shift
  local show_at_lvl=$1
  shift
  (( $dbg_lvl < $show_at_lvl )) \
    && return 0

  # print debug message
  printf "%s%sDEBUG(%s):%s %s\n" \
    "${timestamp:+${timestamp} }" "$(cl::fx black b_cyan)" "${show_at_lvl}" \
    "$(cl::fx r)" "$@"
}

# print 'yes' in green color
cl::p_yes() {
  # zsh: print -P "%F{green}yes%f"
  printf "%syes%s" "$(cl::fx green)" "$(cl::fx r)"
}

# print 'no' in red color
cl::p_no() {
  # zsh: print -P "%F{red}no%f"
  printf "%sno%s" "$(cl::fx red)" "$(cl::fx r)"
}
# }}} = PRINT FUNCTONS =======================================================

# {{{ = ARRAY ================================================================
# join array by delimiter (on zsh ${(j:/:)1} can be used instead)
# example: join_by / 1 '2 a' 3 4 -> 1/2 a/3/4
cl::join_by() {
  if [[ -z "${2:-}" ]]; then
    cl::p_usg "$(cl::func_name) DELIMITER ARRAY.."
    return 1
  fi

  local delimiter="$1"
  local first="$2"
  shift 2
  printf "%s%s" "$first" "${@/#/$delimiter}"
}

# join array by newlines
# example: join_by_n / 1 '2 a' 3 4 -> 1\n2 a\n3\n4\n
cl::join_by_n() {
  if [[ -z "${2:-}" ]]; then
    cl::p_usg "$(cl::func_name) ARRAY.."
    return 1
  fi

  IFS=$'\n' printf "%s\n" "$@"
}
# {{{ = ARRAY ================================================================

# {{{ = PREDICATES ===========================================================
# predicate: is current shell zsh?
cl::is_zsh() {
  [[ "$SHELL" = *zsh ]]
}

# predicate: is current shell bash?
cl::is_bash() {
  [[ "$SHELL" = *bash ]]
}

# predicate: is current user superuse?
cl::is_su() {
  (( UID == 0 && EUID == 0 ))
}

# predicate: is this a sudo envionment?
cl::is_sudo() {
  [[ -n "$SUDO_USER" ]]
}

# predicate: is
cl::is_sudo_cached() {
  sudo -n true 2> /dev/null
}

# predicate: is this a ssh session we are in?
cl::is_ssh() {
  [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]
}

# predicate: is CMD available?
# why not use which? https://stackoverflow.com/a/677212/7393995
cl::cmd_p() {
  if [[ -z "${1:-}" ]]; then
    cl::p_usg "$(cl::func_name) CMD"
    return 1
  fi

  command -v "$1" >& /dev/null \
    && return 0
  return 1
}

# predicate: is given [number] an integer?
# number may NOT contain decimal separator "."
cl::is_int() {
  if [[ -z "$1" ]]; then
     cl::cl::p_usg "$(cl::func_name) NUMBER.."
     return 1
  fi
  for n in "$@"; do
    [[ "$n" =~ ^\ *[+-]?[0-9]+\ *$ ]] || return 1
    shift
  done
  return 0
}

# predicate: is given [number] a decimal number?
# number MUST contain decimal separator "." (optional, scale can be 0)
cl::is_decimal() {
  if [[ -z "$1" ]]; then
    cl::p_usg "$(cl::func_name) NUMBER.."
    return 1
  fi
  for n in "$@"; do
    [[ "$n" =~ ^\ *[+-]?([0-9]*[.][0-9]+|[0-9]+[.][0-9]*)\ *$ ]] \
      || return 1
    shift
  done
  return 0
}

# predicate: is given [number] positive?
# number MAY contain decimal separator "." (optional, can be integer)
cl::is_positive() {
  if [[ -z "$1" ]]; then
    cl::p_usg "$(cl::func_name) NUMBER.."
    return 1
  fi
  for n in "$@"; do
    [[ ! "$n" =~ ^\ *- ]] \
      || return 1
    shift
  done
  return 0
}

# predicate: is given [value] a number? (either integer or decimal)
# number MAY contain decimal separator "." (optional, scale can be 0)
cl::is_number() { # may contain .
  if [[ -z "$1" ]]; then
    cl::p_usg "$(cl::func_name) NUMBER.."
    return 1
  fi
  for n in "$@"; do
    [[ "$n" =~ ^\ *[+-]?([0-9]+|[0-9]*[.][0-9]+|[0-9]+[.][0-9]*)\ *$ ]] \
      || return 1
    shift
  done
  return 0
}
# }}} = PREDICATES ===========================================================

# {{{ = COMMAND EXECUTION ====================================================
# execute command [cmd] with a [delay] (sleep syntax)
cl::cmd_delay() {
  if [[ -z "${2:-}" ]]; then
    cl::p_usg "$(cl::func_name) DELAY COMMAND.."
    return 1
  fi

  local delay="$1"; shift
  sleep "$delay"
  "$@"
}
# }}} = COMMAND EXECUTION ====================================================

# {{{ = QUERIES ==============================================================
# query (yes/no): ask any question (no: return 1)
cl::q_yesno() {
  if [[ -z "${1:-}" ]]; then
    cl::p_usg "$(cl::func_name) QUESTION"
    return 1
  fi

  local -r sh="$(basename "$SHELL")"
  local question="$@"
  local key=""
  printf "%s (y/n) " "$question"
  while [[ "$key" != "y" ]] && [[ "$key" != "n" ]]; do
    if [[ "$sh" = "zsh" ]]; then
      read -s -k 1 key
    else
      read -s -n 1 key
    fi
  done
  printf "\n"
  if [[ "$key" = "y" ]]; then
    return 0
  fi
  return 1
}

# query (yes/no): overwrite given file? (no: return 1)
# return 0, without asking a thing, if [file] doesn't exist
cl::q_overwrite() {
  if [[ -z "$1" ]]; then
    cl::p_usg "$(cl::func_name) file"
    return 1
  fi

  local file="$1"
  if [[ -e "$file" ]]; then
    cl::p_war "file [$file] exists!"
    if cl::q_yesno "overwrite?"; then
      if ! rm -rf -- "$file"; then
        p_err "unable to delete the file!"
        return 1
      fi
      return 0
    fi
    return 1
  fi
  return 0
}
# }}} = QUERIES ==============================================================

# {{{ = PYTHON ===============================================================
# execute python3's print function with the given [code] argument(s)
# examples:
#   py_print "192,168,0,1,sep='.'"
#   py_print -i math "'SQRT({0}) = {1}'.format(1.3, math.sqrt(1.3))"
cl::py_print() {
  if [[ -z "$1" ]]; then
    cl::p_usg "$(cl::func_name) [-i IMPORT] PY_CODE.."
    return 1
  fi

  local py_import
  if [[ "$1" =~ ^(-i|--import)$ ]]; then
    if [[ -z "$2" ]]; then
      cl::p_err "missing value for argument [-i]"
      return 1
    fi
    py_import="$2"
    shift 2
  fi

  # print arguments via python print
  python3<<<"${py_import+import ${py_import}}
print($@)"
}
# }}} = PYTHON ===============================================================