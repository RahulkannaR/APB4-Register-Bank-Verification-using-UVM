// apb_random_with_idle_gaps_test.sv
class apb_random_with_idle_gaps_test extends apb_base_test;
  `uvm_component_utils(apb_random_with_idle_gaps_test)
  function new(string name = "apb_random_with_idle_gaps_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_random_with_idle_gaps_seq seq = apb_random_with_idle_gaps_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
