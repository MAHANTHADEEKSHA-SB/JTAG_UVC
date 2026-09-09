// Abstract contract used by jtag_driver to reach a concrete BFM without
// depending on its interface type. Concrete implementations are nested
// classes inside each driver BFM interface (see src/jtag_driver_bfm.sv)
// and are bound into jtag_agent_config at the testbench top per the
// architecture's instance-binding flow (docs/architecture.md).
virtual class jtag_base_driver_proxy;
  pure virtual task reset(jtag_reset_kind_e kind, int unsigned cycles);
  pure virtual task do_scan(jtag_scan_req_s req, output jtag_scan_rsp_s rsp);
endclass
