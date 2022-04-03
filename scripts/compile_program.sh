#!/bin/sh -ae
if [ $# -eq 0 ]; then
    echo "Error: You must provide a file to be compiled as argument"
    exit 1
fi

. $(dirname "$(readlink -f "$0")")/env

echo "compiling program for $OPENPLC_PLATFORM"
echo ""
    
if [ "$OPENPLC_PLATFORM" = "linux" ]; then
    rm -rf /tmp/build
    mkdir -p /tmp/build
    cd /tmp/build

    x=""
    if [ "$OPLC_MUSL" = "ON" ]; then
        x="-DOPLC_MUSL"
    fi

    cp $PREFIX/etc/st_files/$1 .

    st_optimizer $1 $1
    files=$(iec2c -I $PREFIX/runtime/lib $1 | sed "s/\(POUS\|LOCAT\).*//") >/dev/null
    glue_generator >/dev/null
    echo $files

    src=""
    out=""
    for f in  $files; do
        if [ -z ${f##*.c} ]; then
            src="${src} ${f}"
            out="${out} ${f/\.c/\.o}"
        fi
    done;
    echo $out

    for a in ${src} glueVars.cpp $PREFIX/runtime/core/hardware_layer.cpp; do
        echo "Compiling $a ..."
        cc $x -O3 -DNDEBUG -I$PREFIX/include -I$PREFIX/runtime/core -c $a
    done

    echo "Linking..."
    c++ -rdynamic ${out} glueVars.o hardware_layer.o -o $PREFIX/bin/openplc \
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

