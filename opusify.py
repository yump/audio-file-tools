#!/usr/bin/env python2

"""
Program for preparing audio files for portable devices. Transcodes to opus 
and deletse the original, if the original is lossless or high enough quality
lossy such that the degredation won't be too terrible. opusify.py is best used
with find | parallel.

Usage:
  opusify.py [-b <bitrate>] [--help] <file>...

Options:
  -b <bitrate> --bitrate=<bitrate>  Opus target bitrate [default: 96k].
  -h --help                         Show this message

"""

#I do not like python 2
from __future__ import division
from __future__ import print_function

import mutagen
import subprocess as subp
import os
import sys
import re

from docopt import docopt

def can_transcode(filename):
    """Test if transcoding to a lossy format is appropriate."""
    try:
        mg_File = mutagen.File(filename)
        if isinstance(mg_File, mutagen.flac.FLAC):
            return True
        if isinstance(mg_File, mutagen.wavpack.WavPack):
            return True
        if isinstance(mg_File, mutagen.mp3.MP3):
            # Transcode from MP3 if bitrate > 250 kbps
            if mg_File.info.bitrate/1000 > 250: 
                return True
        return False
    except:
        return False

def do_transcode(filename, bitrate):
    newname = re.sub("\.[^.]+$",".opus",filename)
    ffmpeg_command = """
    ffmpeg
    -i {ifile}
    -c:a opus
    -b:a {br}
    {ofile}
    """.format(ifile=filename, br=bitrate, ofile=newname).split()
    subp.check_call(ffmpeg_command)
    os.remove(filename)


if __name__ == "__main__":
    args = docopt(__doc__)
    files = args["<file>"]
    opus_bitrate = args["--bitrate"]
    for fn in files:
        if can_transcode(fn):
            try:
                do_transcode(fn, opus_bitrate)
            except:
                sys.stderr.write("Problem transcoding {}\n".format(fn))
                exit(1)

