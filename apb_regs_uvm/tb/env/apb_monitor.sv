//-----------------------------------------------------------------------------
// apb_monitor.sv
// Passively samples the bus, reconstructs completed transfers,
// broadcasts them on the analysis port for scoreboard + coverage
//-----------------------------------------------------------------------------
class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  virtual apb_if.MONITOR vif;
  uvm_analysis_port #(apb_seq_item) ap;

  function new(string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "virtual interface 'vif' not set in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      apb_seq_item tr;

      // wait for SETUP phase entry
      do @(vif.mon_cb);
      while (!(vif.mon_cb.psel === 1'b1 && vif.mon_cb.penable === 1'b0));

      tr = apb_seq_item::type_id::create("tr");
      tr.paddr  = vif.mon_cb.paddr;
      tr.pwrite = vif.mon_cb.pwrite;
      tr.pwdata = vif.mon_cb.pwdata;
      tr.pstrb  = vif.mon_cb.pstrb;
      tr.pprot  = vif.mon_cb.pprot;

      // wait for ACCESS phase entry
      @(vif.mon_cb);

      // wait until slave asserts pready -> transfer completes this cycle
      while (vif.mon_cb.pready !== 1'b1)
        @(vif.mon_cb);

      tr.prdata  = vif.mon_cb.prdata;
      tr.pslverr = vif.mon_cb.pslverr;

      `uvm_info("APB_MON", tr.convert2string(), UVM_HIGH)
      ap.write(tr);
    end
  endtask

endclass
