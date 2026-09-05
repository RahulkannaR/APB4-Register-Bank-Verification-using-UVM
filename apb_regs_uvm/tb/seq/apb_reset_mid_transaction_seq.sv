// apb_reset_mid_transaction_seq.sv
// NOTE: this sequence does NOT control reset itself — reset is asserted
// by the TEST class in parallel with this sequence running (see test below).
class apb_reset_mid_transaction_seq extends apb_base_seq;
  `uvm_object_utils(apb_reset_mid_transaction_seq)

  function new(string name = "apb_reset_mid_transaction_seq");
    super.new(name);
  endfunction

  task body();
    // Long-running write — intentionally the transaction that reset
    // will interrupt mid-flight
    send_raw(.addr(32'h0000_0008), .wr(1), .data(32'hFEED_FACE));
  endtask
endclass
