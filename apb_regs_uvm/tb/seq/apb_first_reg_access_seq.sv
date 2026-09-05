// apb_first_reg_access_seq.sv
class apb_first_reg_access_seq extends apb_base_seq;
  `uvm_object_utils(apb_first_reg_access_seq)

  function new(string name = "apb_first_reg_access_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   rdata;
    int          idx = 0; // lowest mapped address boundary

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    reg_model.regs[idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);

    if (status != UVM_IS_OK)
      `uvm_error("SEQ_ERR", "read status not OK at first register")

    if (rdata !== 32'h0) // reset value, per reg_init_i driven as '0 in tb_top
      `uvm_error("SEQ_ERR", $sformatf("reg[0] unexpected value at boundary: 0x%08h", rdata))
    else
      `uvm_info("SEQ_INFO", "first_reg_access PASSED — lowest address decoded correctly", UVM_LOW)
  endtask
endclass
