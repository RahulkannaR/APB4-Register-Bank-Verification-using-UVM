//-----------------------------------------------------------------------------
// apb_reg_adapter.sv
// Translates uvm_reg_bus_op <-> apb_seq_item so RAL sequences can drive
// through the existing apb_driver/apb_sequencer path.
//-----------------------------------------------------------------------------
class apb_reg_adapter extends uvm_reg_adapter;

  `uvm_object_utils(apb_reg_adapter)

  function new(string name = "apb_reg_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses    = 0;
  endfunction

  // RAL -> bus transaction
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_seq_item item = apb_seq_item::type_id::create("item");
    item.paddr  = rw.addr;
    item.pwrite = (rw.kind == UVM_WRITE);
    item.pwdata = (rw.kind == UVM_WRITE) ? rw.data : 32'h0;
    item.pstrb  = (rw.kind == UVM_WRITE) ? 4'b1111 : 4'b0000;
    return item;
  endfunction

  // bus transaction -> RAL
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_seq_item item;
    if (!$cast(item, bus_item))
      `uvm_fatal("APB_ADAPTER", "Failed to cast bus_item to apb_seq_item")

    rw.kind   = item.pwrite ? UVM_WRITE : UVM_READ;
    rw.addr   = item.paddr;
    rw.data   = item.pwrite ? item.pwdata : item.prdata;
    rw.status = item.pslverr ? UVM_NOT_OK : UVM_IS_OK;
  endfunction

endclass
