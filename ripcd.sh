#!/bin/sh
# script to rip Audio-CD disc
# the main intent was to rip to files with specific name format
#
# TODO:
# - add support for cue
# - get a better solution for transliteration
#

CDROM=$1
TRACKS=`cdparanoia -Q -d $CDROM 2>&1 | grep -x -e "^[ 0-9].*" | wc -l`

#
# following is an example of the file with information about CD
#
#ARTIST="Artist"
#ALBUM="Album"
#COMMENT="Encoded by "
#DA="2010"
#FILE_NAME[1]="track 01"
#FILE_NAME[2]="track 02"
#

#include a file formatted as descibed above
. $2

if [ -z $3 ]; then STARTPOS=1; else STARTPOS=$3; fi
if [ -z $4 ]; then FINISHPOS=$TRACKS; else FINISHPOS=$4; fi

for (( TN=$STARTPOS ; $TN <= $FINISHPOS ; TN++ ));
do
 if set | grep "^ARTIST=(" > /dev/null
 then ARTIST_TITLE="${ARTIST[$TN]}"
 else ARTIST_TITLE="${ARTIST}"
 fi

#very ugly, I believe it can be done in more elegant way
 TRANSLIT=`echo "${FILE_NAME[$TN]}" | sed y/абвгдезийклмнопрстуфхцыэ/abvgdezijklmnoprstufhcye/`
 TRANSLIT=`echo "${TRANSLIT}" | sed y/АБВГДЕЗИЙКЛМНОПРСТУФХЦЫЭ/ABVGDEZIJKLMNOPRSTUFHCYE/`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e y/ґҐєЄіІ/gGeEiI/`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/ї/ji/`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/Ї/JI/`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/\?//`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/\*//`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/://`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/\\\///`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/ё/jo/ -e s/ж/zh/ -e s/ч/ch/ -e s/ш/sh/ -e s/щ/sh/ -e s/ъ// -e s/ь// -e s/ю/ju/ -e s/я/ya/`
 TRANSLIT=`echo "${TRANSLIT}" | sed -e s/Ё/JO/ -e s/Ж/ZH/ -e s/Ч/CH/ -e s/Ш/SH/ -e s/Щ/SH/ -e s/Ъ// -e s/Ь// -e s/Ю/JU/ -e s/Я/YA/`
 FILENM=`gawk 'BEGIN { LCASED = tolower(ARGV[1]); gsub("\ ", "_", LCASED); print LCASED}' "${TRANSLIT}" 2>/dev/null` && \
 TNSTR=`gawk 'BEGIN { printf "%0.2d",ARGV[1]}' $TN 2>/dev/null` && \
 echo "OUTPUT TO ${TNSTR}-${FILENM}.flac" && \
 cdparanoia -d $CDROM $TN - | \
 flac --totally-silent -o $TNSTR-$FILENM.flac -8 \
 -T artist="$ARTIST_TITLE" \
 -T album="$ALBUM" \
 -T title="${FILE_NAME[$TN]}" \
 -T date="$DA" \
 -T comment="$COMMENT" \
 -T description="$COMMENT" \
 -T tracknumber="$TNSTR" \
 - ;
 
  if [ $? == 0 ]; then echo "DONE OK"; else echo "OOPS! ERROR!"; fi
done
