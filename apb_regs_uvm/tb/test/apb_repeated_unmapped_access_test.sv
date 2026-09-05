// apb_repeated_unmapped_access_test.sv
class apb_repeated_unmapped_access_test extends apb_base_test;
  `uvm_component_utils(apb_repeated_unmapped_access_test)
  function new(string name = "apb_repeated_unmapped_access_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_repeated_unmapped_access_seq seq = apb_repeated_unmapped_access_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
