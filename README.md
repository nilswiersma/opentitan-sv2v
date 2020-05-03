# OpenTitan sv2v Build Flow

Convert the OpenTitan SystemVerilog codebase into a single flatted Verilog file
for use with tools like Yosys, Icarus Verilog, etc.

This repo contains a Makefile for building the Verilog source using sv2v,
supporting patches to tweak some things that sv2v doesn't seem to handle
properly, and a simple testbench.

## Background
I'm putting this up as a companion to [this
issue](https://github.com/lowRISC/opentitan/issues/1550) tracking the
creation of a working Yosys build flow for OpenTitan. I was working on this
for a verification project, and the build flow is for an old version of the
OpenTitan and isn't entirely comprehensive. It's not currently on the
critical path of my project at this point, so I don't plan to work on it
actively for the time being. That being said, I wanted to share what I have
in case it's helpful for anyone, as well as consolidate links to
[alternatives](#alternatives) so people can find something that works well
for them.

It seems that there's some interest in supporting this flow in OpenTitan
upstream, so if anyone has a particular use case they're trying to support it
might be nice to hear (either in the OpenTitan
[issue](https://github.com/lowRISC/opentitan/issues/1550) or as an issue on this
repo).

## Prerequisites
For Verilog build flow:
- [sv2v](https://github.com/zachjs/sv2v)

For firmware compilation/simulation:
- RISC-V toolchain
- [bin2coe](https://pypi.org/project/bin2coe)
- [Icarus Verilog](http://iverilog.icarus.com/)
- A vcd viewer, such as [gtkwave](http://gtkwave.sourceforge.net/)

## Usage
Download and patch the OpenTitan source (included as a submodule of this repo):
```
git submodule update
cd opentitan
git apply < ../opentitan_sv.patch
cd ..
```

Generate opentitan_patched.v:

`make`

Run simulation of `opentitan_patched.v` on code in `firmware/bootrom.s`:

`make sim`

## Caveats
- Debug module not included
- Tested on OpenTitan 3d93afbe, likely doesn't work on newer versions
- Limited testing of functionality!

## Alternatives
- [HardenedLinux](https://github.com/hardenedlinux/embedded-iot_profile/blob/master/docs/opentitan/opentitan-rtl-synthesis-with-yosys.md)
  - I haven't tried this yet, but it seems to support a more recent version of
    OpenTitan, so likely a better option if that's what you need.
- [OpenTitan in-tree](https://github.com/lowRISC/opentitan/blob/master/util/syn_yosys.sh)
  - Part of official project, but it's experimental and wasn't working when I
    tried it.

## Contributing
Feel free to open an issue if you have any questions or are looking to support a
particular use case! I'd also welcome PRs if you notice anything is broken.
