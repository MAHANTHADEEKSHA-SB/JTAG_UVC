# JTAG UVC

A planned reusable SystemVerilog/UVM JTAG verification component using separate driver and monitor BFMs, a common signal interface, and abstract proxy contracts.

## Architecture

See [Architecture and advantages](docs/architecture.md) for the proposed structure, responsibilities, benefits, trade-offs, and open decisions.

Status: initial implementation scaffold generated from the architecture proposal. No simulation results are included yet; several proxy/timing details are first-draft and still need validation. Initial simulation is planned on EDA Playground with UVM 1.2 and a compatible simulator.

## Repository layout

```text
src/
  jtag_types_pkg.sv        dependency-free package: enums, structs, TAP navigation utilities
  jtag_if.sv                common signal interface
  jtag_driver_bfm.sv         driver BFM (pin/timing only; no proxy logic)
  jtag_monitor_bfm.sv        monitor BFM (pin/timing only; no proxy logic)
  jtag_pkg.sv               package aggregating base/concrete UVM classes, in dependency order
  classes/
    base/                    the architecture's extension points (never reference a BFM)
      proxy/                 abstract driver/monitor proxy contracts
    proxy/                   concrete proxies; the only classes that hold a BFM handle
    seq/                     sequences: base scan sequence, reset, IR scan, DR scan
    (item, config, driver, monitor, sequencer, agent)
tb/
  jtag_min_compile_tb.sv    minimal compile/bind top (validation plan step 1)
  dut/jtag_tap_stub.sv       placeholder loopback TAP for the compile test only
  tests/jtag_smoke_test.svh
files.f                      file list for EDA Playground / simulator compilation
```

`jtag_types_pkg` exists separately from `jtag_pkg` so the BFM interfaces (pin/timing level) and `jtag_pkg` (UVM class level, whose concrete proxies hold a handle to a BFM) can share the same enums/structs without a circular file dependency. `jtag_pkg` re-exports `jtag_types_pkg`, so importing `jtag_pkg` alone is enough everywhere else.

Open items called out in the architecture doc (exact proxy signatures, reset/interruption semantics, TCK/timing ownership, monitor buffering policy) have first-draft answers in this scaffold; treat them as unverified until run through the validation plan.
