#!/usr/bin/env python3
from os.path import dirname, join, split, abspath
import os
import sys
import shutil
import subprocess
import argparse
from contextlib import suppress
from collections import OrderedDict


def _mkdir_p(dir):
    with suppress(FileExistsError):
        os.makedirs(dir)

class Project(object):
    def __init__(self, *, files, ucf, testbenches = None):
        self.files         = files
        self.ucf           = ucf
        self.testbenches   = testbenches
        self.part          = "xc3s500e-fg320"
        self.build_dir     = "_build"
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

    def _normalise_paths(self):
        project_dir = split(sys.argv[0])[0]

        def norm(files):
            return [abspath(join(project_dir, f)) for f in files]

        self.files       = norm(self.files)
        self.testbenches = norm(self.testbenches)
        self.build_dir   = abspath(join(project_dir, self.build_dir))

    def _generate_file_mapping(self):
        source_dir  = join(self.build_dir, "src")
        _mkdir_p(source_dir)
        self.file_mapping = OrderedDict()
        for f in self.files + self.testbenches:
            out_name = abspath(join(source_dir, split(f)[1]))
            self.file_mapping[f] = out_name

    def _preprocess_source(self):
        for source, dest in self.file_mapping.items():
            shutil.copyfile(source, dest)

    def generate(self):
        _mkdir_p(self.build_dir)

        self._output_build_script()
        self._output_ucf()
        self._output_proj()


    def _parse_args(self):
        parser = argparse.ArgumentParser()

        group = parser.add_mutually_exclusive_group()
        group.add_argument("--build",     "-b", default=False, action="store_true")
        group.add_argument("--upload",    "-u", default=False, action="store_true")
        group.add_argument("--testbench", "-t", default=None, nargs="*")

        parser.add_argument("--clean", "-c", default=False, action="store_true")
        parser.add_argument("--run", "-r", default=False, action="store_true")

        self.args = parser.parse_args()

    def build(self):
        subprocess.call(["bash", join(self.build_dir, "run.sh")])

    def _run_testbench(self):
        tb_dir = join(self.build_dir, "testbenches")
        print("Elaborating testbench...")
        subprocess.Popen(["ghdl", "-e", "tb"], cwd=tb_dir).wait()
        if self.args.run:
            print("Running testbench... (press ctrl-c to quit)")
            vcd_command = ["--vcd={}".format(join(os.getcwd(), "out.vcd"))]
            subprocess.Popen(["ghdl", "-r", "tb", "--disp-time"] + vcd_command, cwd=tb_dir).wait()

    def _generate_testbench(self):
        self._preprocess_source()
        tb_dir = join(self.build_dir, "testbenches")
        _mkdir_p(tb_dir)
        for f in self.files + self.testbenches:
            input_file = self.file_mapping[f]
            print("Analysing {}...".format(split(f)[1]))
            subprocess.Popen(["ghdl", "-a", input_file ], cwd=tb_dir).wait()

    def start(self):
        self._parse_args()
        self._normalise_paths()

        if self.args.clean:
            shutil.rmtree(self.build_dir)

        self._generate_file_mapping()

        if self.args.testbench is not None:
            self._generate_testbench()
            self._run_testbench()
        elif self.args.upload:
            raise NotImplementedError()
        else:
            self.generate()
            self.build()
