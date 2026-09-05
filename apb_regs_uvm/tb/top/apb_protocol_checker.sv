//-----------------------------------------------------------------------------
// apb_protocol_checker.sv
// SVA-based APB4 protocol legality checks. Bound to apb_if in tb_top.
// This is the industry-standard way to check signal-timing legality —
// continuous, cycle-by-cycle, independent of any specific test's traffic.
//-----------------------------------------------------------------------------
module apb_protocol_checker (apb_if.CHECKER vif);

  // 1. SETUP phase must be exactly 1 cycle: psel=1,penable=0 -> next cycle penable=1
  property p_setup_one_cycle;
    @(posedge vif.pclk) disable iff (!vif.preset_n)
    (vif.psel && !vif.penable) |=> vif.penable;
  endproperty
  a_setup_one_cycle: assert property (p_setup_one_cycle)
    else `uvm_error("PROTO_ERR", "SETUP phase did not transition to ACCESS next cycle")

  // 2. PADDR/PWDATA/PWRITE must stay stable from SETUP through ACCESS
  //    (until pready completes the transfer)
  property p_addr_stable;
    @(posedge vif.pclk) disable iff (!vif.preset_n)
    (vif.psel && !vif.penable) |-> (vif.paddr === $past(vif.paddr,0)) ##1
      (vif.penable && !vif.pready) |-> $stable(vif.paddr);
  endproperty
  // simplified stable-through-access check
  property p_paddr_pwdata_stable_in_access;
    @(posedge vif.pclk) disable iff (!vif.preset_n)
    (vif.psel && vif.penable && !vif.pready) |=> $stable(vif.paddr) && $stable(vif.pwdata);
  endproperty
  a_paddr_pwdata_stable: assert property (p_paddr_pwdata_stable_in_access)
    else `uvm_error("PROTO_ERR", "PADDR/PWDATA changed mid-ACCESS before PREADY")

  // 3. PENABLE must never be high in the same cycle PSEL first asserts (no skipping SETUP)
  property p_no_setup_skip;
    @(posedge vif.pclk) disable iff (!vif.preset_n)
    ($rose(vif.psel)) |-> !vif.penable;
  endproperty
  a_no_setup_skip: assert property (p_no_setup_skip)
    else `uvm_error("PROTO_ERR", "PENABLE high on same cycle PSEL first asserted — SETUP skipped")

  // 4. Consecutive transfer: SETUP is legal starting the cycle right after
  //    a completed ACCESS (psel may stay high) — this is a coverage-style
  //    check, not an error condition, so implemented as a cover property
  cover_consecutive_transfer: cover property (
    @(posedge vif.pclk) disable iff (!vif.preset_n)
    (vif.psel && vif.penable && vif.pready) ##1 (vif.psel && !vif.penable)
  );

endmodule
