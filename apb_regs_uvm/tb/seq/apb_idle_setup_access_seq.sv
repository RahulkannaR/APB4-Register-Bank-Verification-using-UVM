// apb_idle_setup_access_seq.sv
class apb_idle_setup_access_seq extends apb_base_seq;
  `uvm_object_utils(apb_idle_setup_access_seq)
  function new(string name = "apb_idle_setup_access_seq"); super.new(name); endfunction
  task body();
    send_raw(.addr(32'h0000_0000), .wr(0)); // single clean transfer, IDLE before/after
  endtask
endclass
