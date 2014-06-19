#!/bin/bash

#    Script to analyze the distribution of bitrates in a music collection.
#    Copyright (C) 2014  Russell Haley
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eu

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

rm $scaledtmp
rm $datatmp
rm $labeltmp
