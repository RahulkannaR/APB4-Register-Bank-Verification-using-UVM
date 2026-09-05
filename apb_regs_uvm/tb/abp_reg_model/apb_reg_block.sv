//-----------------------------------------------------------------------------
// apb_reg_block.sv
// RAL model for apb_regs DUT.
// >>> ADJUST NUM_REGS / ADDR_OFFSET / READ_ONLY_MASK to match your actual
// >>> apb_regs instantiation parameters before running.
//-----------------------------------------------------------------------------

class apb_reg extends uvm_reg;

  rand uvm_reg_field value;
  bit is_read_only;

  `uvm_object_utils(apb_reg)

  function new(string name = "apb_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build(bit read_only, bit [31:0] reset_val);
    is_read_only = read_only;
    value = uvm_reg_field::type_id::create("value");
    value.configure(
      .parent            (this),
      .size              (32),
      .lsb_pos           (0),
      .access            (read_only ? "RO" : "RW"),
      .volatile          (0),
      .reset             (reset_val),
      .has_reset         (1),
      .is_rand           (!read_only),
      .individually_accessible(1)
    );
  endfunction

endclass


class apb_reg_block extends uvm_reg_block;

  // ---- DUT address-map parameters ----
  localparam int NUM_REGS      = 8;
  localparam int ADDR_OFFSET   = 4;
  localparam bit [NUM_REGS-1:0] READ_ONLY_MASK = 8'b0000_0001; // reg[0] = RO

  apb_reg regs[NUM_REGS];
  uvm_reg_map apb_map;

  `uvm_object_utils(apb_reg_block)

  function new(string name = "apb_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function void build();
    apb_map = create_map("apb_map", 0, 4, UVM_LITTLE_ENDIAN);

    foreach (regs[i]) begin
      bit ro = READ_ONLY_MASK[i];
      regs[i] = apb_reg::type_id::create($sformatf("reg_%0d", i));
      regs[i].build(.read_only(ro), .reset_val(32'h0000_0000));
      regs[i].configure(this, null, "");
      apb_map.add_reg(regs[i], i * ADDR_OFFSET, "RW");
    end

    lock_model();
  endfunction

endclass
