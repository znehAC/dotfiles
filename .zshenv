typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.npm-global/bin"
  "/opt/cuda/bin"
  "/opt/cuda/nsight_compute"
  "/opt/cuda/nsight_systems/bin"
  "$HOME/.spicetify"
  $path
)
export PATH

export MICRO_TRUECOLOR=1
export MICRO_CLIPBOARD=external
