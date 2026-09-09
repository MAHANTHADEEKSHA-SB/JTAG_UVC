// Abstract contract used by jtag_base_driver to drive a single
// transaction without depending on any concrete BFM type. jtag_item is a
// class handle, so drive_txn() fills in the response fields (tdo_data,
// status) directly on the object it is given rather than returning a
// separate response.
//
// Concrete implementations (e.g. src/classes/proxy/jtag_driver_proxy.svh)
// hold the BFM handle; this contract and jtag_base_driver never do, so the
// BFM can only ever be reached through a proxy.
virtual class jtag_base_driver_proxy;
  pure virtual task drive_txn(jtag_item txn);
endclass
