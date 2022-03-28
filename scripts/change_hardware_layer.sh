#!/bin/sh -ae
if [ $# -eq 0 ]; then
    echo "Error: You must provide a hardware layer as argument"
    exit 1
fi

. $(dirname "$(readlink -f "$0")")/env

if [ "$1" == "blank_linux" ]; then
    echo "Activating Blank driver"
    cp $PREFIX/runtime/hardware_layers/blank.cpp \
       $PREFIX/runtime/core/hardware_layer.cpp

    echo "Setting Platform"
    sed -e "s/OPENPLC_PLATFORM.*/OPENPLC_PLATFORM=linux/" \
        -e "s/OPENPLC_DRIVER.*/OPENPLC_DRIVER=blank_linux/" \
        -i $PREFIX/scripts/env
    echo blank_linux > $PREFIX/etc/openplc_driver

else
    echo "Error: Invalid hardware layer"
fi
