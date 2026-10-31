#!/usr/bin/env bash

set -eu

PWD=$(pwd)
TIMESTAMP="${TIMESTAMP:-$(date -u +"%Y%m%d%H%M")}"
COMMIT="${COMMIT:-$(echo xxxxxx)}"

# West Build (left)
west build -s zmk/app -p -d build/left -b adv360_left -S studio-rpc-usb-uart -- -DZMK_CONFIG="${PWD}/config" -DCONFIG_ZMK_STUDIO=y
# Adv360 Left Kconfig file
grep -vE '(^#|^$)' build/left/zephyr/.config
# Rename zmk.uf2
cp build/left/zephyr/zmk.uf2 "./firmware/${TIMESTAMP}-${COMMIT}-left-clique.uf2"

# Build right side if selected
if [ "${BUILD_RIGHT}" = true ]; then
    # West Build (right)
    west build -s zmk/app -p -d build/right -b adv360_right -- -DZMK_CONFIG="${PWD}/config"
    # Adv360 Right Kconfig file
    grep -vE '(^#|^$)' build/right/zephyr/.config
    # Rename zmk.uf2
    cp build/right/zephyr/zmk.uf2 "./firmware/${TIMESTAMP}-${COMMIT}-right-clique.uf2"
fi

# Build dongle (Adafruit nRF52840 USB Key as BLE central) if selected
if [ "${BUILD_DONGLE:-true}" = true ]; then
    # West Build (dongle)
    west build -s zmk/app -p -d build/dongle -b nrf52840_usb_key -S studio-rpc-usb-uart -- -DSHIELD=dongle -DZMK_CONFIG="${PWD}/config" -DCONFIG_ZMK_STUDIO=y
    # Dongle Kconfig file
    grep -vE '(^#|^$)' build/dongle/zephyr/.config
    # Rename zmk.uf2
    cp build/dongle/zephyr/zmk.uf2 "./firmware/${TIMESTAMP}-${COMMIT}-dongle-clique.uf2"
fi
