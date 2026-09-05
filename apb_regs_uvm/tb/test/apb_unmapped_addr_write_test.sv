// apb_unmapped_addr_write_test.sv
class apb_unmapped_addr_write_test extends apb_base_test;
  `uvm_component_utils(apb_unmapped_addr_write_test)

  function new(string name = "apb_unmapped_addr_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_unmapped_addr_write_seq seq = apb_unmapped_addr_write_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(env.agent.sequencer);
  endtask
endclass
