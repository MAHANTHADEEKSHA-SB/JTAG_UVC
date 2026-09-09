// Consumes jtag_item requests and drives them through the proxy,
// completing the UVM request/response handshake. Holds no BFM handle of
// any kind: all pin- and timing-level work happens behind proxy.drive_txn().
class jtag_driver extends jtag_base_driver;
  `uvm_component_utils(jtag_driver)

  function new(string name = "jtag_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    jtag_item req;
    jtag_item rsp;

    forever begin
      seq_item_port.get_next_item(req);
      rsp = jtag_item::type_id::create("rsp");
      rsp.copy(req);
      rsp.set_id_info(req);

      proxy.drive_txn(rsp);

      seq_item_port.item_done(rsp);
    end
  endtask
endclass
