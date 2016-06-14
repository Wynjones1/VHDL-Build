#!/usr/bin/env python3
from vhdl.project  import *
from vhdl import nexys2

ucf = {
    "clk"   : nexys2.clk,
    "reset" : nexys2.button[0],
    "led"   : nexys2.led[0],
}

files = [
    "./clock_gen.vhd",
    "./top.vhd",
]

proj = Project(
    ucf=ucf,
    files=files
)

proj.generate()
proj.build()
