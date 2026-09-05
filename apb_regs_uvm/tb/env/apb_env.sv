//-----------------------------------------------------------------------------
// apb_env.sv
//-----------------------------------------------------------------------------
class apb_env extends uvm_env;

  `uvm_component_utils(apb_env)

  apb_agent       agent;
  apb_scoreboard  sb;
  apb_coverage    cov;
  apb_reg_block   reg_model;
  apb_reg_adapter reg_adapter;
  apb_reset_driver reset_driver;

  function new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = apb_agent::type_id::create("agent", this);
    //agent.set_config_int("is_active", UVM_ACTIVE);

    sb  = apb_scoreboard::type_id::create("sb", this);
    cov = apb_coverage::type_id::create("cov", this);

    reg_model = apb_reg_block::type_id::create("reg_model");
    reg_model.build();

    reg_adapter = apb_reg_adapter::type_id::create("reg_adapter");

	reset_driver = apb_reset_driver::type_id::create("reset_driver", this);

	uvm_config_db#(virtual reset_if)::set(this, "sb", "rst_vif", null); // will be resolved from tb_top's global set
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agent.ap.connect(sb.mon_imp);
    agent.ap.connect(cov.cov_imp);

    reg_model.apb_map.set_sequencer(.sequencer(agent.sequencer),
                                     .adapter(reg_adapter));
    reg_model.apb_map.set_auto_predict(0); // scoreboard does explicit checking
  endfunction

endclass
