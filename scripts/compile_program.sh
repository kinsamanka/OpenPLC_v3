#!/bin/sh -ae
if [ $# -eq 0 ]; then
    echo "Error: You must provide a file to be compiled as argument"
    exit 1
fi

. $(dirname "$(readlink -f "$0")")/env

echo "compiling program for $OPENPLC_PLATFORM"
echo ""
    
if [ "$OPENPLC_PLATFORM" = "linux" ]; then
    cd /tmp

    x=""
    if [ "$OPLC_MUSL" = "ON" ]; then
        x="-DOPLC_MUSL"
    fi

    cp $PREFIX/etc/st_files/$1 .

    st_optimizer $1 $1
    iec2c -I $PREFIX/runtime/lib $1 >/dev/null
    glue_generator >/dev/null

    for a in glueVars.cpp Config0.c Res0.c $PREFIX/runtime/core/hardware_layer.cpp; do
        echo "Compiling $a ..."
        cc $x -O3 -DNDEBUG -I$PREFIX/include -I$PREFIX/runtime/core -c $a
    done

    echo "Linking..."
    c++ -rdynamic Config0.o Res0.o glueVars.o hardware_layer.o -o $PREFIX/bin/openplc \
        -lopenplc -lpthread -lmodbus -lasiodnp3  -lasiopal -lopendnp3 -lopenpal \
        -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib

    echo -n $1 > $PREFIX/etc/active_program
    echo "Compilation finished successfully!"
    exit 0

else
    echo "Error: Undefined platform! This OpenPLC setup is configured for Linux environment only"
    echo "Compilation finished with errors!"
    exit 1
fi

