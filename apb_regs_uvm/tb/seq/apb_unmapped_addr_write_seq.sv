// apb_unmapped_addr_write_seq.sv
class apb_unmapped_addr_write_seq extends apb_base_seq;
  `uvm_object_utils(apb_unmapped_addr_write_seq)

  function new(string name = "apb_unmapped_addr_write_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    apb_seq_item item;
    bit [31:0] unmapped_addr = 32'h0000_0100;
    bit [31:0] rdata_before, rdata_after;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    // baseline: capture reg[0]'s value before the illegal write attempt
    reg_model.regs[0].read(status, rdata_before, UVM_FRONTDOOR, reg_model.apb_map, this);

    // illegal write to unmapped address
    item = apb_seq_item::type_id::create("item");
    start_item(item);
    if (!item.randomize() with {
          paddr  == unmapped_addr;
          pwrite == 1;
          pwdata == 32'hBAAD_F00D;
        })
      `uvm_error("SEQ_ERR", "randomize failed in unmapped_addr_write")
    finish_item(item);

    if (!item.pslverr)
      `uvm_error("SEQ_ERR", $sformatf(
        "unmapped_addr_write FAIL: addr 0x%08h did not return PSLVERR", unmapped_addr))

    // confirm no valid register was corrupted by the illegal write
    reg_model.regs[0].read(status, rdata_after, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (rdata_after !== rdata_before)
      `uvm_error("SEQ_ERR", $sformatf(
        "unmapped_addr_write CORRUPTED reg[0]: before=0x%08h after=0x%08h",
        rdata_before, rdata_after))
    else
      `uvm_info("SEQ_INFO", "unmapped_addr_write PASSED — error flagged, no corruption", UVM_LOW)
  endtask
endclass
