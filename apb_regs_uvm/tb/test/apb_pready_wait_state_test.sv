// apb_pready_wait_state_test.sv
class apb_pready_wait_state_test extends apb_base_test;
  `uvm_component_utils(apb_pready_wait_state_test)
  function new(string name = "apb_pready_wait_state_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_pready_wait_state_seq seq = apb_pready_wait_state_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
