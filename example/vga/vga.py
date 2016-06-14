#!/usr/bin/env python3
from vhdl.project  import *
from vhdl import nexys2

ucf = {
    "clk"   : nexys2.clk,
    "reset" : nexys2.button[0],
    "red"   : nexys2.red,
    "green" : nexys2.green,
    "blue"  : nexys2.blue,
    "hs"    : nexys2.hs,
    "vs"    : nexys2.vs,
}

files = [
    "./clock_gen.vhd",
    "./vga.vhd",
    "./top.vhd",
]

proj = Project(
    ucf=ucf,
    files=files
)

proj.generate()
proj.build()
