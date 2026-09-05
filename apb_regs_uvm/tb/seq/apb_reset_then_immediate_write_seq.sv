// apb_reset_then_immediate_write_seq.sv
class apb_reset_then_immediate_write_seq extends apb_base_seq;
  `uvm_object_utils(apb_reset_then_immediate_write_seq)
  function new(string name = "apb_reset_then_immediate_write_seq"); super.new(name); endfunction

  task body();
    // Fires as soon as this sequence gets sequencer arbitration — test class
    // controls how tightly this follows reset deassertion (see test below)
    send_raw(.addr(32'h0000_0010), .wr(1), .data(32'h1111_2222));
  endtask
endclass
