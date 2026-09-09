// Single transaction type used for driver requests/responses and, reused,
// for published monitor observations. Splitting request/response/
// observation into separate types is a documented open option
// (docs/architecture.md) if this shared type becomes limiting.
class jtag_item extends jtag_base_sequence_item;
  `uvm_object_utils(jtag_item)

  rand jtag_op_kind_e op_kind;

  // Reset operation fields.
  rand jtag_reset_kind_e reset_kind;
  rand int unsigned      reset_cycles;

  // Scan operation fields (request).
  rand jtag_scan_kind_e scan_kind;
  rand int unsigned     length;
  rand bit              tdi_data[];
  rand jtag_tap_state_e end_state;

  // Response/observation fields, filled in by the driver or monitor.
  bit            tdo_data[];
  jtag_status_e  status;

  constraint c_length_nonzero {
    op_kind == JTAG_OP_SCAN -> length > 0;
  }

  constraint c_tdi_data_size {
    op_kind == JTAG_OP_SCAN -> tdi_data.size() == length;
  }

  constraint c_legal_end_state {
    op_kind == JTAG_OP_SCAN -> end_state inside {RUN_TEST_IDLE, PAUSE_IR, PAUSE_DR};
  }

  function new(string name = "jtag_item");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    jtag_item rhs_;
    if (!$cast(rhs_, rhs)) `uvm_fatal("JTAG_ITEM_COPY", "do_copy: cast failed")
    super.do_copy(rhs);
    op_kind      = rhs_.op_kind;
    reset_kind   = rhs_.reset_kind;
    reset_cycles = rhs_.reset_cycles;
    scan_kind    = rhs_.scan_kind;
    length       = rhs_.length;
    tdi_data     = rhs_.tdi_data;
    end_state    = rhs_.end_state;
    tdo_data     = rhs_.tdo_data;
    status       = rhs_.status;
  endfunction

  function string convert2string();
    case (op_kind)
      JTAG_OP_RESET: return $sformatf("JTAG RESET kind=%s cycles=%0d",
                                       reset_kind.name(), reset_cycles);
      JTAG_OP_SCAN:  return $sformatf("JTAG %s len=%0d end=%s status=%s",
                                       scan_kind.name(), length, end_state.name(), status.name());
      default:       return "JTAG <uninitialized>";
    endcase
  endfunction
endclass
