if status is-interactive
  set -x CLICOLOR "yes"
  set fish_greeting ""

  alias bat batcat
  alias l 'batcat'
  alias ls 'ls --color=always --group-directories-first -xhF'
  alias la 'ls -a'
  alias ll 'ls -l'

  alias crr 'cargo run --release'
  alias cbr 'cargo build --release'
  alias ctr 'cargo test --release'

  fish_vi_key_bindings
end
