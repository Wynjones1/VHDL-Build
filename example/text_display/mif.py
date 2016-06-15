#!/usr/bin/env python2.7
import sys

def group(l, dim):
    out = []
    while l:
        t, l = l[:dim], l[dim:]
        out.append(t)
    return out

def read_text(text, *dims):
    temp = []
    d = dims[0]
    while text:
        vector, text = '"{}"'.format(text[:d]), text[d:]
        temp.append(vector)
    for dim in dims[1:]:
        y = []
        for x in group(temp, dims[1]):
            y.append("({})".format(",".join(x)))
        temp = y
    return temp

def main(argv):
    name, type, filename, out = argv[1:5]
    text = open(filename, "rU").read().replace("\n", "")
    text = text.replace("X", "1")
    text = text.replace(" ", "0")
    x = read_text(text, 8, 8)
    with open(out, "w") as fp:
        fp.write("constant {} : {} := (\n\t".format(name, type))
        fp.write(",\n\t".join(x))
        fp.write(");\n")

if __name__ == "__main__":
    main(sys.argv)
