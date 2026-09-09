// Master-role concrete driver proxy: this agent acts as the active JTAG
// controller driving a DUT TAP (docs/architecture.md, "Objective"). For
// now this is a thin subclass of the generic jtag_driver_proxy, kept as
// its own class so master-specific driving behavior (multi-TAP chain
// navigation, IR-length-aware operations, etc.) can be added here without
// touching the generic proxy or jtag_driver_bfm.
//
// A slave-role driver proxy (this agent acting as the TAP being driven by
// an external master) is out of scope for now and would extend
// jtag_base_driver_proxy directly against a different, slave-role BFM.
class jtag_master_driver_proxy extends jtag_driver_proxy;
  function new(virtual jtag_driver_bfm bfm);
    super.new(bfm);
  endfunction
endclass
