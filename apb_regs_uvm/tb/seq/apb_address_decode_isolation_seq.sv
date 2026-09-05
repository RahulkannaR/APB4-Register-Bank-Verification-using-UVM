// apb_address_decode_isolation_seq.sv
class apb_address_decode_isolation_seq extends apb_base_seq;
  `uvm_object_utils(apb_address_decode_isolation_seq)

  function new(string name = "apb_address_decode_isolation_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e status;
    bit [31:0]   rdata;

    localparam int TARGET_IDX    = 4; // writable, has two writable neighbors
    localparam int LOWER_IDX     = 3;
    localparam int UPPER_IDX     = 5;
    localparam bit [31:0] LOWER_BASELINE  = 32'hAAAA_AAAA;
    localparam bit [31:0] UPPER_BASELINE  = 32'h5555_5555;
    localparam bit [31:0] TARGET_VALUE    = 32'hDEAD_BEEF;

    if (reg_model == null)
      `uvm_fatal("SEQ_ERR", "reg_model not set");

    // Step 1: establish known baseline in neighbors
    reg_model.regs[LOWER_IDX].write(status, LOWER_BASELINE, UVM_FRONTDOOR, reg_model.apb_map, this);
    reg_model.regs[UPPER_IDX].write(status, UPPER_BASELINE, UVM_FRONTDOOR, reg_model.apb_map, this);

    // Step 2: write the target register — this is what could leak
    reg_model.regs[TARGET_IDX].write(status, TARGET_VALUE, UVM_FRONTDOOR, reg_model.apb_map, this);

    // Step 3: confirm neighbors are UNCHANGED
    reg_model.regs[LOWER_IDX].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (rdata !== LOWER_BASELINE)
      `uvm_error("SEQ_ERR", $sformatf(
        "ISOLATION FAIL: reg[%0d] corrupted by write to reg[%0d]: exp=0x%08h got=0x%08h",
        LOWER_IDX, TARGET_IDX, LOWER_BASELINE, rdata))

    reg_model.regs[UPPER_IDX].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (rdata !== UPPER_BASELINE)
      `uvm_error("SEQ_ERR", $sformatf(
        "ISOLATION FAIL: reg[%0d] corrupted by write to reg[%0d]: exp=0x%08h got=0x%08h",
        UPPER_IDX, TARGET_IDX, UPPER_BASELINE, rdata))

    // Step 4: confirm target itself took the write correctly
    reg_model.regs[TARGET_IDX].read(status, rdata, UVM_FRONTDOOR, reg_model.apb_map, this);
    if (rdata !== TARGET_VALUE)
      `uvm_error("SEQ_ERR", $sformatf("Target reg[%0d] write failed: got 0x%08h", TARGET_IDX, rdata))

    `uvm_info("SEQ_INFO", "address_decode_isolation complete", UVM_LOW)
  endtask
endclass
