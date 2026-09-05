// apb_reset_value_check_seq.sv
class apb_reset_value_check_seq extends apb_base_seq;
  `uvm_object_utils(apb_reset_value_check_seq)

  function new(string name = "apb_reset_value_check_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   rdata;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    foreach (reg_model.regs[i]) begin
      reg_model.regs[i].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
      if (rdata !== 32'h0)  // matches reg_init_i driven as '0 in tb_top
        `uvm_error("SEQ_ERR", $sformatf("reg[%0d] reset value wrong: got 0x%08h, exp 0x0", i, rdata))
    end
    `uvm_info("SEQ_INFO", "reset_value_check complete", UVM_LOW)
  endtask
endclass
