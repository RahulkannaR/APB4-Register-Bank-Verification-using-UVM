//-----------------------------------------------------------------------------
// apb_base_seq.sv
// Common base for all sequences. Holds a reg_model handle for RAL-based
// sequences, plus a raw-item helper for tests that must bypass RAL
// (e.g. unmapped-address / error tests where no register exists to target).
//-----------------------------------------------------------------------------
class apb_base_seq extends uvm_sequence #(apb_seq_item);

	`uvm_object_utils(apb_base_seq)

  	apb_reg_block reg_model;

  	function new(string name = "apb_base_seq");
    	super.new(name);
  	endfunction

  	//---------------------------------------------------------------------
  	// Raw bus-level transfer — used when there's no valid register to
  	// address through RAL (unmapped-address / protocol-edge tests)
  	//---------------------------------------------------------------------
  	task send_raw(bit [31:0] addr, bit wr, bit [31:0] data = 0, bit [3:0] strb = 4'b1111);
    	apb_seq_item item = apb_seq_item::type_id::create("item");
		bit [3:0] eff_strb = wr ? strb : 4'b0000;

    	start_item(item);
    	if (!item.randomize() with {
          	paddr  == addr;
          	pwrite == wr;
          	pwdata == data;
          	pstrb  == eff_strb;
        })
      	`uvm_error("SEQ_ERR", "randomize failed in send_raw")
    	finish_item(item);
  endtask

endclass
