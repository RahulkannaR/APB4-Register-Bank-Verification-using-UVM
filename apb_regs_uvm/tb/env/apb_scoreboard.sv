//-----------------------------------------------------------------------------
// apb_scoreboard.sv
// Shadow-memory checker: tracks expected register values, flags any
// mismatch on read data, and validates PSLVERR legality.
// >>> NUM_REGS / ADDR_OFFSET / READ_ONLY_MASK must match apb_reg_block.
//-----------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mon)

class apb_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(apb_scoreboard)

  	uvm_analysis_imp_mon #(apb_seq_item, apb_scoreboard) mon_imp;
	virtual reset_if rst_vif;

  	localparam int NUM_REGS      = 8;
  	localparam int ADDR_OFFSET   = 4;
  	localparam bit [NUM_REGS-1:0] READ_ONLY_MASK = 8'b0000_0001;

  	bit [31:0] shadow_mem[int]; // index -> expected value
  	int        num_checked;
  	int        num_errors;

  	function new(string name = "apb_scoreboard", uvm_component parent = null);
    	super.new(name, parent);
  	endfunction

  	function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	mon_imp = new("mon_imp", this);
    			
		if (!uvm_config_db#(virtual reset_if)::get(this, "", "rst_vif", rst_vif))  // ADD THIS
      		`uvm_fatal("SB_ERR", "reset_if not set in config_db")
    	reset_shadow_mem();
  	endfunction

	function void reset_shadow_mem();   // ADD THIS HELPER
    	foreach (shadow_mem[i]) shadow_mem.delete(i);
    	for (int i = 0; i < NUM_REGS; i++)
      		shadow_mem[i] = 32'h0000_0000;
  	endfunction

  	function void write_mon(apb_seq_item tr);
		bit [31:0] eff_addr = tr.paddr & ((32'h1 << ApbAddrWidth) - 1);
    	int idx = eff_addr / ADDR_OFFSET;
    	bit mapped =  (idx < NUM_REGS);

    	num_checked++;

    	// ---- Unmapped address: must SLVERR, must not corrupt shadow ----
    	if (!mapped) begin
      		if (!tr.pslverr) begin
        		`uvm_error("SB_ERR", $sformatf(
          			"Unmapped addr 0x%08h did NOT return PSLVERR", tr.paddr))
        		num_errors++;
      		end
      		return;
    	end

    	// ---- Mapped write ----
    	if (tr.pwrite) begin
      		if (READ_ONLY_MASK[idx]) begin
        	// read-only: value must NOT change, response behavior per DUT spec
				if (!tr.pslverr) begin
      				`uvm_error("SB_ERR", $sformatf(
        				"RO reg[%0d] write did NOT return expected PSLVERR", idx))
      				num_errors++;
    			end else begin
        			`uvm_info("SB_INFO", $sformatf(
          				"Write to RO reg[%0d] correctly ignored (data unchanged)", idx), UVM_MEDIUM)
				end
      		end else begin
        		shadow_mem[idx] = tr.pwdata;
      			if (tr.pslverr) begin
        			`uvm_error("SB_ERR", $sformatf(
         	 			"Unexpected PSLVERR on legal mapped write to reg[%0d]", idx))
        			num_errors++;
      			end
    		end
		end
    	// ---- Mapped read ----
    	else begin
      		if (tr.pslverr) begin
        		`uvm_error("SB_ERR", $sformatf(
          			"Unexpected PSLVERR on legal mapped read of reg[%0d]", idx))
        		num_errors++;
      		end else if (tr.prdata !== shadow_mem[idx]) begin
        		`uvm_error("SB_ERR", $sformatf(
          			"MISMATCH reg[%0d]: expected=0x%08h actual=0x%08h",
          		idx, shadow_mem[idx], tr.prdata))
        		num_errors++;
      		end
    	end
  	endfunction

  	function void report_phase(uvm_phase phase);
    	`uvm_info("SB_REPORT", $sformatf(
      		"Scoreboard: checked=%0d errors=%0d", num_checked, num_errors), UVM_LOW)
  	endfunction

	task run_phase(uvm_phase phase);   // ADD THIS ENTIRE TASK
    	forever begin
      		@(negedge rst_vif.preset_n);
      		`uvm_info("SB_INFO", "Reset detected — resyncing shadow_mem to 0", UVM_MEDIUM)
      		reset_shadow_mem();
    	end
  	endtask
endclass
