// apb_walking_zeros_data_seq.sv
class apb_walking_zeros_data_seq extends apb_base_seq;
  `uvm_object_utils(apb_walking_zeros_data_seq)

  function new(string name = "apb_walking_zeros_data_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   wdata, rdata;
    int          idx = 2; // same target reg as walking_ones — direct comparison basis

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    for (int bit_pos = 0; bit_pos < 32; bit_pos++) begin
      wdata = ~(32'h1 << bit_pos); // all 1s except bit_pos

      reg_model.regs[idx].write(status, wdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      reg_model.regs[idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);

      if (rdata !== wdata)
        `uvm_error("SEQ_ERR", $sformatf(
          "walking_zeros FAIL at bit %0d: wrote 0x%08h, read 0x%08h", bit_pos, wdata, rdata))
    end

    `uvm_info("SEQ_INFO", "walking_zeros_data sweep complete (32 bit positions)", UVM_LOW)
  endtask
endclass
