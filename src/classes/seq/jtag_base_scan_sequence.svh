// Common body for a single scan-type sequence (IR or DR): create one
// jtag_item, randomize it with the given scan kind/length/end_state, and
// send it. jtag_ir_scan_sequence and jtag_dr_scan_sequence only need to
// supply get_scan_kind(). This is a sequence-library convenience base, not
// one of the architecture's extension points; those live under
// src/classes/base/.
virtual class jtag_base_scan_sequence extends jtag_base_sequence;
  rand int unsigned     length    = 4;
  rand jtag_tap_state_e end_state = RUN_TEST_IDLE;

  function new(string name = "jtag_base_scan_sequence");
    super.new(name);
  endfunction

  pure virtual function jtag_scan_kind_e get_scan_kind();

  task body();
    jtag_item        item = jtag_item::type_id::create("item");
    jtag_scan_kind_e kind = get_scan_kind();

    start_item(item);
    if (!item.randomize() with {
      op_kind   == JTAG_OP_SCAN;
      scan_kind == local::kind;
      length    == local::length;
      end_state == local::end_state;
    }) `uvm_fatal("JTAG_SCAN_SEQ", "Randomization failed")
    finish_item(item);
  endtask
endclass
