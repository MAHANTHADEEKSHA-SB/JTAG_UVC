// Driver BFM: owns controller-side pin driving, TCK generation, TAP
// navigation, and operation-level scan/reset execution
// (docs/architecture.md, "BFM contracts and ownership"). A plain
// interface with no proxy logic of its own; src/classes/proxy/jtag_driver_proxy.svh
// is the only class permitted to call these tasks.
interface jtag_driver_bfm
  import jtag_types_pkg::*;
(
  jtag_if.driver_mp vif
);

  time              tck_period = 100ns;
  jtag_tap_state_e  cur_state  = TEST_LOGIC_RESET; // driver's own predicted state

  initial begin
    vif.tck    = 1'b0;
    vif.tms    = 1'b1;
    vif.tdi    = 1'b0;
    vif.trst_n = 1'b1;
  end

  function automatic void configure(time period);
    tck_period = period;
  endfunction

  // Drives one TCK pulse with the given TMS/TDI, sampling TDO after the
  // falling edge, and advances the predicted TAP state.
  task automatic pulse_tck(bit tms_val, bit tdi_val, output bit tdo_val);
    vif.tck = 1'b0;
    vif.tms = tms_val;
    vif.tdi = tdi_val;
    #(tck_period / 2);
    vif.tck = 1'b1;
    #(tck_period / 2);
    vif.tck = 1'b0;
    tdo_val = vif.tdo;
    cur_state = jtag_tap_next_state(cur_state, tms_val);
  endtask

  task automatic walk_path(bit tms_path[$]);
    bit unused_tdo;
    foreach (tms_path[i]) pulse_tck(tms_path[i], 1'b0, unused_tdo);
  endtask

  task automatic apply_reset(jtag_reset_kind_e kind, int unsigned cycles);
    bit unused_tdo;
    case (kind)
      JTAG_RESET_TMS: begin
        repeat (cycles) pulse_tck(1'b1, 1'b0, unused_tdo);
        cur_state = TEST_LOGIC_RESET;
      end
      JTAG_RESET_TRST: begin
        vif.trst_n = 1'b0;
        repeat (2) pulse_tck(1'b1, 1'b0, unused_tdo);
        vif.trst_n = 1'b1;
        cur_state = TEST_LOGIC_RESET;
      end
      default: $fatal(1, "jtag_driver_bfm: unknown reset kind");
    endcase
  endtask

  // Operation-level scan: navigate to SHIFT_IR/SHIFT_DR, shift `length`
  // bits (last bit's TMS=1 exits to EXIT1_*), then navigate to
  // req.end_state.
  task automatic do_scan(input jtag_scan_req_s req, output jtag_scan_rsp_s rsp);
    jtag_tap_state_e shift_state;
    bit              tms_path[$];
    bit              tdo_bit;

    rsp.kind   = req.kind;
    rsp.length = req.length;
    rsp.data   = new[req.length];
    rsp.status = JTAG_STATUS_OK;

    shift_state = (req.kind == JTAG_SCAN_IR) ? SHIFT_IR : SHIFT_DR;

    jtag_tap_compute_path(cur_state, shift_state, tms_path);
    walk_path(tms_path);

    for (int unsigned i = 0; i < req.length; i++) begin
      bit last = (i == req.length - 1);
      pulse_tck(last, req.data[i], tdo_bit);
      rsp.data[i] = tdo_bit;
    end

    jtag_tap_compute_path(cur_state, req.end_state, tms_path);
    walk_path(tms_path);
  endtask
endinterface
