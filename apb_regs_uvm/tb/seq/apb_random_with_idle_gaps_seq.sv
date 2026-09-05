// apb_random_with_idle_gaps_seq.sv
class apb_random_with_idle_gaps_seq extends apb_base_seq;
  `uvm_object_utils(apb_random_with_idle_gaps_seq)
  function new(string name = "apb_random_with_idle_gaps_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    int unsigned gap_cycles;

    repeat (50) begin
      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            paddr inside {[32'h0000_0000:32'h0000_001C]};
          })
        `uvm_error("SEQ_ERR", "randomize failed in random_with_idle_gaps");
      finish_item(item);

      // randomized idle gap 0-5 cycles before the next item is even offered
      // to the sequencer — this defeats try_next_item()'s pipelining on
      // purpose, forcing the driver back to IDLE between some transfers
      gap_cycles = $urandom_range(0, 5);
      if (gap_cycles > 0) #(gap_cycles * 10ns);
    end
    `uvm_info("SEQ_INFO", "random_with_idle_gaps: 50 transactions, variable gaps", UVM_LOW)
  endtask
endclass
