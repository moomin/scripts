#!/bin/sh

IN=$1
OUT=$2
SAMPLE_RATE=44100
BPS=16

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
#flac -s -d -c $IN | sox - -D -r $SAMPLE_RATE -b $BPS -t wav - | flac -8 -o $OUT -

#Option 2: always work but has drawbacks
#does everything (decoding, downsampling, encoding) with same speed as #1
#in this case encoder doesn't know input size and cannot create seektable and cuesheet cannot be added
#flac -s -d -c $IN | sox - -S -D -r $SAMPLE_RATE -b $BPS -t raw -e signed-integer - | flac -s -8 -o $OUT --endian=little --channels=2 --sign=signed --bps=16 --sample-rate=44100 -

#Option 3: randomly does not work on linux
#but requires creating a wav file resulting in more time to process
#sox crashes with following message:
#sox FAIL formats: can't open input  `-': WAVE: RIFF header not found 
#flac -s -d -c $IN | sox - -S -D -r $SAMPLE_RATE -b $BPS $OUT.wav

echo "Decoding"
flac -d -o $OUT.wav.orig $IN

echo "Downsampling"
sox $OUT.wav.orig -S -D -r $SAMPLE_RATE -b $BPS $OUT.wav

#cleanup original decoded wav
rm $OUT.wav.orig

echo "Encoding"
flac -8 -S 4s -o $OUT $OUT.wav 

echo "Exporting tags"
metaflac --export-tags-to=$TAGS $IN

echo "Importing tags"
metaflac --import-tags-from=$TAGS $OUT

#cleanup
rm $OUT.wav
rm $TAGS
echo "Downsampling complete"

