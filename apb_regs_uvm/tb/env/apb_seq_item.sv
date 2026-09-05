//-----------------------------------------------------------------------------
// apb_seq_item.sv
// APB4 transaction item - carries one complete SETUP+ACCESS transfer
//-----------------------------------------------------------------------------
class apb_seq_item extends uvm_sequence_item;

  // --- Driven fields (Master -> Slave) ---
  rand bit [31:0] paddr;
  rand bit [31:0] pwdata;
  rand bit [3:0]  pstrb;
  rand bit        pwrite;      // 1 = write, 0 = read
  rand bit [2:0]  pprot;

  // --- Response fields (Slave -> Master), filled by monitor/driver ---
  bit [31:0] prdata;
  bit        pslverr;

  // --- Convenience knobs for directed sequences ---
  rand bit addr_valid;         // steer toward mapped vs unmapped address

  //---------------------------------------------------------------------
  // Constraints
  //---------------------------------------------------------------------
  constraint c_default_strobe {
    // full-word writes by default; sequences override pstrb directly
    // for partial-write / edge tests
    pwrite -> pstrb == 4'b1111;
    !pwrite -> pstrb == 4'b0000;
  }

  constraint c_pprot_default {
    pprot == 3'b000;
  }

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(paddr,   UVM_ALL_ON)
    `uvm_field_int(pwdata,  UVM_ALL_ON)
    `uvm_field_int(pstrb,   UVM_ALL_ON)
    `uvm_field_int(pwrite,  UVM_ALL_ON)
    `uvm_field_int(pprot,   UVM_ALL_ON)
    `uvm_field_int(prdata,  UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(pslverr, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf(
      "paddr=0x%08h pwrite=%0b pwdata=0x%08h pstrb=%b | prdata=0x%08h pslverr=%0b",
      paddr, pwrite, pwdata, pstrb, prdata, pslverr);
  endfunction

endclass
