// apb_out_of_range_low_test.sv
class apb_out_of_range_low_test extends apb_base_test;
  `uvm_component_utils(apb_out_of_range_low_test)
  function new(string name = "apb_out_of_range_low_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_out_of_range_low_seq seq = apb_out_of_range_low_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
