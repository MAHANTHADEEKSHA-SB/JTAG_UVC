// Shared package: common enums/structs (re-exported from jtag_types_pkg),
// abstract proxy contracts, base classes, and concrete UVM classes,
// included in an explicit dependency order (docs/architecture.md,
// "Parameters, packages, and runtime configuration"). Not instantiated
// with per-agent parameter overrides; per-instance values live in
// jtag_agent_config instead.
//
// Depends on jtag_driver_bfm and jtag_monitor_bfm (for the concrete
// proxies' virtual-interface handles), so those two interfaces must be
// compiled before this package; see files.f.
package jtag_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import jtag_types_pkg::*;
  export jtag_types_pkg::*;

  // Forward declarations for every class in this package, so a field,
  // pure-virtual argument, or other bare type reference never depends on
  // `include order below.
  //
  // This does NOT relax `extends`: a derived class still requires its
  // base class's full body to already be compiled, and any method body
  // that touches another class's members still requires that class to be
  // fully defined first. The `include order below still walks each
  // inheritance chain base-before-derived (jtag_base_sequence_item before
  // jtag_item, jtag_base_driver_proxy before jtag_driver_proxy before
  // jtag_master_driver_proxy, and so on) for that reason; only the
  // "declared as a plain handle/type" references are order-independent.
  typedef class jtag_item;
  typedef class jtag_base_driver_proxy;
  typedef class jtag_base_monitor_proxy;
  typedef class jtag_agent_config;
  typedef class jtag_base_sequence_item;
  typedef class jtag_base_sequence;
  typedef class jtag_base_driver;
  typedef class jtag_base_monitor;
  typedef class jtag_base_sequencer;
  typedef class jtag_base_agent;
  typedef class jtag_driver_proxy;
  typedef class jtag_monitor_proxy;
  typedef class jtag_master_driver_proxy;
  typedef class jtag_master_monitor_proxy;
  typedef class jtag_base_scan_sequence;
  typedef class jtag_reset_sequence;
  typedef class jtag_ir_scan_sequence;
  typedef class jtag_dr_scan_sequence;
  typedef class jtag_driver;
  typedef class jtag_monitor;
  typedef class jtag_sequencer;
  typedef class jtag_agent;

  // Sequence item (needed by name in the base classes below).
  `include "classes/base/jtag_base_sequence_item.svh"
  `include "classes/jtag_item.svh"

  // Abstract proxy contracts, extension points implemented by concrete
  // proxies further below. Neither these nor any other base class ever
  // references a BFM directly.
  `include "classes/base/proxy/jtag_base_driver_proxy.svh"
  `include "classes/base/proxy/jtag_base_monitor_proxy.svh"

  // Agent configuration (holds the two proxy handles above).
  `include "classes/jtag_agent_config.svh"

  // Remaining base classes: the architecture's other extension points
  // (sequence, driver, monitor, sequencer, agent).
  `include "classes/base/jtag_base_sequence.svh"
  `include "classes/base/jtag_base_driver.svh"
  `include "classes/base/jtag_base_monitor.svh"
  `include "classes/base/jtag_base_sequencer.svh"
  `include "classes/base/jtag_base_agent.svh"

  // Concrete proxies: the only classes permitted to hold a BFM handle.
  `include "classes/proxy/jtag_driver_proxy.svh"
  `include "classes/proxy/jtag_monitor_proxy.svh"

  // Role-specific proxies. Master role only for now; a slave role would
  // add its own proxy/BFM pair alongside these later.
  `include "classes/proxy/master/jtag_master_driver_proxy.svh"
  `include "classes/proxy/master/jtag_master_monitor_proxy.svh"

  // Sequences.
  `include "classes/seq/jtag_base_scan_sequence.svh"
  `include "classes/seq/jtag_reset_sequence.svh"
  `include "classes/seq/jtag_ir_scan_sequence.svh"
  `include "classes/seq/jtag_dr_scan_sequence.svh"

  // Driver, monitor, sequencer, agent.
  `include "classes/jtag_driver.svh"
  `include "classes/jtag_monitor.svh"
  `include "classes/jtag_sequencer.svh"
  `include "classes/jtag_agent.svh"
endpackage
