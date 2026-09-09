// Monitor BFM: independently reconstructs observed protocol activity from
// pins and never drives bus pins (docs/architecture.md, "BFM contracts
// and ownership"). A plain interface with no proxy logic of its own;
// src/classes/proxy/jtag_monitor_proxy.svh is the only class permitted to
// call these tasks. Publishes completed scans and reset events into a
// bounded mailbox; overflow raises an error rather than silently dropping
// activity (docs/architecture.md, "Observation buffering").
interface jtag_monitor_bfm
  import jtag_types_pkg::*;
(
  jtag_if.monitor_mp vif
);

  localparam int unsigned OBS_QUEUE_DEPTH = 64;
  mailbox #(jtag_observation_s) obs_q = new(OBS_QUEUE_DEPTH);

  jtag_tap_state_e cur_state   = TEST_LOGIC_RESET; // monitor's own observed state
  bit              state_known = 1'b0;

  bit tdi_buf[$];
  bit tdo_buf[$];

  task automatic publish(jtag_observation_s obs);
    if (!obs_q.try_put(obs))
      $error("jtag_monitor_bfm: observation queue overflow (depth=%0d); increase OBS_QUEUE_DEPTH or drain faster",
             OBS_QUEUE_DEPTH);
  endtask

  task automatic get_observation(output jtag_observation_s obs);
    obs_q.get(obs);
  endtask

  function automatic void handle_reset();
    jtag_observation_s obs;
    obs.obs_kind  = JTAG_OBS_RESET;
    obs.status    = state_known ? JTAG_STATUS_INTERRUPTED : JTAG_STATUS_OK;
    obs.timestamp = $time;
    publish(obs);
    cur_state   = TEST_LOGIC_RESET;
    state_known = 1'b1;
    tdi_buf.delete();
    tdo_buf.delete();
  endfunction

  initial begin
    forever begin
      @(negedge vif.trst_n);
      handle_reset();
      @(posedge vif.trst_n);
    end
  end

  initial begin
    forever begin
      jtag_tap_state_e nxt;
      @(posedge vif.tck);
      if (!state_known) continue; // ignore activity before the first observed reset

      nxt = jtag_tap_next_state(cur_state, vif.tms);

      if (cur_state inside {CAPTURE_IR, SHIFT_IR, CAPTURE_DR, SHIFT_DR}) begin
        if (cur_state == CAPTURE_IR || cur_state == CAPTURE_DR) begin
          tdi_buf.delete();
          tdo_buf.delete();
        end
        tdi_buf.push_back(vif.tdi);
        tdo_buf.push_back(vif.tdo);
      end

      if ((cur_state == SHIFT_IR || cur_state == SHIFT_DR) && nxt != cur_state) begin
        jtag_observation_s obs;
        obs.obs_kind  = JTAG_OBS_SCAN;
        obs.scan_kind = (cur_state == SHIFT_IR) ? JTAG_SCAN_IR : JTAG_SCAN_DR;
        obs.length    = tdi_buf.size();
        obs.tdi_data  = tdi_buf;
        obs.tdo_data  = tdo_buf;
        obs.status    = JTAG_STATUS_OK;
        obs.timestamp = $time;
        obs.end_state = nxt; // state reached immediately after the last shift bit
        publish(obs);
      end

      cur_state = nxt;
    end
  end
endinterface
