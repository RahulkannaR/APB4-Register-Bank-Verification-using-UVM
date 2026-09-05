// apb_reset_then_immediate_write_test.sv
class apb_reset_then_immediate_write_test extends apb_base_test;
  `uvm_component_utils(apb_reset_then_immediate_write_test)
  function new(string name = "apb_reset_then_immediate_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_reset_then_immediate_write_seq seq;
	apb_ral_read_check_seq             check_seq;
    uvm_status_e status;
    bit [31:0] rdata;

    // run_phase already did power-on reset + 1 cycle settle (base_test);
    // fire the write with NO additional delay — as immediate as possible
    seq = apb_reset_then_immediate_write_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);

	check_seq = apb_ral_read_check_seq::type_id::create("check_seq");
    check_seq.reg_model = env.reg_model;
    check_seq.reg_idx   = 4;
    check_seq.expected  = 32'h1111_2222;
    check_seq.start(env.agent.sequencer);

    endtask
endclass
