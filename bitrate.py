#!/usr/bin/env python2

#    bitrate.py is a script for getting the bitrate of mp3 audio files.
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

#I do not like python 2
from __future__ import division
from __future__ import print_function

import mutagen
import sys

def bitrate(filename):
    return mutagen.File(fn).info.bitrate/1000

for fn in sys.argv[1:]:
    try:
        print("{}\t{}".format(bitrate(fn),fn))
    except (KeyboardInterrupt, SystemExit):
        raise
    except:
        sys.stderr.write("problem with file {}\n".format(fn))
        raise
