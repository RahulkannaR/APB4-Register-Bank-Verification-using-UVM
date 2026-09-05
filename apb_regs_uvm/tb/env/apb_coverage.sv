//-----------------------------------------------------------------------------
// apb_coverage.sv
// Functional coverage: register index, R/W type, PSLVERR, RO-vs-RW cross.
// >>> NUM_REGS / READ_ONLY_MASK must match apb_reg_block.
//-----------------------------------------------------------------------------
`uvm_analysis_imp_decl(_cov)

class apb_coverage extends uvm_component;

  `uvm_component_utils(apb_coverage)

  uvm_analysis_imp_cov #(apb_seq_item, apb_coverage) cov_imp;

  localparam int NUM_REGS      = 8;
  localparam int ADDR_OFFSET   = 4;
  localparam bit [NUM_REGS-1:0] READ_ONLY_MASK = 8'b0000_0001;

  apb_seq_item tr_cov;
  int          reg_idx;
  bit          is_ro;

  covergroup cg_apb;
    option.per_instance = 1;

    cp_reg_idx : coverpoint reg_idx {
      bins valid_idx[] = {[0:NUM_REGS-1]};
      bins out_of_range = {[NUM_REGS:$]};
    }

    cp_rw : coverpoint tr_cov.pwrite {
      bins write = {1};
      bins read  = {0};
    }

    cp_pslverr : coverpoint tr_cov.pslverr {
      bins ok    = {0};
      bins error = {1};
    }

    cp_is_ro : coverpoint is_ro {
      bins ro = {1};
      bins rw = {0};
    }

    // cross: every register hit for both read & write, split RO/RW
    x_idx_rw_ro : cross cp_reg_idx, cp_rw, cp_is_ro{

      // idx 1..NUM_REGS-1 can never be RO
      ignore_bins writable_regs_never_ro =
        binsof(cp_reg_idx.valid_idx) intersect {[1:NUM_REGS-1]} &&
        binsof(cp_is_ro.ro);

      // out_of_range always computes is_ro=0, never RO
      ignore_bins out_of_range_never_ro =
        binsof(cp_reg_idx.out_of_range) &&
        binsof(cp_is_ro.ro);

      // idx 0 is always RO, never RW
      ignore_bins reg0_never_rw =
        binsof(cp_reg_idx.valid_idx[0]) &&
        binsof(cp_is_ro.rw);
    }

    // cross: confirm SLVERR seen on both mapped and unmapped paths
    x_idx_err : cross cp_reg_idx, cp_pslverr{
      ignore_bins writable_regs_never_error =
        binsof(cp_reg_idx.valid_idx) intersect {[1:NUM_REGS-1]} &&
        binsof(cp_pslverr.error);
    }

  endgroup

  function new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_apb = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_imp = new("cov_imp", this);
  endfunction

  function void write_cov(apb_seq_item tr);
    tr_cov  = tr;
    reg_idx = tr.paddr / ADDR_OFFSET;
    is_ro   = (reg_idx < NUM_REGS) ? READ_ONLY_MASK[reg_idx] : 1'b0;
    cg_apb.sample();
  endfunction

endclass
