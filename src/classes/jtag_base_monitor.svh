// Project extension point for the monitor.
class jtag_base_monitor extends uvm_monitor;
  `uvm_component_utils(jtag_base_monitor)

  function new(string name = "jtag_base_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
