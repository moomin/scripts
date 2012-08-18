import argparse
import os
import sys
import math
import subprocess
import errno

presets = ['720p', '1080p']
default_preset = 1

convert_command_template = "gm convert %(src)s -resize %(maxsize)dx%(maxsize)d -gravity center -crop %(w)dx%(h)d+0+0 -define jpeg:preserve-settings %(dst)s"

cl = argparse.ArgumentParser()
cl.add_argument("src", help="source directory with images")
cl.add_argument("dst", help="directory where to save converted images")
cl.add_argument("-p", "--preset",
    help="target resolution, default is " + presets[default_preset],
    choices=presets,
    default=presets[default_preset])
args = cl.parse_args()

if not os.access(args.src, os.X_OK) :
  print >> sys.stderr, "directory %s is not accessible" % args.src
  sys.exit(1)

if os.access(args.dst, os.X_OK) and len(os.listdir(args.dst)):
  print >> sys.stderr, "directory %s is not empty" % args.dst
  sys.exit(1)

if args.preset == "1080p":
  width = 1920
  height = 1080
  maxsize = 1920
elif args.preset == "720p":
  width = 1280
  height = 720
  maxsize = 1280

try:
  os.mkdir(args.dst)
  print "directory %s created" % os.path.abspath(args.dst)
except OSError as e:
  if e.errno != errno.EEXIST:
    print >> sys.stderr, "Error creating %s: %s" % (args.dst, e.strerror)
    sys.exit(1)

print "Starting processing %d source files" % len(os.listdir(args.src))

images = sorted(os.listdir(args.src))
src_abspath = os.path.abspath(args.src)
dst_abspath = os.path.abspath(args.dst)
total = len(images)

for i in range(total):
  dst = "%s/%04d.jpg" % (dst_abspath, i+1)
  percentage = (i+1) / (float(total)/float(100))
  sys.stdout.write("\r%03d%% (%04d/%04d)" % (percentage, i+1, len(images)))
  sys.stdout.flush()

  convert_args = {"src":src_abspath + "/" + images[i],
                  "maxsize":maxsize,
                  "w":width,
                  "h":height,
                  "dst":dst}

  convert_cmd = convert_command_template % convert_args
  if not subprocess.call(convert_cmd, shell=True) == 0:
    print "\nProcess exited with non-zero code: %s" % convert_cmd

print "\nAll done"
