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
    selinux="enforce" # enforce (chad) / permissive (yuck)

## [Image/Zip Configs]
    todo="todo"

# [Stupid Variables Something]
    export arch="arm64" 
    export subarch="arm64"
    export ANDROID_MAJOR_VERSION=q # Q, R, S, T, U
    export ScriptDebugger=disabled # enabled/disabled, logs shit happening during script runtime

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
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: disabled device A"
        fi
        export conf_a="Device Disabled"
    fi

    if [[ $device_b == "disabled" ]]; then
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: disabled device B"
        fi
        export conf_b="Device Disabled"
    fi

    if [[ $device_c == "disabled" ]]; then
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: disabled device C"
        fi
        export conf_c="Device Disabled"
    fi

    if [[ $device_d == "disabled" ]]; then
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: disabled device D"
        fi
        export conf_d="Device Disabled"
    fi

    if [[ $device_e == "disabled" ]]; then
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: disabled device E"
        fi
        export conf_e="Device Disabled"
    fi

    if [ -n "${LLVM+x}" ]; then
        echo "Fatal: LLVM enabled, please start script in a clean env"
        exit 1 > /dev/null 2>&1
    else
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: LLVM not detected, continue script."
        fi
    fi

# [Backend]
    build() {
        if [[ "$1" == "ksu" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: enabled KernelSU"
            fi
            export ksu="enabled"
        elif [[ "$1" == "vanilla" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: disabled KernelSU"
            fi
            export ksu="disabled"
        else
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: KernelSU defaults to $ksu"
            fi
        fi

        if [[ "$ksu" == "disabled" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: setting kernel name to $name"
            fi
            export LOCALVERSION="-$name"
        elif [[ "$ksu" == "enabled" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: setting kernel name to $name-KernelSU"
            fi
            export LOCALVERSION="-$name-KernelSU"
        else
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: setting kernel name to $name"
            fi
            export LOCALVERSION="-$name"
        fi

        if [[ "$1" == "sudo" ]]; then
            sudo make build -j$(nproc) # Building with Sudo is only gonna cause trouble, I put this here because it is a inside joke.
        else
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: start build process"
            fi
            echo "Warning: disable CONFIG_LTO_CLANG in your defconfig if its enabled"     
            make build -j$(nproc)      # <- This is the halal way to build the Linux Kernel
        fi
    } # Used to set kernel name and build it

    genconf_temp() {
        if [[ "$ScriptDebugger" == "enabled" ]]; then
            echo "Debugger: genconf_temp: stage 1: garbage old temp_defconfig"
            echo "Debugger: genconf_temp: stage 2: create empty temp_defconfig"
        fi
        rm "$conf_dir/temp_defconfig" > /dev/null 2>&1
        touch "$conf_dir/temp_defconfig"
        
        cat "$selected" >> "$conf_dir/temp_defconfig"

        if [[ "$base_defconfig" != "undefined" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf_temp: insert device defconfig into temp_defconfig"
            fi
            cat "$base_defconfig" >> "$conf_dir/temp_defconfig"
        fi

        if [[ "$ext_defconfig" != "undefined" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf_temp: insert extra defconfig into temp_defconfig"
            fi
            cat "$ext_defconfig" >> "$conf_dir/temp_defconfig"
        fi

        if [[ "$regio_defconfig" != "undefined" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf_temp: insert regio defconfig into temp_defconfig"
            fi
            cat "$regio_defconfig" >> "$conf_dir/temp_defconfig"
        fi
    } # Used to generate a custom defconfig based off 2 or more defconfigs

    append_kernelsu() {
        if [[ "$ksu" == "enabled" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: building KernelSU kernel"
            fi
            echo "CONFIG_KSU=y" >> "$conf_dir/temp_defconfig"
        else
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: building Vanilla kernel"
            fi
        fi
    }

    append_selinux() {
        if [[ "$selinux" == "permissive" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: Building Selinux Permissive Kernel"
            fi
            echo "CONFIG_ALWAYS_PERMISSIVE=y" >> "$conf_dir/temp_defconfig"
        elif [[ "$selinux" == "enforce" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: Building Selinux Enforce Kernel"
                # Echoing to temp_defconfig not needed because kernel with patched selinux will build with enforce unless CONFIG_ALWAYS_PERMISSIVE is enabled
            fi
        fi
    }

    genconf() {
        if [[ "$arch" == "arm64" && "$selected" != "Device Disabled" && "$ext_defconfig" == "undefined" && "$base_defconfig" == "undefined" && "$regio_defconfig" == "undefined" ]]; then
            genconf_temp && append_selinux && append_kernelsu
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf: make non-split defconfig"
            fi
            make "$conf_dir/temp_defconfig"
        elif [[ "$arch" == "arm64" && "$selected" != "Device Disabled"]]; then
            genconf_temp && append_selinux && append_kernelsu
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf: make split defconfig"
            fi
            make "$conf_dir/temp_defconfig"
        elif [[ "$arch" == "x86" ]]; then
            if [[ "$ScriptDebugger" == "enabled" ]]; then
                echo "Debugger: genconf: make x86 defconfig via menuconfig"
            fi
            make menuconfig
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

