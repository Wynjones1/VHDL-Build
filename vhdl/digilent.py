#!/usr/bin/env python3
import subprocess
import re


def _attribute(line):
    return [x.strip() for x in line.split(":")]

_device_regex = re.compile(\
"""Found (\d+) device\(s\)\s+Device: (\w+)
"""

, re.M | re.S
)
def list():
    p = subprocess.check_output(["djtgcfg", "enum"]).decode("utf-8")
    lines = p.split("\n")
    match = re.match(r"Found (\d+) device\(s\)", lines[0])
    out = {}
    if match:
        num_devices = int(match.groups()[0])
        start = lines[2:]
        device = _attribute(start[0])[1]
        out[device] = {}
        key, value = _attribute(start[1])
        out[device][key] = value
        key, value = _attribute(start[2])
        out[device][key] = value
        key, value = _attribute(start[3])
        out[device][key] = value
    return out
