// Project extension point for sequence items. Marked virtual so all JTAG
// transactions go through a project-specific type rather than raw
// uvm_sequence_item.
virtual class jtag_base_sequence_item extends uvm_sequence_item;
  function new(string name = "jtag_base_sequence_item");
    super.new(name);
  endfunction
endclass
