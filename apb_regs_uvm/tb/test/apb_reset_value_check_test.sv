// apb_reset_value_check_test.sv
class apb_reset_value_check_test extends apb_base_test;
  `uvm_component_utils(apb_reset_value_check_test)

  function new(string name = "apb_reset_value_check_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_reset_value_check_seq seq = apb_reset_value_check_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(env.agent.sequencer);
  endtask
endclass
