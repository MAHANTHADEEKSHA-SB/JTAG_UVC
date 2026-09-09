// Obtains transactions through the proxy and publishes them on an
// analysis port. Holds no BFM handle of any kind: all pin-level
// observation happens behind proxy.monitor_txn().
class jtag_monitor extends jtag_base_monitor;
  `uvm_component_utils(jtag_monitor)

  uvm_analysis_port #(jtag_item) ap;

  function new(string name = "jtag_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    jtag_item txn;

    forever begin
      proxy.monitor_txn(txn);
      ap.write(txn);
    end
  endtask
endclass
