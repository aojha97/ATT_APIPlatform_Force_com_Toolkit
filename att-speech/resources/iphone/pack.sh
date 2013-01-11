#!/bin/bash

# Function for packing javascript files in directory.
# Params:
#   DIRECTORY - defines directory with files to pack.
#
# Usage: pack $DIRECTORY
#
function pack {
    DIR=$1
    DIR_PATH="${DIR%/}"
    DIR_NAME="${DIR_PATH##*/}"
    PACKED_JS_NAME="$DIR_NAME.packed.js"
    
    if [[ -z `ls *.js | grep "$PACKED_JS_NAME"` ]]; then
        cat *.js >> $PACKED_JS_NAME
        ls *.js | grep -v "$PACKED_JS_NAME" | xargs rm
    fi
    echo "[CREATED] $PACKED_JS_NAME file in $DIR"
}

# Function for replacing all scripts from specified directory
# with single packed script in index.html file
# Params:
#   DIRECTORY - defines directory with files to pack.
#
# Usage: change_index_file $DIRECTORY
#
function change_index_file {
    DIR=$1
    ESCAPED_DIR_NAME=${DIR%/}
    ESCAPED_DIR_NAME="${ESCAPED_DIR_NAME##$ROOT_DIR/}"
    DIR_NAME_PATTERN=${ESCAPED_DIR_NAME//\//\\\/}"\/[^\/]+\.js"
    PACKED_FILE=`ls $ROOT_DIR/$ESCAPED_DIR_NAME/*.js`
    PACKED_FILE="${PACKED_FILE##$ROOT_DIR/}"
    awk 'BEGIN { count = 0; }
    {
        if (/'$DIR_NAME_PATTERN'/ && count < 1) {
            count++;
            sub(/'$DIR_NAME_PATTERN'/, "'$PACKED_FILE'")
            print;
        }
        else if (! /'$DIR_NAME_PATTERN'/)
            print;
    }' "$ROOT_DIR/index.html" > /tmp/out && mv /tmp/out "$ROOT_DIR/index.html"
    echo "[DONE] Scripts from $DIR are replaced with packed script"
}


# ====== MAIN ======= #
if [ -z $1 ] || [ -z $2 ]; then
    echo "Directory must be specified"
    echo "Command format: pack.sh [ROOT_DIR] [JS_DIR]"
else
    echo "Packing files..."
    ROOT_DIR="$1"
    ROOT_DIR="${ROOT_DIR%/}"
    JS_DIR="$2"
    JS_DIR="${JS_DIR%/}"
    JS_DIR="${JS_DIR##$ROOT_DIR/}"
        
    cd $ROOT_DIR
    ROOT_DIR=`pwd`
        
    # Packing all javascript files in root directory
    # and its subdirectories
    SUB_DIRS=`ls -d $ROOT_DIR/$JS_DIR/*/`
    SUB_DIRS="$SUB_DIRS $ROOT_DIR/$JS_DIR/"
    echo "Packing scripts..."
    for DIR in $SUB_DIRS; do
        cd $DIR
        pack $DIR
        cd $ROOT_DIR
    done
    # Replacing all scripts declarations with single packed script 
    # for every subdirectory 
    echo "Replacing script in index.html..."
    for DIR in $SUB_DIRS; do
        change_index_file $DIR
    done
fi