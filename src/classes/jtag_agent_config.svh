// Per-instance agent settings and proxy handles. Testbench setup must
// publish this via uvm_config_db before UVM build so jtag_agent can
// retrieve and validate it (docs/architecture.md, "Instance binding and
// startup").
class jtag_agent_config extends uvm_object;
  `uvm_object_utils(jtag_agent_config)

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  int unsigned       ir_length           = 1;
  time                tck_period          = 100ns;
  jtag_reset_kind_e default_reset_kind = JTAG_RESET_TMS;

  // Required in active mode. Required in passive mode as well, since a
  // monitor is always built.
  jtag_base_driver_proxy  driver_proxy;
  jtag_base_monitor_proxy monitor_proxy;

  function new(string name = "jtag_agent_config");
    super.new(name);
  endfunction
endclass
