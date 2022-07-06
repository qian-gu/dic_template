# dic_template

[![verilator](https://github.com/qian-gu/dic_template/actions/workflows/verilator.yml/badge.svg?branch=main)](https://github.com/qian-gu/dic_template/actions/workflows/verilator.yml)

Digital IC template project integrated with common opensource tools.

## Feature

- [x] support verilator
- [ ] support fusesoc
- [ ] support verible
- [ ] support svlint
- [ ] support yosis
- [ ] CI (travis)
- [ ] build.yml

## verilator

- `tb/tb_top`: testbench
- `tb/sim_main.cpp`: wrapper to instantiate testbench
- `Makefile`: including environment variables checking and build, run, coverage targets

## svlint

The configuration(`.svlint.toml`) matches the lowRISC SystemVerilog style guide at
https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md.
See https://github.com/dalance/svlint/blob/master/RULES.md for a list of rules.

```sh
svlint -f vlogfiles.f
```

## fusesoc
