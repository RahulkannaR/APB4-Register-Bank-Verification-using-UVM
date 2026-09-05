// apb_back_to_back_reset_pulses_seq.sv
// No bus activity in this sequence — reset control happens entirely in the
// test class via env.reset_driver, mirroring reset_mid_transaction's pattern.
class apb_back_to_back_reset_pulses_seq extends apb_base_seq;
  `uvm_object_utils(apb_back_to_back_reset_pulses_seq)
  function new(string name = "apb_back_to_back_reset_pulses_seq"); super.new(name); endfunction

  task body();
    // Post-pulse sanity read — confirms DUT is alive and correctly reset
    uvm_status_e status;
    bit [31:0] rdata;
    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");
    reg_model.regs[4].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (rdata !== 32'h0)
      `uvm_error("SEQ_ERR", $sformatf("post-pulse reg[4] not reset: 0x%08h", rdata))
    else
      `uvm_info("SEQ_INFO", "back_to_back_reset_pulses: DUT alive & clean post-pulses", UVM_LOW)
  endtask
endclass
