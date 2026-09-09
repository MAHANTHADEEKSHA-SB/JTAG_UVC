// Project extension point for the sequencer.
class jtag_base_sequencer extends uvm_sequencer #(jtag_item);
  `uvm_component_utils(jtag_base_sequencer)

  function new(string name = "jtag_base_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
