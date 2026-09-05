// apb_repeated_unmapped_access_seq.sv
class apb_repeated_unmapped_access_seq extends apb_base_seq;
  `uvm_object_utils(apb_repeated_unmapped_access_seq)
  function new(string name = "apb_repeated_unmapped_access_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    bit [31:0] unmapped_addrs[4] = '{32'h100, 32'h104, 32'h200, 32'hFFF0};

    // fire 4 illegal accesses back-to-back
    foreach (unmapped_addrs[i]) begin
      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with { paddr == unmapped_addrs[i]; pwrite == 0; })
        `uvm_error("SEQ_ERR", "randomize failed in repeated_unmapped_access");
      finish_item(item);
      if (!item.pslverr)
        `uvm_error("SEQ_ERR", $sformatf("addr 0x%08h in burst did not SLVERR", unmapped_addrs[i]))
    end

    // immediately follow with ONE legal access — must NOT inherit false SLVERR
    item = apb_seq_item::type_id::create("item");
    start_item(item);
    if (!item.randomize() with { paddr == 32'h0000_0004; pwrite == 0; })
      `uvm_error("SEQ_ERR", "randomize failed on trailing legal access");
    finish_item(item);
    if (item.pslverr)
      `uvm_error("SEQ_ERR", "Legal access after illegal burst falsely returned PSLVERR")
    else
      `uvm_info("SEQ_INFO", "repeated_unmapped_access PASSED — no error-flag bleed", UVM_LOW)
  endtask
endclass
