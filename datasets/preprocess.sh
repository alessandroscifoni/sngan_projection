#!/bin/bash
set -euo pipefail    # Strict mode

IMAGENET_PATH=$1
SAVE_PATH=$2
# IMAGENET_PATH_VAL=$3
# SAVE_PATH_VAL=$4

function convertDir() {
   dir="$1"
   save_path="$2"

   # Handle files with spaces in their names
   # but also different extensions
   find "$dir" \
      -type f \
      -iname '*.jpg' -print0 \
      -or -iname '*.jpeg' -print0 \
      -or -iname '*.png' -print0 \
      | while IFS= read -r -d $'\0' name; do
         convertImage "$name" "$dir" "$save_path" || (
            echo "Failed to convert $name"
            exit 1
         )
   done
}

function convertImage() {
   name="$1"
   dir="$2"
   save_path="$3"

   out_file=${save_path}/${dir##*/}/${name##*/}

   # Skip existing files
   if [ -f "$out_file" ]; then
      echo "Skipping $out_file"
      return
   fi

   w=`identify -format "%w" "$name"`
   h=`identify -format "%h" "$name"`
   magick "$name" -resize 256x256^ -quality 95 -gravity center -extent 256x256 "$out_file"
}

# Preprocess training data
mkdir -p "$SAVE_PATH"
for dir in `find "$IMAGENET_PATH" -type d -maxdepth 1 -mindepth 1`; do
   echo $dir
   mkdir -p ${SAVE_PATH}/${dir##*/}
   convertDir "$dir" "$SAVE_PATH"
done

# Preprocess validation data
# if [ -n "$IMAGENET_PATH_VAL" ] && [ -n "$SAVE_PATH_VAL" ]; then
#     mkdir -p $SAVE_PATH_VAL
#     for name in ${IMAGENET_PATH_VAL}/*.JPG; do
#        echo "$name"
#        convert -resize 256x256^ -quality 95 -gravity center -extent 256x256 "$name" ${SAVE_PATH_VAL}/${name##*/}
#     done
# fi
