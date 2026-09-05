// apb_reset_retains_readonly_init_test.sv
class apb_reset_retains_readonly_init_test extends apb_base_test;
  `uvm_component_utils(apb_reset_retains_readonly_init_test)
  function new(string name = "apb_reset_retains_readonly_init_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_reset_retains_readonly_init_seq seq = apb_reset_retains_readonly_init_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;

    seq.scribble();                          // corrupt everything first
    env.reset_driver.assert_reset(5);        // then reset
    env.reset_driver.deassert_reset();
    @(posedge env.agent.monitor.vif.pclk);

    seq.start(env.agent.sequencer);          // verify clean init
  endtask
endclass
