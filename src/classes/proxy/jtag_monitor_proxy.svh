// Generic concrete monitor proxy: translates jtag_monitor_bfm observations
// into jtag_item transactions. This is the only class that ever holds a
// handle to the monitor BFM.
//
// DUT- or instance-specific observation behavior does not require touching
// jtag_monitor_bfm or jtag_base_monitor: extend this class (its `bfm`
// handle is protected, not local, precisely so a subclass can reuse it)
// and override monitor_txn(), or extend jtag_base_monitor_proxy directly
// for a BFM of a different shape.
class jtag_monitor_proxy extends jtag_base_monitor_proxy;
  protected virtual jtag_monitor_bfm bfm;

  function new(virtual jtag_monitor_bfm bfm);
    this.bfm = bfm;
  endfunction

  task monitor_txn(output jtag_item txn);
    jtag_observation_s obs;

    bfm.get_observation(obs);

    txn = jtag_item::type_id::create("mon_txn");
    case (obs.obs_kind)
      JTAG_OBS_RESET: begin
        txn.op_kind = JTAG_OP_RESET;
        txn.status  = obs.status;
      end

      JTAG_OBS_SCAN: begin
        txn.op_kind   = JTAG_OP_SCAN;
        txn.scan_kind = obs.scan_kind;
        txn.length    = obs.length;
        txn.tdi_data  = obs.tdi_data;
        txn.tdo_data  = obs.tdo_data;
        txn.end_state = obs.end_state;
        txn.status    = obs.status;
      end

      default: `uvm_fatal("JTAG_MON_PROXY_BADOBS", "Unknown observation kind")
    endcase
  endtask
endclass
