// Issues a single IR scan; tdi_data is randomized by jtag_item itself.
class jtag_ir_scan_sequence extends jtag_base_scan_sequence;
  `uvm_object_utils(jtag_ir_scan_sequence)

  function new(string name = "jtag_ir_scan_sequence");
    super.new(name);
  endfunction

  function jtag_scan_kind_e get_scan_kind();
    return JTAG_SCAN_IR;
  endfunction
endclass
