# APB4 Register Block — UVM Verification Environment

A complete SystemVerilog UVM verification environment built for the `apb_regs` peripheral from pulp-platform's open-source APB IP — covering functional correctness, protocol compliance, boundary/error handling, and RAL-based register verification.

## RTL Under Test

- **Source:** [`pulp-platform/apb`](https://github.com/pulp-platform/apb) — `apb_regs.sv`
- **Author:** ETH Zurich / pulp-platform (open-source, silicon-proven IP used across multiple taped-out PULP SoCs)
- **Dependency:** [`pulp-platform/common_cells`](https://github.com/pulp-platform/common_cells) — `addr_decode` module for address-range decoding
- **Configuration verified:** 8 registers, 12-bit address width, 32-bit data width, register 0 configured read-only

This project deliberately verifies a real, industry-authored register block rather than a custom/toy DUT, so every finding below reflects genuine hardware behavior rather than a contrived teaching example.

## Environment Architecture

Standard layered UVM testbench: `apb_seq_item` → `apb_driver`/`apb_monitor` → `apb_agent` → `apb_env`, with a RAL (Register Abstraction Layer) integration (`apb_reg_block` + `apb_reg_adapter`) sitting on top of the same bus-level infrastructure. An SVA-based protocol checker (`apb_protocol_checker`) runs independently in the background to catch signal-timing violations (SETUP/ACCESS phase legality, PADDR/PWDATA stability) that transaction-level checking alone wouldn't catch.

The driver supports pipelined back-to-back transfers (zero-IDLE-cycle bus utilization) and an opt-in reset-abort mechanism for tests that interrupt transactions mid-flight.

## Bug Found and Fixed

**Data-width truncation bug in `apb_regs.sv`'s `apb_data_t` typedef.**

The internal type used for the read-data path was incorrectly sized to `ApbAddrWidth` instead of `ApbDataWidth`:

```systemverilog
// Before (bug):
typedef logic [ApbAddrWidth-1:0] apb_data_t;

// After (fix):
typedef logic [ApbDataWidth-1:0] apb_data_t;
```

**Symptom:** with `ApbAddrWidth=12` and `ApbDataWidth=32` (a legitimate, commonly-used parameter combination), every register read silently truncated to the lower 12 bits. A write of `0xCAFEBABE` read back as `0x00000ABE`. This bug is invisible to any testbench using equal address/data widths — which is likely why it went unnoticed in this widely-used IP.

**Verification of the fix:** confirmed via `single_write_read` (basic round-trip), then more rigorously via `walking_ones_data` / `walking_zeros_data`, which independently proved every one of the 32 data bits — including bit 31, the exact bit the original bug would have dropped — could be driven and read back correctly in both directions after the fix.

## Coverage Journey

Initial functional coverage analysis flagged 47 "uncovered" cross-bins between register index, read/write direction, read-only status, and error response. Investigation showed these were not real test gaps but **structurally unreachable state combinations** — since this DUT has exactly one read-only register, a register's RO/RW status is fully determined by its index, so combinations like "a writable register sampled as read-only" can never physically occur. Similarly, a legal write to any writable register can never produce a protocol error under correct DUT operation, making certain error-cross bins permanently empty by design.

Rather than write meaningless tests chasing unreachable states, the coverage model itself was corrected with `ignore_bins` exclusions reflecting the DUT's actual reachable state space. Final coverage:

| Metric | Result |
|---|---|
| Covergroups | 100% (30/30 bins) |
| Assertions | 94.44% (17/18) |
| Overall | 98.14% |

The one remaining assertion gap (`a_paddr_pwdata_stable`) is a known, documented limitation rather than an open bug: this DUT is 0-wait-state (confirmed across the entire regression — `PREADY` asserts on the first ACCESS cycle in every single transaction observed), which structurally limits how much this stability-under-wait-state assertion can ever be exercised without a wait-state-injecting DUT variant.

## Test Suite

30 directed and randomized tests across seven categories, run via a Python-driven regression (`scripts/run_regression.py`) with automated per-test coverage capture, merge, and HTML/text reporting.

| Category | Tests | Why these specifically |
|---|---|---|
| **Normal / Sanity** | single_write_read, all_regs_write_read, back_to_back_wr_rd, reset_value_check, readonly_write_attempt, address_decode_isolation | Baseline correctness across the full register map, including a dedicated decoder-isolation test that writes a target register flanked by two known-baseline neighbors — catching address-aliasing bugs that a simple per-register sweep would miss |
| **Corner** | first/last_reg_access, walking_ones/zeros_data, all_ones_all_zeros, same_reg_repeated_access | Boundary decode precision at both ends of the address map, plus bidirectional single-bit and full-word data-path integrity — walking-ones and walking-zeros together rule out both stuck-at-0 *and* stuck-at-1 faults, which either test alone would miss |
| **Edge Case** | hole_address_access, out_of_range_high/low, reset_mid_transaction, back_to_back_reset_pulses | Discovered the DUT performs *range-based* address decoding (misaligned addresses alias into a containing register's window) rather than exact-match rejection — this was investigated, confirmed as correct DUT behavior, and the test corrected to document it rather than assume it as an error |
| **Error / Negative** | unmapped_addr_read/write, repeated_unmapped_access, readonly_write_error_check | `unmapped_addr_write` specifically checks the illegal write doesn't silently corrupt a real register, not just that it's flagged; `repeated_unmapped_access` checks the error flag doesn't "bleed" into a subsequent legal transaction |
| **Reset / Init** | reset_then_immediate_write, reset_retains_readonly_init | `reset_retains_readonly_init` deliberately corrupts every register first, then proves reset unconditionally restores them — a stronger proof than checking reset-values from an already-clean state |
| **Protocol Compliance** | idle_setup_access, paddr_pwdata_stability, pready_wait_state | Independent SVA-based signal-timing checks running alongside every test, plus a dedicated test confirming (and documenting) the DUT's 0-wait-state response behavior |
| **Random / Stress** | random_addr_data_mixed, random_back_to_back_burst, random_with_idle_gaps, full_regression_soak (1000 txns) | Constrained-random testing independently re-confirmed every directed finding (address aliasing, out-of-range rejection, RO protection) using data never explicitly chosen — and the 1000-transaction soak test caught a real testbench address-masking bug that no smaller test surfaced |

## Repository Structure
```
apb_regs_uvm/
├── rtl/ # DUT + dependencies (apb-master, common_cells-master)
├── tb/
│ ├── env/ # interface, package, driver, monitor, agent, scoreboard, coverage
│ ├── abp_reg_model/ # RAL register block + adapter
│ ├── seq/ # all sequences
│ ├── test/ # all tests
│ └── top/ # tb_top, protocol checker
├── sim/ # run.do, logs, coverage databases
└── scripts/ # Python regression automation
```
## Running the Regression

```bash
python3 scripts/run_regression.py
```

Compiles once, runs all 30 tests, merges per-test coverage into a single database, and generates text + HTML coverage reports with an uncovered-bin analysis.
