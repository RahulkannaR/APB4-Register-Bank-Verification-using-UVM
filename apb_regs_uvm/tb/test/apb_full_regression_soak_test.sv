// apb_full_regression_soak_test.sv
class apb_full_regression_soak_test extends apb_base_test;
  `uvm_component_utils(apb_full_regression_soak_test)
  function new(string name = "apb_full_regression_soak_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_full_regression_soak_seq seq = apb_full_regression_soak_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
