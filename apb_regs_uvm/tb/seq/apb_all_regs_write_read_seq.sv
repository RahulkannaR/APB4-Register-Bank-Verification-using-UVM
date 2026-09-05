// apb_all_regs_write_read_seq.sv
class apb_all_regs_write_read_seq extends apb_base_seq;
  `uvm_object_utils(apb_all_regs_write_read_seq)

  function new(string name = "apb_all_regs_write_read_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   wdata, rdata;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    foreach (reg_model.regs[i]) begin
      wdata = $urandom();

      if (!reg_model.regs[i].is_read_only) begin
        reg_model.regs[i].write(status, wdata, UVM_FRONTDOOR, reg_model.apb_map, this);
        reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
        if (rdata !== wdata)
          `uvm_error("SEQ_ERR", $sformatf("reg[%0d] MISMATCH exp=0x%08h got=0x%08h", i, wdata, rdata))
      end else begin
        // RO: just read, expect reset value (0), no write attempted here
        reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
        if (rdata !== 32'h0)
          `uvm_error("SEQ_ERR", $sformatf("RO reg[%0d] unexpected value 0x%08h", i, rdata))
      end
    end
    `uvm_info("SEQ_INFO", "all_regs_write_read sweep complete", UVM_LOW)
  endtask
endclass
