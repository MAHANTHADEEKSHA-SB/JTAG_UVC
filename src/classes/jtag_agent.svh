// Builds and connects the sequencer/driver/monitor, enabling the
// sequencer/driver only in active mode. Validates the required proxy
// handles from configuration and fails with a clear fatal error if either
// is missing (docs/architecture.md, "Instance binding and startup").
class jtag_agent extends jtag_base_agent;
  `uvm_component_utils(jtag_agent)

  jtag_agent_config cfg;
  jtag_sequencer    sequencer;
  jtag_driver       driver;
  jtag_monitor      monitor;

  function new(string name = "jtag_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(jtag_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("JTAG_AGT_NOCFG", "jtag_agent_config not found in config_db")

    is_active = cfg.is_active;

    if (cfg.monitor_proxy == null)
      `uvm_fatal("JTAG_AGT_NOMONPROXY", "jtag_agent_config.monitor_proxy is not set")
    uvm_config_db#(jtag_agent_config)::set(this, "monitor", "cfg", cfg);
    monitor = jtag_monitor::type_id::create("monitor", this);

    if (is_active == UVM_ACTIVE) begin
      if (cfg.driver_proxy == null)
        `uvm_fatal("JTAG_AGT_NODRVPROXY",
                    "jtag_agent_config.driver_proxy is not set for an active agent")
      uvm_config_db#(jtag_agent_config)::set(this, "driver", "cfg", cfg);
      sequencer = jtag_sequencer::type_id::create("sequencer", this);
      driver    = jtag_driver::type_id::create("driver", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass
