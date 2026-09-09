// Shared package: common enums, data types, abstract proxy contracts, and
// UVM classes, included in an explicit dependency order
// (docs/architecture.md, "Parameters, packages, and runtime
// configuration"). Not instantiated with per-agent parameter overrides;
// per-instance values live in jtag_agent_config instead.
package jtag_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Shared enums, structs, and TAP navigation utilities.
  `include "classes/jtag_types.svh"

  // Abstract proxy contracts (extension points implemented by concrete
  // BFM proxies nested inside src/jtag_driver_bfm.sv and
  // src/jtag_monitor_bfm.sv).
  `include "classes/proxy/jtag_base_driver_proxy.svh"
  `include "classes/proxy/jtag_base_monitor_proxy.svh"

  // Sequence item.
  `include "classes/jtag_base_sequence_item.svh"
  `include "classes/jtag_item.svh"

  // Sequences.
  `include "classes/jtag_base_sequence.svh"
  `include "classes/seq/jtag_reset_sequence.svh"
  `include "classes/seq/jtag_ir_scan_sequence.svh"
  `include "classes/seq/jtag_dr_scan_sequence.svh"

  // Agent configuration.
  `include "classes/jtag_agent_config.svh"

  // Driver.
  `include "classes/jtag_base_driver.svh"
  `include "classes/jtag_driver.svh"

  // Monitor.
  `include "classes/jtag_base_monitor.svh"
  `include "classes/jtag_monitor.svh"

  // Sequencer.
  `include "classes/jtag_base_sequencer.svh"
  `include "classes/jtag_sequencer.svh"

  // Agent.
  `include "classes/jtag_base_agent.svh"
  `include "classes/jtag_agent.svh"
endpackage
