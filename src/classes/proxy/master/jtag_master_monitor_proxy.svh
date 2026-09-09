// Master-role concrete monitor proxy: observes the DUT TAP while this
// agent drives it as the active JTAG controller (docs/architecture.md,
// "Objective"). For now this is a thin subclass of the generic
// jtag_monitor_proxy, kept as its own class so master-specific
// observation behavior can be added here without touching the generic
// proxy or jtag_monitor_bfm.
//
// A slave-role monitor proxy is out of scope for now and would extend
// jtag_base_monitor_proxy directly against a different, slave-role BFM.
class jtag_master_monitor_proxy extends jtag_monitor_proxy;
  function new(virtual jtag_monitor_bfm bfm);
    super.new(bfm);
  endfunction
endclass
