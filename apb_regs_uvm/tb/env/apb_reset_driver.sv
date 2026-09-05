// apb_reset_driver.sv — test-side reset control
class apb_reset_driver extends uvm_component;
  `uvm_component_utils(apb_reset_driver)

  virtual reset_if rst_vif;

  function new(string name = "apb_reset_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reset_if)::get(this, "", "rst_vif", rst_vif))
      `uvm_fatal("RST_DRV", "virtual interface 'rst_vif' not set in config_db")
  endfunction

  // cycles measured against 10ns clock period (100MHz) set in tb_top
  task assert_reset(int unsigned cycles = 5);
    rst_vif.preset_n = 1'b0;
    #(cycles * 10ns);
  endtask

  task deassert_reset();
    rst_vif.preset_n = 1'b1;
  endtask
endclass
