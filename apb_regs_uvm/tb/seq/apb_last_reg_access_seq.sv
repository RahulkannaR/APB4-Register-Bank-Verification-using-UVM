// apb_last_reg_access_seq.sv
class apb_last_reg_access_seq extends apb_base_seq;
  `uvm_object_utils(apb_last_reg_access_seq)

  function new(string name = "apb_last_reg_access_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   wdata = 32'h1234_5678;
    bit [31:0]   rdata;
    int          idx;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    idx = reg_model.regs.size() - 1; // highest mapped index, derived not hardcoded

    reg_model.regs[idx].write(status, wdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (status != UVM_IS_OK)
      `uvm_error("SEQ_ERR", "write status not OK at last register")

    reg_model.regs[idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (status != UVM_IS_OK)
      `uvm_error("SEQ_ERR", "read status not OK at last register")

    if (rdata !== wdata)
      `uvm_error("SEQ_ERR", $sformatf(
        "last_reg_access MISMATCH at reg[%0d]: wrote 0x%08h, read 0x%08h", idx, wdata, rdata))
    else
      `uvm_info("SEQ_INFO", $sformatf("last_reg_access PASSED at reg[%0d]", idx), UVM_LOW)
  endtask
endclass
