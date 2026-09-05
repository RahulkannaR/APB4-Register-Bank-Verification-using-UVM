// apb_random_back_to_back_burst_seq.sv
class apb_random_back_to_back_burst_seq extends apb_base_seq;
  `uvm_object_utils(apb_random_back_to_back_burst_seq)
  function new(string name = "apb_random_back_to_back_burst_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    repeat (200) begin
      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            paddr inside {[32'h0000_0000:32'h0000_001C]}; // valid map only — pure throughput test
          })
        `uvm_error("SEQ_ERR", "randomize failed in random_back_to_back_burst");
      finish_item(item); // driver's try_next_item() pipelines these with zero gap
    end
    `uvm_info("SEQ_INFO", "random_back_to_back_burst: 200 transactions, zero-gap", UVM_LOW)
  endtask
endclass
