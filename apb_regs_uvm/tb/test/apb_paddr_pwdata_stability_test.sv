// apb_paddr_pwdata_stability_test.sv
class apb_paddr_pwdata_stability_test extends apb_base_test;
  `uvm_component_utils(apb_paddr_pwdata_stability_test)
  function new(string name = "apb_paddr_pwdata_stability_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_test_body(uvm_phase phase);
    apb_paddr_pwdata_stability_seq seq = apb_paddr_pwdata_stability_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
  endtask
endclass
