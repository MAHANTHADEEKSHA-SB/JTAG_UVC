// Consumes jtag_item requests, invokes the driver proxy, and completes the
// UVM request/response handshake. Owns no pin- or timing-level behavior;
// that belongs to the driver BFM behind the proxy.
class jtag_driver extends jtag_base_driver;
  `uvm_component_utils(jtag_driver)

  protected jtag_agent_config      cfg;
  protected jtag_base_driver_proxy proxy;

  function new(string name = "jtag_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(jtag_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("JTAG_DRV_NOCFG", "jtag_agent_config not found in config_db")
    if (cfg.driver_proxy == null)
      `uvm_fatal("JTAG_DRV_NOPROXY", "jtag_agent_config.driver_proxy is not set")
    proxy = cfg.driver_proxy;
  endfunction

  task run_phase(uvm_phase phase);
    jtag_item req;
    jtag_item rsp;

    forever begin
      seq_item_port.get_next_item(req);
      rsp = jtag_item::type_id::create("rsp");
      rsp.copy(req);
      rsp.set_id_info(req);

      case (req.op_kind)
        JTAG_OP_RESET: begin
          proxy.reset(req.reset_kind, req.reset_cycles);
          rsp.status = JTAG_STATUS_OK;
        end

        JTAG_OP_SCAN: begin
          jtag_scan_req_s scan_req;
          jtag_scan_rsp_s scan_rsp;

          scan_req.kind      = req.scan_kind;
          scan_req.length    = req.length;
          scan_req.data      = req.tdi_data;
          scan_req.end_state = req.end_state;

          proxy.do_scan(scan_req, scan_rsp);

          rsp.tdo_data = scan_rsp.data;
          rsp.status   = scan_rsp.status;
        end

        default: `uvm_fatal("JTAG_DRV_BADOP", "Unknown jtag_item op_kind")
      endcase

      seq_item_port.item_done(rsp);
    end
  endtask
endclass
