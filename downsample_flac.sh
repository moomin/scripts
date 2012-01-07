#!/bin/sh

IN=$1
OUT=$2
SAMPLE_RATE=44100
BPS=16

TAGS=$OUT.tags

# -D sox option disables dithering which takes place by default
# in order to increase dynamic range when 24 to 16 bit conversion applied
# -V sox option can be given to display all effects chain
# the command below does decode | downsample | encode
flac -s -d -c $IN | sox - -D -r $SAMPLE_RATE -b $BPS -t wav - | flac -8 -o $OUT - 
metaflac --export-tags-to=$TAGS $IN
metaflac --import-tags-from=$TAGS $OUT
rm $TAGS
echo "Downsampling is finished"

