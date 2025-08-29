# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.XDG_CONFIG_HOME = ($env.HOME | path join .config)
$env.XDG_DATA_HOME = ($env.HOME | path join .local/share)
$env.XDG_CACHE_HOME = ($env.HOME | path join .cache)
$env.XDG_STATE_HOME = ($env.HOME | path join .local/state)

$env.BAT_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join bat)
$env.YAZI_CONFIG_HOME = ($env.XDG_CONFIG_HOME | path join yazi)

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

const plugins = [
	"gstat",
	"query"
]
$plugins | each {
	|plugin| plugin add $"nu_plugin_($plugin)(if $nu.os-info.name == 'windows' {'.exe'})"
}

# $env.CURRENT_THEME = "light"
def set-theme-based-on-time [] {
	let now = (date now)
	# let last_check = ($env.LAST_THEME_CHECK? | default ($now - 10min))
	#
	# if ($now - $last_check) > 5min {
		# $env.LAST_THEME_CHECK = $now

		let hour = ($now | format date "%H" | into int)
		let new_theme = if $hour >= 7 and $hour < 20 { "light" } else { "dark" }

		if $env.CURRENT_THEME? != $new_theme {
			if $new_theme == "light" {
				source ~/.config/nushell/themes/catppuccin_latte.nu
				open ($env.XDG_CONFIG_HOME
					| path join starship.toml)
				| update palette "catppuccin_latte"
				| save --force ($env.XDG_CONFIG_HOME
					| path join starship.toml)
			} else {
				source ~/.config/nushell/themes/catppuccin_mocha.nu
				open ($env.XDG_CONFIG_HOME
					| path join starship.toml)
				| update palette "catppuccin_mocha"
				| save --force ($env.XDG_CONFIG_HOME
					| path join starship.toml)
			}
			$env.CURRENT_THEME = $new_theme
		}
	# }
}
set-theme-based-on-time

$env.STARSHIP_SHELL = "nu"
$env.EDITOR = "nvim"

$env.CODESTATS_KEY = open --raw ($env.HOME | path join .secrets/codestats_key)

$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.PROMPT_INDICATOR_VI_NORMAL = "`"
$env.PROMPT_INDICATOR_VI_INSERT = " "
$env.PROMPT_MULTILINE_INDICATOR = ":::"

mkdir ($nu.data-dir | path join "vendor/autoload")

def --wrapped scoop [...args] {
	if ($args | is-empty) {
		return (powershell scoop.ps1)
	}
	match $args.0 {
		"search" => { scoop-search.exe ...($args | skip 1) }
		_ => { powershell scoop.ps1 ...$args }
	}
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ($env.XDG_CACHE_HOME | path join carapace)
carapace _carapace nushell | save --force ($env.XDG_CACHE_HOME | path join carapace/init.nu)
source ~/.cache/carapace/init.nu

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

# Enable the external completer
$env.config.completions.external = {
  enable: true
  completer: $carapace_completer
}

# Load completions
source ~/.config/nushell/completions/komorebic-completions.nu

$env.config.render_right_prompt_on_last_line = true
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.starship_prompt_command = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = {
    set-theme-based-on-time
    do $env.starship_prompt_command
}
$env.TRANSIENT_PROMPT_COMMAND = {||
	$" (starship module directory)(starship module character)"
}
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {||
 $"(starship module status --status $env.LAST_EXIT_CODE)(starship module cmd_duration --cmd-duration $env.CMD_DURATION_MS)(starship module time)"
}

zoxide init nushell --cmd cd | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

alias ll = eza --icons --color=always -GF -a --group-directories-first
alias la = eza --icons --color=always --long --classify --all --group-directories-first --group --header --git

alias bat = bat --theme=$"(if $env.CURRENT_THEME == 'light' { 'Catppuccin Latte' } else { 'Catppuccin Mocha' })"

alias dots = git --git-dir=$"($env.XDG_DATA_HOME | path join chezmoi)"

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

tput cup (tput lines) 0
fastfetch
