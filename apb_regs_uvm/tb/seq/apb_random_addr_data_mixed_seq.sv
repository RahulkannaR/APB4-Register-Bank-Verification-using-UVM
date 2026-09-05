// apb_random_addr_data_mixed_seq.sv
class apb_random_addr_data_mixed_seq extends apb_base_seq;
  `uvm_object_utils(apb_random_addr_data_mixed_seq)
  function new(string name = "apb_random_addr_data_mixed_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    repeat (100) begin
      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            // 80% valid mapped addresses (0x00-0x1C), 20% invalid, weighted
            paddr dist {
              [32'h0000_0000:32'h0000_001C] :/ 80,
              [32'h0000_0020:32'hFFFF_FFFF] :/ 20
            };
            pstrb == (pwrite ? 4'b1111 : 4'b0000);
          })
        `uvm_error("SEQ_ERR", "randomize failed in random_addr_data_mixed");
      finish_item(item);
    end
    `uvm_info("SEQ_INFO", "random_addr_data_mixed: 100 transactions sent", UVM_LOW)
  endtask
endclass
