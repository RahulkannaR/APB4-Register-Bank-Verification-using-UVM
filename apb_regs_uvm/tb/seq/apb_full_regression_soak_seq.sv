// apb_full_regression_soak_seq.sv
class apb_full_regression_soak_seq extends apb_base_seq;
  `uvm_object_utils(apb_full_regression_soak_seq)
  function new(string name = "apb_full_regression_soak_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    repeat (1000) begin
      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            paddr dist {
              [32'h0000_0000:32'h0000_001C] :/ 90,
              [32'h0000_0020:32'hFFFF_FFFF] :/ 10
            };
          })
        `uvm_error("SEQ_ERR", "randomize failed in full_regression_soak");
      finish_item(item);
    end
    `uvm_info("SEQ_INFO", "full_regression_soak: 1000 transactions complete", UVM_LOW)
  endtask
endclass
