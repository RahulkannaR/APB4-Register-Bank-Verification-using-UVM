//-----------------------------------------------------------------------------
// apb_if.sv
// APB4 interface — signal names match DUT's APB.Slave modport 1:1
//-----------------------------------------------------------------------------
interface apb_if (input logic pclk, input logic preset_n);

  logic [31:0] paddr;
  logic [2:0]  pprot;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic        pready;
  logic [31:0] prdata;
  logic        pslverr;

  //---------------------------------------------------------------------
  // Clocking block — driver side (avoids race with DUT on pclk edge)
  //---------------------------------------------------------------------
  clocking drv_cb @(posedge pclk);
    output paddr, pprot, psel, penable, pwrite, pwdata, pstrb;
    input  pready, prdata, pslverr;
  endclocking

  //---------------------------------------------------------------------
  // Clocking block — monitor side (sample-only, zero skew ambiguity)
  //---------------------------------------------------------------------
  clocking mon_cb @(posedge pclk);
    input paddr, pprot, psel, penable, pwrite, pwdata, pstrb,
          pready, prdata, pslverr;
  endclocking

  modport DRIVER  (clocking drv_cb, input pclk, preset_n);
  modport MONITOR (clocking mon_cb, input pclk, preset_n);

  // Direct (non-clocked) connection to the DUT's APB.Slave modport
  modport DUT (
    output paddr, pprot, psel, penable, pwrite, pwdata, pstrb,
    input  pready, prdata, pslverr
  );

  modport CHECKER (
  input pclk, preset_n, paddr, pprot, psel, penable, pwrite, pwdata, pstrb,
          pready, prdata, pslverr
  );

endinterface
