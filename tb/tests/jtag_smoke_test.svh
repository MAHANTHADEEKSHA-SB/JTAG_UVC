// Minimal smoke test: builds one active jtag_agent and issues a reset, an
// IR scan, and a DR scan. Covers validation-plan step 1 (compile and
// bind) and a first pass at step 4 (basic scans); it does not check
// captured data against independent expectations (step 5) or exercise
// interrupted/reset-during-scan behavior (step 6).
class jtag_smoke_test extends uvm_test;
  `uvm_component_utils(jtag_smoke_test)

  jtag_agent agent;

  function new(string name = "jtag_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = jtag_agent::type_id::create("agent", this);
  endfunction

  task run_phase(uvm_phase phase);
    jtag_reset_sequence   reset_seq = jtag_reset_sequence::type_id::create("reset_seq");
    jtag_ir_scan_sequence ir_seq    = jtag_ir_scan_sequence::type_id::create("ir_seq");
    jtag_dr_scan_sequence dr_seq    = jtag_dr_scan_sequence::type_id::create("dr_seq");

    phase.raise_objection(this);

    reset_seq.reset_kind   = JTAG_RESET_TMS;
    reset_seq.reset_cycles = 5;
    reset_seq.start(agent.sequencer);

    ir_seq.length = 4;
    ir_seq.start(agent.sequencer);

    dr_seq.length = 8;
    dr_seq.start(agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass
