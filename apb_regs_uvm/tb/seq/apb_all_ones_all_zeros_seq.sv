// apb_all_ones_all_zeros_seq.sv
class apb_all_ones_all_zeros_seq extends apb_base_seq;
  `uvm_object_utils(apb_all_ones_all_zeros_seq)
  function new(string name = "apb_all_ones_all_zeros_seq"); super.new(name); endfunction

  task body();
    uvm_status_e status;
    bit [31:0] rdata;
    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");

    foreach (reg_model.regs[i]) begin
      if (reg_model.regs[i].is_read_only) continue;

      reg_model.regs[i].write(status, 32'hFFFF_FFFF, UVM_FRONTDOOR, reg_model.apb_map, this);
      reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      if (rdata !== 32'hFFFF_FFFF)
        `uvm_error("SEQ_ERR", $sformatf("reg[%0d] all-ones FAIL: got 0x%08h", i, rdata))

      reg_model.regs[i].write(status, 32'h0000_0000, UVM_FRONTDOOR, reg_model.apb_map, this);
      reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      if (rdata !== 32'h0000_0000)
        `uvm_error("SEQ_ERR", $sformatf("reg[%0d] all-zeros FAIL: got 0x%08h", i, rdata))
    end
    `uvm_info("SEQ_INFO", "all_ones_all_zeros sweep complete", UVM_LOW)
  endtask
endclass
