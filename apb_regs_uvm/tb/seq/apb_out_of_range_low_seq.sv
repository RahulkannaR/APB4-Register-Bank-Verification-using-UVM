// apb_out_of_range_low_seq.sv
class apb_out_of_range_low_seq extends apb_base_seq;
  `uvm_object_utils(apb_out_of_range_low_seq)
  function new(string name = "apb_out_of_range_low_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item = apb_seq_item::type_id::create("item");
    // With BaseAddr=0x000 there's no true "below" address in a 32-bit space
    // except wrap-around; use the highest possible address as the underflow proxy
    bit [31:0] addr = 32'hFFFF_FFFF;

    start_item(item);
    if (!item.randomize() with { paddr == addr; pwrite == 0; })
      `uvm_error("SEQ_ERR", "randomize failed in out_of_range_low");
    finish_item(item);

    if (!item.pslverr)
      `uvm_error("SEQ_ERR", $sformatf("out_of_range_low FAIL: addr 0x%08h did not SLVERR", addr))
    else
      `uvm_info("SEQ_INFO", "out_of_range_low PASSED", UVM_LOW)
  endtask
endclass
