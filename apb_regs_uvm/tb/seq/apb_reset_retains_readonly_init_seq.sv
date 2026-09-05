// apb_reset_retains_readonly_init_seq.sv
class apb_reset_retains_readonly_init_seq extends apb_base_seq;
  `uvm_object_utils(apb_reset_retains_readonly_init_seq)
  function new(string name = "apb_reset_retains_readonly_init_seq"); super.new(name); endfunction

  // Phase 1: scribble over every register (RW gets real writes, RO gets an
  // illegal write attempt) — called BEFORE reset in the test
  task scribble();
    uvm_status_e status;
    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");
    foreach (reg_model.regs[i])
      reg_model.regs[i].write(status, 32'hDEAD_DEAD, UVM_FRONTDOOR, reg_model.apb_map, this);
  endtask

  // Phase 2: verify every register back to init — called AFTER reset
  task body();
    uvm_status_e status;
    bit [31:0] rdata;
    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");
    foreach (reg_model.regs[i]) begin
      reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      if (rdata !== 32'h0)
        `uvm_error("SEQ_ERR", $sformatf("reg[%0d] not at init post-reset: 0x%08h", i, rdata))
    end
    `uvm_info("SEQ_INFO", "reset_retains_readonly_init verified across full map", UVM_LOW)
  endtask
endclass
