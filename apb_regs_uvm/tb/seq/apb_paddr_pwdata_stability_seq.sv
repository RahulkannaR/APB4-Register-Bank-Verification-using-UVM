// apb_paddr_pwdata_stability_seq.sv
class apb_paddr_pwdata_stability_seq extends apb_base_seq;
  `uvm_object_utils(apb_paddr_pwdata_stability_seq)
  function new(string name = "apb_paddr_pwdata_stability_seq"); super.new(name); endfunction
  task body();
    send_raw(.addr(32'h0000_0004), .wr(1), .data(32'hABCD_1234)); // write, most likely to catch drift
    send_raw(.addr(32'h0000_0008), .wr(0));
  endtask
endclass
