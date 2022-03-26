#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Error: You must provide a hardware layer as argument"
    exit 1
fi

#move into the scripts folder if you're not there already
cd scripts &>/dev/null

#move to the core folder
cd ../runtime/core

if [ "$1" == "blank_linux" ]; then
    echo "Activating Blank driver"
    cp ../hardware_layers/blank.cpp ./hardware_layer.cpp
    echo "Setting Platform"
    echo linux > ../../etc/openplc_platform
    echo blank_linux > ../../etc/openplc_driver
    
else
    echo "Error: Invalid hardware layer"
fi
