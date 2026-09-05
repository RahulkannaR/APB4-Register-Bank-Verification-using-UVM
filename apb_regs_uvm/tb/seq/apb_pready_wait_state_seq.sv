// apb_pready_wait_state_seq.sv
class apb_pready_wait_state_seq extends apb_base_seq;
  `uvm_object_utils(apb_pready_wait_state_seq)
  function new(string name = "apb_pready_wait_state_seq"); super.new(name); endfunction
  task body();
    send_raw(.addr(32'h0000_0000), .wr(0));
    send_raw(.addr(32'h0000_0004), .wr(1), .data(32'h0000_0001));
  endtask
endclass
