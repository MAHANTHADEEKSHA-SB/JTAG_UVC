// Common driver base: retrieves jtag_agent_config and validates/stores the
// driver proxy handle. Concrete drivers (src/classes/jtag_driver.svh) only
// implement run_phase against the inherited `proxy` handle; neither this
// class nor any derived driver ever references a BFM directly.
class jtag_base_driver extends uvm_driver #(jtag_item);
  `uvm_component_utils(jtag_base_driver)

  protected jtag_agent_config      cfg;
  protected jtag_base_driver_proxy proxy;

  function new(string name = "jtag_base_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(jtag_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("JTAG_DRV_NOCFG", "jtag_agent_config not found in config_db")
    if (cfg.driver_proxy == null)
      `uvm_fatal("JTAG_DRV_NOPROXY", "jtag_agent_config.driver_proxy is not set")
    proxy = cfg.driver_proxy;
  endfunction
endclass
