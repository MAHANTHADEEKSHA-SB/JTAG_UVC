// Placeholder TAP used only to give the compile/smoke testbench something
// to wiggle TDO. It does not implement TAP state, IR/DR registers, or
// IEEE 1149.1 behavior, and must be replaced by a real TAP DUT before
// running the protocol-level checks in the validation plan
// (docs/architecture.md, step 4 onward).
module jtag_tap_stub (
  jtag_if.dut_mp jtag
);
  always @(posedge jtag.tck or negedge jtag.trst_n) begin
    if (!jtag.trst_n) jtag.tdo <= 1'b0;
    else               jtag.tdo <= jtag.tdi;
  end
endmodule
