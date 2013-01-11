#!/bin/bash

echo "Compiling files in $1 directory..."

# Checking the first parameter existance
if [ -z $1 ]; then
    echo "Command format: compile.sh [DIR]"
    echo "[ERROR] Directory should be specified";
else 
    CURRENT_DIR=`pwd`
    # Retrieving all js-files from the specified directory
    JS_FILES_DIR=$1
    JS_FILES_DIR=${JS_FILES_DIR%/}
    JS_FILES=`find $JS_FILES_DIR -type f -name *.js`
    
    for FILE in $JS_FILES; do
        # compiler.jar program cannot put result to the source js-file
        # so we create the new $COMPILED_FILE and then replace the source file with it
        COMPILED_FILE="$FILE.o"
        # Compile js-filess
        java -jar $CURRENT_DIR/resources/compiler/compiler.jar --js $FILE --js_output_file $COMPILED_FILE
        # Replacing source file with newly created
        mv -f $COMPILED_FILE $FILE
        
        echo "[COMPILED] $FILE";
    done
    
    echo "Compilation is finished."
fi