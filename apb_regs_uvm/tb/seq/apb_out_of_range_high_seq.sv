// apb_out_of_range_high_seq.sv
class apb_out_of_range_high_seq extends apb_base_seq;
  `uvm_object_utils(apb_out_of_range_high_seq)
  function new(string name = "apb_out_of_range_high_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item = apb_seq_item::type_id::create("item");
    bit [31:0] addr = 32'h0000_0020; // exactly one word past the last mapped reg

    start_item(item);
    if (!item.randomize() with { paddr == addr; pwrite == 0; })
      `uvm_error("SEQ_ERR", "randomize failed in out_of_range_high");
    finish_item(item);

    if (!item.pslverr)
      `uvm_error("SEQ_ERR", $sformatf("out_of_range_high FAIL: addr 0x%08h did not SLVERR", addr))
    else
      `uvm_info("SEQ_INFO", "out_of_range_high PASSED", UVM_LOW)
  endtask
endclass
