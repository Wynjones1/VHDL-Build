#!/usr/bin/env python3
from os.path import dirname, join, split, abspath
import os
import sys
import shutil
import subprocess
from contextlib import suppress


def _mkdir_p(dir):
    with suppress(FileExistsError):
        os.makedirs(dir)

class Project(object):
    def __init__(self, *, files, ucf):
        self.files         = files
        self.ucf           = ucf
        self.part          = "xc3s500e-fg320"
        self.build_dir     = "build"
        self.xilinx_source = "/opt/Xilinx/14.7/ISE_DS/settings64.sh"
        self.proj_file     = "out.proj"
        self.ucf_file      = "out.ucf"
        self.out_file      = "output"
        self.opt_mode      = "Speed"
        self.opt_level     = 1
        self.startup_clk   = "JtagClk"
        self.bit_file      = "out.bit"
        self.device        = "Nexys2"
        self.threads       = 4

    def _output_build_script(self):
        options = {
            "xilinx_source" : self.xilinx_source,
            "proj_file"     : self.proj_file,
            "out_file"      : self.out_file,
            "part"          : self.part,
            "opt_mode"      : self.opt_mode,
            "opt_level"     : self.opt_level,
            "ucf"           : self.ucf_file,
            "startup_clk"   : self.startup_clk,
            "bit_file"      : self.bit_file,
            "device"        : self.device,
            "threads"       : self.threads,
            "build_dir"     : abspath(self.build_dir),
        }
        template_file = join(dirname(__file__), "build_script.txt")
        with open(template_file, "r") as fp:
            script = fp.read().format(**options)
        with open(join(self.build_dir, "run.sh"), "w") as fp:
            fp.write(script)

    def _output_ucf(self):
        with open(join(self.build_dir, self.ucf_file), "w") as fp:
            for key, value in self.ucf.items():
                if isinstance(value, tuple):
                    for idx, value in enumerate(value):
                        fp.write('NET {}<{}> LOC = "{}";\n'.format(key, idx, value))
                else:
                    fp.write('NET {} LOC = "{}";\n'.format(key, value))
            fp.write("\n")

    def _output_proj(self, sources):
        with open(join(self.build_dir, self.proj_file), "w") as fp:
            for f in sources:
                fp.write("{}\n".format(f))

    def _preprocess_source(self):
        project_dir = split(abspath(sys.argv[0]))[0]
        source_dir = join(self.build_dir, "src")
        _mkdir_p(source_dir)
        out = []
        for f in self.files:
            out_name = abspath(join(source_dir, split(f)[1]))
            in_name  = join(project_dir, f)
            out.append(out_name)
            shutil.copyfile(in_name, out_name)
        return out

    def _build_testbench(self, sources):
        for f in sources:
            print("Building testbench for {}".format(f))
            subprocess.call(["ghdl", "-a", f, "-o", join(self.build_dir, "out.cf")])

    def generate(self):
        _mkdir_p(self.build_dir)

        self._output_build_script()
        self._output_ucf()
        sources = self._preprocess_source()
        self._build_testbench(sources)
        self._output_proj(sources)

    def build(self):
        subprocess.call(["bash", join(self.build_dir, "run.sh")])
