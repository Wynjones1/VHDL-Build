#!/usr/bin/env python2.7

def main(argv):
    filename = argv[1]
    with open(filename, "r") as fp:
        for i in xrange(128):
