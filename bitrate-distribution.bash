#!/bin/bash

#set -eu

musdir="$HOME/Music/main"

datatmp=$(mktemp)

#get bitrate information.  Format is <bitrate> <filename>.
#find "$musdir" -type f -iname '*.mp3' -exec ./bitrate.py "{}" + >$datatmp
cp bitrates.txt $datatmp

#scale for gnuplot's smoothing functions
scalefactor=$(calc -p 1 / $(wc -l <$datatmp) | sed 's/~//')
scalefactor=1
scaledtmp=$(mktemp)
awk "{print \$1,$scalefactor}" $datatmp >$scaledtmp

#Find the top 8 bitrates seen more than once, for peak labeling
labeltmp=$(mktemp)
awk '{print $1}' $datatmp \
	| sort -n \
	| uniq -c \
	| sort -nk 1,1 \
	| tail -n8 \
	| awk '{print $2,$1+50,$2+0"k"}' \
	>$labeltmp

gnuplot /dev/stdin <<-EOF
	#set term pdf fontscale 0.3
	set term png size 1280,800
	unset key
	set xlabel "Bitrate (kbps)"
	set xrange [0:330]
	#set output "cdf.pdf"
	set output "cdf.png"
	set title "MP3 Bitrate Cumulative Distribution"
	plot "$scaledtmp" smooth cumulative with steps
	#set output "counts.pdf"
	set output "counts.png"
	set title "MP3 Bitrate File Counts"
	plot "$scaledtmp" smooth frequency with impulses, "$labeltmp" with labels
EOF

#rm $scaledtmp
#rm $datatmp
#rm $labeltmp
