# Homebrew
let-env PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin')
let-env PATH = ($env.PATH | split row (char esep) | prepend '/run/current-system/sw/bin/')
let-env PATH = ($env.PATH | split row (char esep) | append ([$env.HOME '.nix-profile/bin/'] | str join "/"))
let-env PATH = ($env.PATH | split row (char esep) | append "/usr/local/bin/")
