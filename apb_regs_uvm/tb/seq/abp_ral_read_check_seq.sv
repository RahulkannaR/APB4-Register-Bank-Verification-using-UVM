// New small helper sequence — add to apb_uvm_pkg.sv includes
class apb_ral_read_check_seq extends apb_base_seq;
  `uvm_object_utils(apb_ral_read_check_seq)

  int        reg_idx;
  bit [31:0] expected;

  function new(string name = "apb_ral_read_check_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   rdata;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    reg_model.regs[reg_idx].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);

    if (rdata !== expected)
      `uvm_error("TEST_ERR", $sformatf(
        "reg[%0d] check FAILED: got 0x%08h, expected 0x%08h", reg_idx, rdata, expected))
    else
      `uvm_info("TEST_INFO", $sformatf("reg[%0d] check PASSED: 0x%08h", reg_idx, rdata), UVM_LOW)
  endtask
endclass
