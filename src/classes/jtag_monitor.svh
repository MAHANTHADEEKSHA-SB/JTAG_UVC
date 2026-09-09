// Obtains observations through the monitor proxy and publishes them as
// jtag_item transactions on an analysis port. Never drives bus pins;
// pin-level observation belongs to the monitor BFM behind the proxy.
class jtag_monitor extends jtag_base_monitor;
  `uvm_component_utils(jtag_monitor)

  uvm_analysis_port #(jtag_item) ap;

  protected jtag_agent_config       cfg;
  protected jtag_base_monitor_proxy proxy;

  function new(string name = "jtag_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(jtag_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("JTAG_MON_NOCFG", "jtag_agent_config not found in config_db")
    if (cfg.monitor_proxy == null)
      `uvm_fatal("JTAG_MON_NOPROXY", "jtag_agent_config.monitor_proxy is not set")
    proxy = cfg.monitor_proxy;
  endfunction

  task run_phase(uvm_phase phase);
    jtag_observation_s obs;
    jtag_item           item;

    forever begin
      proxy.get_observation(obs);
      item = jtag_item::type_id::create("mon_item");

      case (obs.obs_kind)
        JTAG_OBS_RESET: begin
          item.op_kind = JTAG_OP_RESET;
          item.status  = obs.status;
        end

        JTAG_OBS_SCAN: begin
          item.op_kind   = JTAG_OP_SCAN;
          item.scan_kind = obs.scan_kind;
          item.length    = obs.length;
          item.tdi_data  = obs.tdi_data;
          item.tdo_data  = obs.tdo_data;
          item.end_state = obs.end_state;
          item.status    = obs.status;
        end

        default: `uvm_warning("JTAG_MON_UNDEF", "Observed undefined/unknown TAP activity")
      endcase

      ap.write(item);
    end
  endtask
endclass
