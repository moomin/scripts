#!/bin/bash

export inname=$1
export outname=$1
#south|center
export gravity=$2

convert $inname -resize 1280x1280 -gravity $gravity -crop 1280x720+0+0 $outname