see [original repo](https://github.com/nmoroze/opentitan-sv2v)

## Usage
Download and patch the OpenTitan source (included as a submodule of this repo):
```
git submodule update
cd opentitan
git apply < ../opentitan_sv.patch
cd ..
```

Generate opentitan_patched.v (added a second patch to make memories blackbox):
```
make
```

Run simulation of `opentitan_patched.v` on code in `firmware/bootrom.s`:
```
make sim
```

Run yosys to synthesize design to generate `opentitan_synth.v` and run simulation:
```
make synthsim
```

Don't start gtkwave:
```
make sim2
make synthsim2
```
