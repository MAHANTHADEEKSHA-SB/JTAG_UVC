// Issues a single reset operation (TMS or TRST based).
class jtag_reset_sequence extends jtag_base_sequence;
  `uvm_object_utils(jtag_reset_sequence)

  rand jtag_reset_kind_e reset_kind   = JTAG_RESET_TMS;
  rand int unsigned      reset_cycles = 5;

  function new(string name = "jtag_reset_sequence");
    super.new(name);
  endfunction

  task body();
    jtag_item item = jtag_item::type_id::create("item");
    start_item(item);
    if (!item.randomize() with {
      op_kind      == JTAG_OP_RESET;
      reset_kind   == local::reset_kind;
      reset_cycles == local::reset_cycles;
    }) `uvm_fatal("JTAG_RESET_SEQ", "Randomization failed")
    finish_item(item);
  endtask
endclass
