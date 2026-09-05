//-----------------------------------------------------------------------------
// tb_top.sv
// Top-level testbench: clock/reset gen, apb_if instance, struct packing
// glue between apb_if (flat signals) and apb_regs DUT (req_t/resp_t ports),
// UVM config_db wiring, run_test() launch.
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

import uvm_pkg::*;
import apb_uvm_pkg::*;
`include "uvm_macros.svh"
`include "apb_protocol_checker.sv"
`include "reset_if.sv"

module tb_top;

  //---------------------------------------------------------------------
  // Parameters — MUST match apb_reg_block / apb_scoreboard / apb_coverage
  //---------------------------------------------------------------------
  localparam int unsigned NoApbRegs    = 8;
  localparam int unsigned ApbAddrWidth = 12;
  localparam int unsigned AddrOffset   = 4;
  localparam int unsigned ApbDataWidth = 32;
  localparam int unsigned RegDataWidth = 32;
  localparam bit [NoApbRegs-1:0] ReadOnly = 8'b0000_0001;
  localparam logic [ApbAddrWidth-1:0] BaseAddr = 12'h000;

  //---------------------------------------------------------------------
  // Clock
  //---------------------------------------------------------------------
  logic pclk;

  initial pclk = 0;
  always #5 pclk = ~pclk; // 100MHz

  //---------------------------------------------------------------------
  // Reset — now test-controlled via reset_if / apb_reset_driver
  //---------------------------------------------------------------------
  reset_if rst_if();
  //wire preset_n = rst_if.preset_n;

  initial rst_if.preset_n = 1'b0; // starting state; base_test drives the real sequence

  //---------------------------------------------------------------------
  // APB interface instance
  //---------------------------------------------------------------------
  apb_if vif (.pclk(pclk), .preset_n(rst_if.preset_n));

  //---------------------------------------------------------------------
  // DUT req/resp struct wires + pack/unpack glue
  //---------------------------------------------------------------------
  apb_req_t  dut_req;
  apb_resp_t dut_resp;

  assign dut_req.paddr   = vif.paddr[ApbAddrWidth-1:0];
  assign dut_req.pprot   = vif.pprot;
  assign dut_req.psel    = vif.psel;
  assign dut_req.penable = vif.penable;
  assign dut_req.pwrite  = vif.pwrite;
  assign dut_req.pwdata  = vif.pwdata;
  assign dut_req.pstrb   = vif.pstrb;

  assign vif.pready  = dut_resp.pready;
  assign vif.prdata  = dut_resp.prdata;
  assign vif.pslverr = dut_resp.pslverr;

  //---------------------------------------------------------------------
  // Register-side ports (testbench drives init values, not RTL params)
  //---------------------------------------------------------------------
  logic [NoApbRegs-1:0][RegDataWidth-1:0] reg_init;
  logic [NoApbRegs-1:0][RegDataWidth-1:0] reg_q_out;

  genvar gi;
  generate
    for (gi = 0; gi < NoApbRegs; gi++) begin : g_reg_init
      assign reg_init[gi] = '0; // must match apb_reg_block reset values
    end
  endgenerate

  //---------------------------------------------------------------------
  // DUT instantiation
  //---------------------------------------------------------------------
  apb_regs #(
    .NoApbRegs    (NoApbRegs),
    .ApbAddrWidth (ApbAddrWidth),
    .AddrOffset   (AddrOffset),
    .ApbDataWidth (ApbDataWidth),
    .RegDataWidth (RegDataWidth),
    .ReadOnly     (ReadOnly),
    .req_t        (apb_req_t),
    .resp_t       (apb_resp_t)
  ) u_dut (
    .pclk_i      (pclk),
    .preset_ni   (rst_if.preset_n),
    .req_i       (dut_req),
    .resp_o      (dut_resp),
    .base_addr_i (BaseAddr),
    .reg_init_i  (reg_init),
    .reg_q_o     (reg_q_out)
  );

  apb_protocol_checker u_protocol_checker (.vif(vif));

  //---------------------------------------------------------------------
  // UVM config_db wiring + test launch
  //---------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual apb_if.DRIVER)::set(null, "*.agent.driver",  "vif", vif);
    uvm_config_db#(virtual apb_if.MONITOR)::set(null, "*.agent.monitor", "vif", vif);
    uvm_config_db#(virtual reset_if)::set(null, "*", "rst_vif", rst_if);
    run_test();
  end

  //---------------------------------------------------------------------
  // Optional: waveform dump for run.do
  //---------------------------------------------------------------------
  initial begin
    $dumpfile("apb_tb.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
