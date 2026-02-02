# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

let zoxide_path = $nu.data-dir | path join zoxide.nu
zoxide init nushell | save $zoxide_path --force

let mise_path = $nu.data-dir | path join mise.nu
^mise activate nu | save $mise_path --force
