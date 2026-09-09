// Standalone package for JTAG enums, structs, and TAP navigation
// utilities, kept free of any UVM dependency. Both the BFM interfaces
// (pin/timing level, src/jtag_driver_bfm.sv and src/jtag_monitor_bfm.sv)
// and jtag_pkg (UVM class level) import this, which is what lets
// jtag_pkg's concrete proxies hold a handle to a BFM interface without a
// circular dependency between "the package needs the interfaces" and
// "the interfaces need the package".
package jtag_types_pkg;
  `include "classes/jtag_types.svh"
endpackage
