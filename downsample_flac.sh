#!/bin/sh

IN=$1
IN_SR=`metaflac --show-sample-rate $1`
IN_BPS=`metaflac --show-bps $1`

OUT=$2
OUT_SR=44100
OUT_BPS=16

TAGS=$OUT.tags

#cuesheet section in flac file doesn't include track names rendering it useless
#CUESHEET=${IN%.flac}.cue

# -D sox option disables dithering which takes place by default
# in order to increase dynamic range when 24 to 16 bit conversion applied
# -V sox option can be given to display all effects chain
# the command below does decode | downsample | encode

#Option 1: does not work sometimes
#does everything (decoding, downsampling, encoding) and the fastest
#encoder just crashes with unexpected EOF at 99-100%
#flac -s -d -c $IN | sox - -D -r $OUT_SR -b $OUT_BPS -t wav - | flac -8 -o $OUT -

#Option 2: always work but has drawbacks
#does everything (decoding, downsampling, encoding) with same speed as #1
#in this case encoder doesn't know input size and cannot create seektable and cuesheet cannot be added
#flac -s -d -c $IN | sox - -S -D -r $OUT_SR -b $OUT_BPS -t raw -e signed-integer - | flac -s -8 -o $OUT --endian=little --channels=2 --sign=signed --bps=$OUT_BPS --sample-rate=$OUT_SR -

#Option 3: always works but slow because requires temporary files on each stage
#flac -d -o $OUT.wav.orig $IN
#sox $OUT.wav.orig -S -D -r $OUT_SR -b $OUT_BPS $OUT.wav
#rm $OUT.wav.orig
#flac -8 -S 4s -o $OUT $OUT.wav 
#rm $OUT.wav

#Option 4: always works and almost as fast as #1
#the only slowdown is in additional seektable generation command
echo "Decoding, downsampling and encoding"
flac -s -d -c --force-raw-format --endian=little --sign=signed $IN |\
sox -t raw -r $IN_SR -b $IN_BPS -c 2 -e signed-integer -\
    -D\
    -t raw -r $OUT_SR -b $OUT_BPS - |\
flac -s -8 -o $OUT -P 65536 --endian=little --channels=2 --sign=signed --bps=$OUT_BPS --sample-rate=$OUT_SR -

echo "Adding seektable"
metaflac --add-seekpoint=4s $OUT

echo "Exporting tags"
metaflac --export-tags-to=$TAGS $IN

echo "Importing tags"
metaflac --import-tags-from=$TAGS $OUT

rm $TAGS
echo "Downsampling finished"
ls -lh $OUT

