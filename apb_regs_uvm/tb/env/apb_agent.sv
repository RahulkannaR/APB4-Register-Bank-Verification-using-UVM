//-----------------------------------------------------------------------------
// apb_agent.sv
// Bundles sequencer + driver + monitor. Active/passive configurable.
//-----------------------------------------------------------------------------
class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  apb_sequencer sequencer;
  apb_driver    driver;
  apb_monitor   monitor;

  uvm_analysis_port #(apb_seq_item) ap; // pass-through to env

  function new(string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    monitor = apb_monitor::type_id::create("monitor", this);
    ap      = new("ap", this);

    if (get_is_active() == UVM_ACTIVE) begin
      sequencer = apb_sequencer::type_id::create("sequencer", this);
      driver    = apb_driver::type_id::create("driver", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (get_is_active() == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);

    monitor.ap.connect(this.ap);
  endfunction

endclass
