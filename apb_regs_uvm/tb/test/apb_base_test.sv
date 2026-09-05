//-----------------------------------------------------------------------------
// apb_base_test.sv
// Builds the env and hands each derived test a common place to start.
// Derived tests override run_test_body() — base handles objections + reporting.
//-----------------------------------------------------------------------------
class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  apb_env env;
  apb_reg_block reg_model;

  function new(string name = "apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "apb_base_test running");
	env.reset_driver.assert_reset(5);
    env.reset_driver.deassert_reset();
    @(posedge env.agent.monitor.vif.pclk); // let reset settle one cycle
    run_test_body(phase);
    phase.drop_objection(this, "apb_base_test done");
  endtask

  // Derived tests override this — base does nothing on its own
  virtual task run_test_body(uvm_phase phase);
    `uvm_info("BASE_TEST", "No test body defined — override run_test_body()", UVM_LOW)
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_ERROR) == 0)
      `uvm_info("TEST_RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("TEST_RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction

endclass
