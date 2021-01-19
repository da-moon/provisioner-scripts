# this script installs scoop and then installs some common tools
iwr -useb get.scoop.sh | iex
scoop install -g git
scoop bucket add extras
scoop install -g firefox
