#!/usr/bin/env bash
# [ NOTE ] => ref
# - https://blog.simos.info/running-x11-software-in-lxd-containers/

lxc profile create x11
cat x11.profile | lxc profile edit x11
lxc launch ubuntu:18.04 --profile default --profile x11 mycontainer
lxc exec mycontainer -- sudo --user ubuntu --login
# [ NOTE ] => tests

glxinfo -B
nvidia-smi
printenv PULSE_SERVER
export PULSE_SERVER="unix:/home/ubuntu/pulse-native"
pactl info
