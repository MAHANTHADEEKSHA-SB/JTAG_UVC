// Project extension point for the agent.
class jtag_base_agent extends uvm_agent;
  `uvm_component_utils(jtag_base_agent)

  function new(string name = "jtag_base_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
