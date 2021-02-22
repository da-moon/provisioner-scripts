#!/usr/bin/env bash

scripts=(
"init"
"python"
"node"
"goenv"
"rust-toolchain"
"starship"
"ripgrep"
"nu"
"ansible"
"hashicorp"
"tfenv"
)
base="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
for i in "${scripts[@]}";do
wget "$base/$i"
bash $i
rm $i
done
