// apb_hole_address_access_seq.sv
class apb_hole_address_access_seq extends apb_base_seq;
  	`uvm_object_utils(apb_hole_address_access_seq)

  	function new(string name = "apb_hole_address_access_seq");
    	super.new(name);
  	endfunction

  	task body();
  		apb_seq_item item;
  	
		// NUM_REGS/ADDR_OFFSET must match apb_reg_block
  		bit [31:0] test_addrs[3]     = '{32'h0000_0001, 32'h0000_0006, 32'h0000_000B};
  		int        expected_idx[3]   = '{0, 1, 2};  // window each address should alias into

  		foreach (test_addrs[i]) begin
    		item = apb_seq_item::type_id::create("item");
    
			start_item(item);
    		if (!item.randomize() with { paddr == test_addrs[i]; pwrite == 0; })
      			`uvm_error("SEQ_ERR", "randomize failed");
    		finish_item(item);

    		`uvm_info("SEQ_INFO", $sformatf(
      			"misaligned addr 0x%08h aliased into reg[%0d] window -> pslverr=%0b prdata=0x%08h",
      			test_addrs[i], expected_idx[i], item.pslverr, item.prdata), UVM_LOW)

    		if (item.pslverr)
      			`uvm_error("SEQ_ERR", $sformatf(
        		"Unexpected PSLVERR — DUT normally range-aliases misaligned addr 0x%08h", test_addrs[i]))
  		end
	endtask
endclass
