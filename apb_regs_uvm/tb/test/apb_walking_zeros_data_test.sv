// apb_walking_zeros_data_test.sv
class apb_walking_zeros_data_test extends apb_base_test;
  `uvm_component_utils(apb_walking_zeros_data_test)

  function new(string name = "apb_walking_zeros_data_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_walking_zeros_data_seq seq = apb_walking_zeros_data_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(env.agent.sequencer);
  endtask
endclass
