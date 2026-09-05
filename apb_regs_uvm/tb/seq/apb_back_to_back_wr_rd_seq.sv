// apb_back_to_back_wr_rd_seq.sv (unchanged from before)
class apb_back_to_back_wr_rd_seq extends apb_base_seq;
  `uvm_object_utils(apb_back_to_back_wr_rd_seq)

  function new(string name = "apb_back_to_back_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    localparam int NUM_REGS    = 8;
    localparam int ADDR_OFFSET = 4;
    bit [31:0] wr_pattern[NUM_REGS];

    for (int i = 0; i < NUM_REGS; i++) begin
      wr_pattern[i] = $urandom();
      send_raw(.addr(i * ADDR_OFFSET), .wr(1), .data(wr_pattern[i]));
    end

    for (int i = 0; i < NUM_REGS; i++) begin
      send_raw(.addr(i * ADDR_OFFSET), .wr(0));
    end

    `uvm_info("SEQ_INFO", "back_to_back_wr_rd burst sent", UVM_LOW)
  endtask
endclass
