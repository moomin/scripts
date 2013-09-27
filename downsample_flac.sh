#!/bin/sh

IN=$1
IN_SR=`metaflac --show-sample-rate "$1"`
IN_BPS=`metaflac --show-bps "$1"`

OUT=$2
OUT_SR=44100
OUT_BPS=16

TAGS="$OUT.tags"

if [[ $3 == "mp3" ]]
then
FORMAT=mp3
else
FORMAT=flac
fi

ENCODEFLAC="flac -s -8 -o ${OUT} -P 65536 --endian=little --channels=2 --sign=signed --bps=$OUT_BPS --sample-rate=$OUT_SR -"
ENCODEMP3="lame -r -s 44.1 --bitwidth 16 --signed --little-endian -m s --preset insane --quiet - ${OUT}"

if [[ $FORMAT == mp3 ]]
then
ENCODECMD=$ENCODEMP3
else
ENCODECMD=$ENCODEFLAC
fi

#cuesheet section in flac file doesn't include track names rendering it useless
#CUESHEET=${IN%.flac}.cue

# -D sox option disables dithering which takes place by default
# in order to increase dynamic range when 24 to 16 bit conversion applied
# -V sox option can be given to display all effects chain
# the command below does decode | downsample | encode

echo "Decoding, downsampling and encoding"
flac -s -d -c --force-raw-format --endian=little --sign=signed "$IN" |\
sox -t raw -r $IN_SR -b $IN_BPS -c 2 -e signed-integer -\
    -D\
    -t raw -r $OUT_SR -b $OUT_BPS - |\
$ENCODECMD

#flac -s -8 -o "$OUT" -P 65536 --endian=little --channels=2 --sign=signed --bps=$OUT_BPS --sample-rate=$OUT_SR -

echo "Adding seektable"
metaflac --add-seekpoint=4s "$OUT"

echo "Exporting tags"
metaflac --export-tags-to="$TAGS" "$IN"

echo "Importing tags"
metaflac --import-tags-from="$TAGS" "$OUT"

rm "$TAGS"
echo "Downsampling finished"
ls -lh "$OUT"

