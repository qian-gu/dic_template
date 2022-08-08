# dic_template

[![ci](https://github.com/qian-gu/dic_template/actions/workflows/ci.yml/badge.svg)](https://github.com/qian-gu/dic_template/actions/workflows/ci.yml)

Digital IC template project integrated with common opensource tools.

## Feature

- [x] support verilator
- [x] support fusesoc
- [x] support svlint
- [x] support bender
- [x] support morty
- [ ] support verible
- [ ] support yosis

Manage all targets and flows via the
[Makefile](https://github.com/qian-gu/dic_template/blob/main/Makefile).

## verilator

- `tb/tb_top`: testbench
- `tb/sim_main.cpp`: wrapper to instantiate testbench

## svlint

The configuration(`.svlint.toml`) matches the lowRISC SystemVerilog style guide at
https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md.

See https://github.com/dalance/svlint/blob/master/RULES.md for a list of rules.

## fusesoc

see the [Makefile](https://github.com/qian-gu/dic_template/blob/main/Makefile)
