// apb_same_reg_repeated_access_seq.sv
class apb_same_reg_repeated_access_seq extends apb_base_seq;
  `uvm_object_utils(apb_same_reg_repeated_access_seq)
  function new(string name = "apb_same_reg_repeated_access_seq"); super.new(name); endfunction

  task body();
    uvm_status_e status;
    bit [31:0] wdata, rdata;
    int idx = 3;
    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");

    for (int i = 0; i < 50; i++) begin
      wdata = $urandom();
      reg_model.regs[idx].write(status, wdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      reg_model.regs[idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      if (rdata !== wdata)
        `uvm_error("SEQ_ERR", $sformatf("repeated_access iter %0d FAIL: exp=0x%08h got=0x%08h", i, wdata, rdata))
    end
    `uvm_info("SEQ_INFO", "same_reg_repeated_access complete (50 iterations)", UVM_LOW)
  endtask
endclass
