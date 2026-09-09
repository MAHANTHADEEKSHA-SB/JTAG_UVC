// Project extension point for sequences.
class jtag_base_sequence extends uvm_sequence #(jtag_item);
  `uvm_object_utils(jtag_base_sequence)

  function new(string name = "jtag_base_sequence");
    super.new(name);
  endfunction
endclass
