// Generic concrete driver proxy: translates a jtag_item into
// jtag_driver_bfm calls and fills in its response fields in place. This is
// the only class that ever holds a handle to the driver BFM.
//
// DUT- or instance-specific driving behavior does not require touching
// jtag_driver_bfm or jtag_base_driver: extend this class (its `bfm` handle
// is protected, not local, precisely so a subclass can reuse it) and
// override drive_txn(), or extend jtag_base_driver_proxy directly for a
// BFM of a different shape. Either way the extended proxy's constructor is
// free to take whatever additional parameters that instance needs.
class jtag_driver_proxy extends jtag_base_driver_proxy;
  protected virtual jtag_driver_bfm bfm;

  function new(virtual jtag_driver_bfm bfm);
    this.bfm = bfm;
  endfunction

  task drive_txn(jtag_item txn);
    case (txn.op_kind)
      JTAG_OP_RESET: begin
        bfm.apply_reset(txn.reset_kind, txn.reset_cycles);
        txn.status = JTAG_STATUS_OK;
      end

      JTAG_OP_SCAN: begin
        jtag_scan_req_s scan_req;
        jtag_scan_rsp_s scan_rsp;

        scan_req.kind      = txn.scan_kind;
        scan_req.length    = txn.length;
        scan_req.data      = txn.tdi_data;
        scan_req.end_state = txn.end_state;

        bfm.do_scan(scan_req, scan_rsp);

        txn.tdo_data = scan_rsp.data;
        txn.status   = scan_rsp.status;
      end

      default: `uvm_fatal("JTAG_DRV_PROXY_BADOP", "Unknown jtag_item op_kind")
    endcase
  endtask
endclass
