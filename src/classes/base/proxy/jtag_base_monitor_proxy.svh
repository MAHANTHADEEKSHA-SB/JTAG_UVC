// Abstract contract used by jtag_base_monitor to obtain a single observed
// transaction without depending on any concrete BFM type. monitor_txn()
// blocks until the BFM has an observation ready (scan completion or
// reset) and must report interrupted/reset activity, not only successful
// completions.
//
// Concrete implementations (e.g. src/classes/proxy/jtag_monitor_proxy.svh)
// hold the BFM handle; this contract and jtag_base_monitor never do, so
// the BFM can only ever be reached through a proxy.
virtual class jtag_base_monitor_proxy;
  pure virtual task monitor_txn(output jtag_item txn);
endclass
