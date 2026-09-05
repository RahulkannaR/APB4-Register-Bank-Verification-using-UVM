// apb_readonly_write_attempt_test.sv
class apb_readonly_write_attempt_test extends apb_base_test;
  `uvm_component_utils(apb_readonly_write_attempt_test)

  function new(string name = "apb_readonly_write_attempt_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_readonly_write_attempt_seq seq = apb_readonly_write_attempt_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(env.agent.sequencer);
  endtask
endclass
