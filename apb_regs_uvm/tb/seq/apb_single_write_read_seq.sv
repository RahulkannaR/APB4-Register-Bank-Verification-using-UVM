// apb_single_write_read_seq.sv
class apb_single_write_read_seq extends apb_base_seq;
  `uvm_object_utils(apb_single_write_read_seq)

  function new(string name = "apb_single_write_read_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   wdata = 32'hCAFE_BABE;
    bit [31:0]   rdata;
    int          idx = 2; // reg[2] — writable, safe default per READ_ONLY_MASK

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set — assign in test before start()")

    reg_model.regs[idx].write(status, wdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (status != UVM_IS_OK)
      `uvm_error("SEQ_ERR", "write status not OK")

    reg_model.regs[idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (status != UVM_IS_OK)
      `uvm_error("SEQ_ERR", "read status not OK")

    if (rdata !== wdata)
      `uvm_error("SEQ_ERR", $sformatf("MISMATCH: wrote 0x%08h, read 0x%08h", wdata, rdata))
    else
      `uvm_info("SEQ_INFO", "single_write_read PASSED", UVM_LOW)
  endtask
endclass
