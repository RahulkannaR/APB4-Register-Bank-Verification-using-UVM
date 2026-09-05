// apb_readonly_write_attempt_seq.sv
class apb_readonly_write_attempt_seq extends apb_base_seq;
  `uvm_object_utils(apb_readonly_write_attempt_seq)

  function new(string name = "apb_readonly_write_attempt_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   original, attempted, after_write;
    int          idx = 0; // reg[0] is RO per READ_ONLY_MASK = 8'b0000_0001

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    if (!reg_model.regs[idx].is_read_only)
      `uvm_fatal("SEQ_ERR", $sformatf("reg[%0d] is not RO — check READ_ONLY_MASK alignment", idx));

    // capture original value
    reg_model.regs[idx].read(status, original, UVM_FRONTDOOR, reg_model.apb_map, this);

    // attempt illegal write
    attempted = 32'hDEAD_BEEF;
    reg_model.regs[idx].write(status, attempted, UVM_FRONTDOOR, reg_model.apb_map, this);

    // confirm value unchanged
    reg_model.regs[idx].read(status, after_write, UVM_FRONTDOOR, reg_model.apb_map, this);

    if (after_write !== original)
      `uvm_error("SEQ_ERR", $sformatf(
        "RO VIOLATION: reg[%0d] changed from 0x%08h to 0x%08h after illegal write",
        idx, original, after_write))
    else
      `uvm_info("SEQ_INFO", "readonly_write_attempt PASSED — RO reg correctly protected", UVM_LOW)
  endtask
endclass
