#!/usr/bin/env python2

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
