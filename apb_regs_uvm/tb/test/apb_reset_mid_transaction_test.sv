class apb_reset_mid_transaction_test extends apb_base_test;
  `uvm_component_utils(apb_reset_mid_transaction_test)
  function new(string name = "apb_reset_mid_transaction_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

 function void build_phase(uvm_phase phase);
    uvm_config_db#(bit)::set(null, "*.agent.driver", "enable_reset_watch", 1);
    super.build_phase(phase);   // this is what actually creates env -> agent -> driver
  endfunction 

  task run_test_body(uvm_phase phase);
    apb_reset_mid_transaction_seq seq = apb_reset_mid_transaction_seq::type_id::create("seq");
    apb_ral_read_check_seq check_seq = apb_ral_read_check_seq::type_id::create("check_seq");

    check_seq.reg_model = env.reg_model;
    check_seq.reg_idx   = 2;              // CHANGED: matches send_raw's addr(0x08)
    check_seq.expected  = 32'h0000_0000;  // CHANGED: write should NOT have landed

    fork
      seq.start(env.agent.sequencer);
      check_seq.start(env.agent.sequencer);
      begin
        #12ns;
        env.reset_driver.assert_reset(5);
        env.reset_driver.deassert_reset();
      end
    join

    `uvm_info("TEST_INFO", "reset_mid_transaction: clean recovery confirmed", UVM_LOW)
  endtask
endclass
