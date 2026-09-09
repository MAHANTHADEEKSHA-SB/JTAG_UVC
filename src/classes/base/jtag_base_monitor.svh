// Common monitor base: retrieves jtag_agent_config and validates/stores
// the monitor proxy handle. Concrete monitors (src/classes/jtag_monitor.svh)
// only implement run_phase against the inherited `proxy` handle; neither
// this class nor any derived monitor ever references a BFM directly.
class jtag_base_monitor extends uvm_monitor;
  `uvm_component_utils(jtag_base_monitor)

  protected jtag_agent_config       cfg;
  protected jtag_base_monitor_proxy proxy;

  function new(string name = "jtag_base_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(jtag_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("JTAG_MON_NOCFG", "jtag_agent_config not found in config_db")
    if (cfg.monitor_proxy == null)
      `uvm_fatal("JTAG_MON_NOPROXY", "jtag_agent_config.monitor_proxy is not set")
    proxy = cfg.monitor_proxy;
  endfunction
endclass
