#!/bin/sh

#ls *.flv | while read file; do
#   echo ${file} | tr '[A-Z]' '[a-z]'
   #mv "${file%.avi}.flv" "${DEST_DIR}" 
#done
for f in *.flv; do
  g=`expr "xxx$f" : 'xxx\(.*\)' | tr '[A-Z]' '[a-z]'`
  h=`expr "xxx$g" : 'xxx\(.*\)' | tr ' ' '_'`
  echo mv "$f" "$h"
  mv "$f" "lower_$h"
  mv "lower_$h" "$h"
done 
