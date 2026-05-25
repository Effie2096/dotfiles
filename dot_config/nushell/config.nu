use std repeat

mkdir ($nu.data-dir | path join "vendor/autoload")

$env.EDITOR = "nvim"
$env.SHELL = "nu"

if (($env.HOME | path join ".secrets/codestats_key") | path exists) {
  $env.CODESTATS_KEY = open --raw ($env.HOME | path join .secrets/codestats_key)
}

if (($env.HOME | path join ".secrets/bw_session") | path exists) {
  $env.BW_SESSION = open --raw ($env.HOME | path join .secrets/bw_session)
}

$env.BAT_CONFIG_DIR = ($env.HOME | path join ".config/bat")
$env.YAZI_CONFIG_HOME = ($env.HOME | path join ".config/yazi")

const zoxide_path = $nu.data-dir | path join zoxide.nu
^zoxide init nushell | save $zoxide_path --force
source ($nu.data-dir | path join zoxide.nu)
const mise_path = $nu.data-dir | path join mise.nu
^mise activate nu | save $mise_path --force
use ($nu.data-dir | path join mise.nu)

const IS_WINDOWS = ($nu.os-info.name == "windows")

if not (which fnm | is-empty) {
  fnm env --json | from json | load-env
  $env.PATH = $env.PATH
  | prepend (
    $env.FNM_MULTISHELL_PATH | (if not $IS_WINDOWS { $in | path join 'bin' } else { $in }))
  $env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | append {
      condition: {|| ['.nvmrc' '.node-version'] | any {|el| $el | path exists}}
      code: {|| fnm use}
    }
  )
}

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

const plugins = [
  "polars",
  "query",
  "gstat"
]
$plugins | each {
  |plugin| plugin add $"nu_plugin_($plugin)(if $IS_WINDOWS {'.exe'})"
}

$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.PROMPT_INDICATOR = "󰅂"
$env.TRANSIENT_PROMPT_INDICATOR = "󰅂"
$env.PROMPT_INDICATOR_VI_NORMAL = "`"
$env.PROMPT_INDICATOR_VI_INSERT = " "
$env.PROMPT_MULTILINE_INDICATOR = ":::"

use ($nu.default-config-dir | path join prompt.nu) [
  dir_component
  duration_component
  status_component
  time_component
  git_component
]

$env.PROMPT_COMMAND = { ||
  [
    (ansi dark_gray_dimmed)
    ("─" | repeat (tput cols | into int) | str join)
    (ansi reset)
    (char newline)
    (char space)
    (dir_component)
    (git_component)
    (char newline)
    (ansi magenta_bold)
    (char space)
    $env.PROMPT_INDICATOR
    (ansi reset)
  ] | str join
}

$env.TRANSIENT_PROMPT_COMMAND = { ||
  let dir = dir_component
  [
    (char space)
    $dir
    (ansi magenta_bold)
    (char space)
    $env.TRANSIENT_PROMPT_INDICATOR
    (ansi reset)
  ] | str join
}

def prompt_right [] {
  [
    (duration_component)
    (
      if $env.LAST_EXIT_CODE != 0 {
        status_component
      }
    )
    (time_component)
    (char space)
  ] | str join
}

$env.PROMPT_COMMAND_RIGHT = ""
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| prompt_right }


def --wrapped scoop [...args] {
  if ($args | is-empty) {
    return (powershell scoop.ps1)
  }
  match $args.0 {
    "search" => { scoop-search.exe ...($args | skip 1) }
    _ => { powershell scoop.ps1 ...$args }
  }
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
source $"($nu.cache-dir)/carapace.nu"

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

def "nu-complete zoxide path" [context: string] {
  let parts = $context | split row " " | skip 1
  {
    options: {
      sort: false,
      completion_algorithm: substring,
      case_sensitive: false,
    },
    completions: (^zoxide query --list --exclude $env.PWD -- ...$parts | lines),
  }
}

def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
  __zoxide_z ...$rest
}

# Enable the external completer
$env.config.completions.external = {
  enable: true
  completer: $carapace_completer
}

# Load completions
source ./completions/komorebic-completions.nu


alias ll = ^eza --icons --color=always -GF -a --group-directories-first
alias la = ^eza --icons --color=always --long --classify --all --group-directories-first --group --header --git

def --wrapped v [...rest] {
  ^nvim ...$rest
}

def --wrapped ff [...args] {
  ^fzf -m --preview 'bat --style=numbers,header --decorations=always --color=always {}' --preview-window 'right,60%,border-left' ...$args
  | lines
  | reduce {|it, acc| $acc | append $it }
}

def --wrapped nuf [
  ...args
]: list<any> -> list<any>, table -> table, record -> record, string -> string {
  let input = $in

  match ($input | describe | str replace --regex '<.*' '') {
    "list" => {
      $input | str join "\n" | ^fzf ...$args | lines
    },
    _ => {
      $input | each {|i| $i | to json --raw}
      | str join "\n"
      | ^fzf ...$args
      | lines
      | each {$in | from json}
      | reduce {|it, acc| $acc | append $it}
    }
  }
}


def neovide --wrapped [...rest] { job spawn { ^neovide ...$rest } }

def --env y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  ^yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != $env.PWD and ($cwd | path exists) {
    cd $cwd
  }
  rm -fp $tmp
}

$env.config.keybindings ++= [{
  name: clear_term
  modifier: CONTROL
  keycode: Char_l
  mode: vi_insert
  event: [
    { send: ClearScreen }
    {
      send: executehostcommand,
      cmd: "tput cup (tput lines) 0"
    }
  ]
}]

if ($nu.is-interactive) {
  (^tput cup (^tput lines) 0)
  ^fastfetch
}
