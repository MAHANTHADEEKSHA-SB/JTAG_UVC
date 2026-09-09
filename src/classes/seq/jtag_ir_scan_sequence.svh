// Issues a single IR scan; tdi_data is randomized by jtag_item itself.
class jtag_ir_scan_sequence extends jtag_base_sequence;
  `uvm_object_utils(jtag_ir_scan_sequence)

  rand int unsigned     length    = 4;
  rand jtag_tap_state_e end_state = RUN_TEST_IDLE;

  function new(string name = "jtag_ir_scan_sequence");
    super.new(name);
  endfunction

  task body();
    jtag_item item = jtag_item::type_id::create("item");
    start_item(item);
    if (!item.randomize() with {
      op_kind   == JTAG_OP_SCAN;
      scan_kind == JTAG_SCAN_IR;
      length    == local::length;
      end_state == local::end_state;
    }) `uvm_fatal("JTAG_IR_SEQ", "Randomization failed")
    finish_item(item);
  endtask
endclass
