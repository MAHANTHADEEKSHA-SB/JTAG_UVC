class jtag_sequencer extends jtag_base_sequencer;
  `uvm_component_utils(jtag_sequencer)

  function new(string name = "jtag_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
