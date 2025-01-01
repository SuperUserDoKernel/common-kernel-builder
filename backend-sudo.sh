#!/bin/bash
# 
# This script is licensed under the GNU General Public License version 2.
# 
# Copyright (C) 2024 SuperUserDoKernel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# [Generic Configs]
    name="Sudo" # Kernel Name
    device_a="rosemary" 
    device_b="disabled" # unused slots shoud be set to "disabled"
    device_c="disabled" # :
    device_d="disabled" # :
    device_e="disabled" # :
    soc="SudoPower" # You can put anything here
    ksu="disabled" # disabled/enabled

## [Image/Zip Configs]
    todo="todo"

# [Stupid Variables Something]
    export arch="arm64" 
    export subarch="arm64"
    export ANDROID_MAJOR_VERSION=q # Q, R, S, T, U

# [Defconfig Paths] Replace device_defconfig with the name of your standalone or otherwise split defconfig specific to your device.
    pwd="$(pwd)" # Presumably Kernel Workdir
    conf_dir="$pwd/arch/$arch/configs/"
    conf_a="$conf_dir/device_defconfig"
    conf_b="$conf_dir/device_defconfig"
    conf_c="$conf_dir/device_defconfig"
    conf_d="$conf_dir/device_defconfig"
    conf_e="$conf_dir/device_defconfig"

# [Some Misc Stuff]
    base_defconfig="$conf_dir/undefined" # Set to undefined to disable
    ext_defconfig="$conf_dir/underfined" # Set to undefined to disable merging of custom defconfig, otherwise specify filename of it.
    regio_defconfig="$conf_dir/undefined" # on my kernel is either eur_defconfig or kor_defconfig, set to undefined to disable.
    out_dtb="$pwd/arch/$arch/boot/dtb.img"

# [GCC Configs]
    export CC="aarch64-linux-gnu-" 
    export LD="ld.gold"

# [Placeholders]
    selected="$conf_a"          # Placeholder
    device_selected="$device_a" # : ^^^

# [Init Scripts]
if [[ $device_a == "disabled" ]]; then
    export conf_a="Device Disabled"
elif [[ $device_b == "disabled" ]]; then
    export conf_b="Device Disabled"
elif [[ $device_c == "disabled" ]]; then
    export conf_c="Device Disabled"
elif [[ $device_d == "disabled" ]]; then
    export conf_d="Device Disabled"
elif [[ $device_e == "disabled" ]]; then
    export conf_e="Device Disabled"
fi

# [Functions]
build() {
    if [[ "$ksu" == "disabled" ]]; then
        export LOCALVERSION="-$name"
    elif
        export LOCALVERSION="-$name-KernelSU"
    else
        export LOCALVERSION="-$name"
    fi

    if [[ "$1" == "sudo" ]]; then
        sudo make build -j$(nproc) # Building with Sudo is only gonna cause trouble, I put this here because it is a inside joke.
    else       
        echo "Warning: disable CONFIG_LTO_CLANG in your defconfig if its enabled"     
        make build -j$(nproc)      # <- This is the halal way to build the Linux Kernel
    fi
} # Used to set kernel name and build it

genconf_temp() {
    rm "$conf_dir/temp_defconfig" > /dev/null 2>&1
    touch "$conf_dir/temp_defconfig"
    
    cat "$selected" >> "$conf_dir/temp_defconfig"

    if [[ "$base_defconfig" != "undefined" ]]; then
        cat "$base_defconfig" >> "$conf_dir/temp_defconfig"
    fi

    if [[ "$ext_defconfig" != "undefined" ]]; then
        cat "$ext_defconfig" >> "$conf_dir/temp_defconfig"
    fi

     if [[ "$regio_defconfig" != "undefined" ]]; then
        cat "$regio_defconfig" >> "$conf_dir/temp_defconfig"
     fi
} # Used to generate a custom defconfig based off 2 or more defconfigs

genconf() {
    if [[ "$arch" == "arm64" && "$selected" != "Device Disabled" && "$ext_defconfig" == "undefined" && "$base_defconfig" == "undefined" && "$regio_defconfig" == "undefined" ]]; then
        make $selected
    elif [[ "$arch" == "arm64" && "$selected" != "Device Disabled"]]; then
        genconf_temp
        make "$conf_dir/temp_defconfig"
    fi
} # Used to make defconfig

clean() {
    if [[ "$1" == "simple" ]]; then
        echo "Sudo: cleaning directory"
        make clean
    elif [[ "$1" == "advanced" ]]; then
        echo "Sudo: cleaning directory in depth"
        make clean && make mrproper
    else
        echo "Sudo: cleaning directory"
        make clean
    fi 
} # Used for cleaning Linux work directory

