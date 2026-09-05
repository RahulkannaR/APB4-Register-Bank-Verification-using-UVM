// apb_back_to_back_reset_pulses_test.sv
class apb_back_to_back_reset_pulses_test extends apb_base_test;
  `uvm_component_utils(apb_back_to_back_reset_pulses_test)
  function new(string name = "apb_back_to_back_reset_pulses_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_test_body(uvm_phase phase);
    apb_back_to_back_reset_pulses_seq seq;

    // Fire 4 rapid reset pulses, 2 cycles apart, before running the sanity check
    repeat (4) begin
      env.reset_driver.assert_reset(2);
      env.reset_driver.deassert_reset();
      #10ns; // minimal 1-cycle gap between pulses
    end

    seq = apb_back_to_back_reset_pulses_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(env.agent.sequencer);
  endtask
endclass
