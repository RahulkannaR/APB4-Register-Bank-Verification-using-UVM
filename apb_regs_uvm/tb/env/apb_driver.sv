class apb_driver extends uvm_driver #(apb_seq_item);

  `uvm_component_utils(apb_driver)

  virtual apb_if.DRIVER vif;
  bit enable_reset_watch = 0;   // ADDED — opt-in, default off

  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.DRIVER)::get(this, "", "vif", vif))
      `uvm_fatal("APB_DRV", "virtual interface 'vif' not set in config_db")
    // ADDED — only set by tests that need mid-run reset support
    void'(uvm_config_db#(bit)::get(this, "", "enable_reset_watch", enable_reset_watch));
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item req;
    apb_seq_item next_req;
    bit          setup_done_this_iter;
    bit          item_pending;
    bit          reset_now;

    reset_bus();

	$display("Enable_reset_watch = %0b",enable_reset_watch);

    if (enable_reset_watch) begin
      // Only spawned when a test explicitly opts in
      fork
        forever begin
          @(negedge vif.preset_n);
          reset_now = 1;
          `uvm_info("APB_DRV", "Reset detected mid-run — aborting in-flight transaction", UVM_MEDIUM)
          vif.drv_cb.psel    <= 1'b0;
          vif.drv_cb.penable <= 1'b0;
          if (item_pending) begin
            req.pslverr = 1'b1;
            seq_item_port.item_done();
            item_pending = 0;
          end
          @(posedge vif.preset_n);
          reset_now = 0;
        end
      join_none
    end

    // ---- Main driving loop — UNCHANGED from the original simple version ----
    forever begin
      apb_seq_item local_req;

      if (enable_reset_watch && reset_now) begin
        @(vif.drv_cb);
        continue;
      end

      seq_item_port.get_next_item(req);
      item_pending = 1;
      setup_done_this_iter = 0;

      forever begin
        if (!setup_done_this_iter) begin
          @(vif.drv_cb);
          if (enable_reset_watch && reset_now) break;
          apply_setup(req);
        end

        @(vif.drv_cb);
        if (enable_reset_watch && reset_now) break;
        vif.drv_cb.penable <= 1'b1;

        do @(vif.drv_cb);
        while (vif.drv_cb.pready !== 1'b1 && !(enable_reset_watch && reset_now));
        if (enable_reset_watch && reset_now) break;

        req.prdata  = vif.drv_cb.prdata;
        req.pslverr = vif.drv_cb.pslverr;
        seq_item_port.item_done();
        item_pending = 0;

        seq_item_port.try_next_item(next_req);
        if (next_req != null) begin
          req = next_req;
          item_pending = 1;
          apply_setup(req);
          setup_done_this_iter = 1;
        end else begin
          vif.drv_cb.psel    <= 1'b0;
          vif.drv_cb.penable <= 1'b0;
          break;
        end
      end
    end
  endtask

  task reset_bus();
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.paddr   <= '0;
    vif.drv_cb.pwdata  <= '0;
    vif.drv_cb.pwrite  <= 1'b0;
    vif.drv_cb.pstrb   <= '0;
    vif.drv_cb.pprot   <= '0;
    @(posedge vif.preset_n);
    @(vif.drv_cb);
  endtask

  task apply_setup(apb_seq_item item);
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.paddr   <= item.paddr;
    vif.drv_cb.pwrite  <= item.pwrite;
    vif.drv_cb.pwdata  <= item.pwdata;
    vif.drv_cb.pstrb   <= item.pstrb;
    vif.drv_cb.pprot   <= item.pprot;
  endtask

endclass
