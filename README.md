# JTAG UVC

A planned reusable SystemVerilog/UVM JTAG verification component using separate driver and monitor BFMs, a common signal interface, and abstract proxy contracts.

## Architecture

See [Architecture and advantages](docs/architecture.md) for the proposed structure, responsibilities, benefits, trade-offs, and open decisions.

Status: initial implementation scaffold generated from the architecture proposal. No simulation results are included yet; several proxy/timing details are first-draft and still need validation. Initial simulation is planned on EDA Playground with UVM 1.2 and a compatible simulator.

## Repository layout

```text
src/
  jtag_if.sv              common signal interface
  jtag_pkg.sv             package aggregating types and UVM classes, in dependency order
  jtag_driver_bfm.sv       driver BFM + concrete driver proxy
  jtag_monitor_bfm.sv      monitor BFM + concrete monitor proxy
  classes/                 UVM classes: item, sequences, config, driver, monitor, sequencer, agent
    proxy/                 abstract driver/monitor proxy contracts
    seq/                   example sequences (reset, IR scan, DR scan)
tb/
  jtag_min_compile_tb.sv  minimal compile/bind top (validation plan step 1)
  dut/jtag_tap_stub.sv     placeholder loopback TAP for the compile test only
  tests/jtag_smoke_test.svh
files.f                    file list for EDA Playground / simulator compilation
```

Open items called out in the architecture doc (exact proxy signatures, reset/interruption semantics, TCK/timing ownership, monitor buffering policy) have first-draft answers in this scaffold; treat them as unverified until run through the validation plan.
