// Common JTAG signal interface: TCK, TMS, TDI, TDO and an optional TRST.
// One instance is shared by the driver BFM, the monitor BFM, and the DUT
// TAP, each connecting through the modport matching its role.
interface jtag_if;
  logic tck;
  logic tms;
  logic tdi;
  logic tdo;
  logic trst_n; // optional; drive 1'b1 continuously if the DUT has no dedicated TRST pin

  modport driver_mp  (output tck, output tms, output tdi, input  tdo, output trst_n);
  modport monitor_mp (input  tck, input  tms, input  tdi, input  tdo, input  trst_n);
  modport dut_mp     (input  tck, input  tms, input  tdi, output tdo, input  trst_n);
endinterface
