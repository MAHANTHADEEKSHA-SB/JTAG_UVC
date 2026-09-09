// Minimal compile/bind testbench top (docs/architecture.md, validation
// plan step 1): instantiates the common interface, both BFMs, and binds
// their concrete proxies into jtag_agent_config before run_test().
`include "uvm_macros.svh"

import uvm_pkg::*;
import jtag_pkg::*;

`include "tests/jtag_smoke_test.svh"

module jtag_min_compile_tb;
  jtag_if dut_if();

  jtag_driver_bfm  drv_bfm (.vif(dut_if.driver_mp));
  jtag_monitor_bfm mon_bfm (.vif(dut_if.monitor_mp));
  jtag_tap_stub    dut     (.jtag(dut_if.dut_mp));

  initial begin
    jtag_agent_config  cfg       = jtag_agent_config::type_id::create("cfg");
    jtag_driver_proxy  drv_proxy = new(drv_bfm);
    jtag_monitor_proxy mon_proxy = new(mon_bfm);

    cfg.is_active  = UVM_ACTIVE;
    cfg.tck_period = 100ns;

    drv_bfm.configure(cfg.tck_period);
    cfg.driver_proxy  = drv_proxy;
    cfg.monitor_proxy = mon_proxy;

    uvm_config_db#(jtag_agent_config)::set(null, "*", "cfg", cfg);

    run_test("jtag_smoke_test");
  end
endmodule
