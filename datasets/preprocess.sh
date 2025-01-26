#!/bin/bash
set -euo pipefail    # Strict mode

IMAGENET_PATH=$1
SAVE_PATH=$2
# IMAGENET_PATH_VAL=$3
# SAVE_PATH_VAL=$4

function convertImage() {
   name="$1"
   dir="$2"

   w=`identify -format "%w" "$name"`
   h=`identify -format "%h" "$name"`
   if [ $w -ge 256 ] && [ $h -ge 256 ]; then
         convert -resize 256x256^ -quality 95 -gravity center -extent 256x256 "$name" ${SAVE_PATH}/${dir##*/}/${name##*/}
   fi
}

# Preprocess training data
mkdir -p "$SAVE_PATH"
for dir in `find "$IMAGENET_PATH" -type d -maxdepth 1 -mindepth 1`; do
   echo $dir
   mkdir -p ${SAVE_PATH}/${dir##*/} 

   # Handle files with spaces in their names
   find "$dir" -type f -iname '*.jpg' -print0 | while IFS= read -r -d $'\0' name; do
      convertImage "$name" "$dir"
   done
done

# Preprocess validation data
# if [ -n "$IMAGENET_PATH_VAL" ] && [ -n "$SAVE_PATH_VAL" ]; then
#     mkdir -p $SAVE_PATH_VAL
#     for name in ${IMAGENET_PATH_VAL}/*.JPG; do
#        echo "$name"
#        convert -resize 256x256^ -quality 95 -gravity center -extent 256x256 "$name" ${SAVE_PATH_VAL}/${name##*/}
#     done
# fi
