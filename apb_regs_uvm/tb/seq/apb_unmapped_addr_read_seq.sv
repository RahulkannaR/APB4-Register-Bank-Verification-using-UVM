// apb_unmapped_addr_read_seq.sv
class apb_unmapped_addr_read_seq extends apb_base_seq;
  `uvm_object_utils(apb_unmapped_addr_read_seq)

  function new(string name = "apb_unmapped_addr_read_seq");
    super.new(name);
  endfunction

  task body();
    apb_seq_item item = apb_seq_item::type_id::create("item");
    bit [31:0] unmapped_addr = 32'h0000_0100; // well beyond mapped range (0x00-0x1C)

    start_item(item);
    if (!item.randomize() with {
          paddr  == unmapped_addr;
          pwrite == 0;
        })
      `uvm_error("SEQ_ERR", "randomize failed in unmapped_addr_read")
    finish_item(item);

    if (!item.pslverr)
      `uvm_error("SEQ_ERR", $sformatf(
        "unmapped_addr_read FAIL: addr 0x%08h did not return PSLVERR", unmapped_addr))
    else
      `uvm_info("SEQ_INFO", "unmapped_addr_read PASSED — PSLVERR correctly asserted", UVM_LOW)
  endtask
endclass
