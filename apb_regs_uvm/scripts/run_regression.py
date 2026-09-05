#!/usr/bin/env python3
import subprocess
import os
import re
import sys
import time

TESTS = [
    "apb_single_write_read_test",
    "apb_all_regs_write_read_test",
    "apb_back_to_back_wr_rd_test",
    "apb_reset_value_check_test",
    "apb_readonly_write_attempt_test",
    "apb_address_decode_isolation_test",
    "apb_first_reg_access_test",
    "apb_last_reg_access_test",
    "apb_walking_ones_data_test",
    "apb_walking_zeros_data_test",
    "apb_all_ones_all_zeros_test",
    "apb_same_reg_repeated_access_test",
    "apb_hole_address_access_test",
    "apb_out_of_range_high_test",
    "apb_out_of_range_low_test",
    "apb_unmapped_addr_read_test",
    "apb_unmapped_addr_write_test",
    "apb_repeated_unmapped_access_test",
    "apb_readonly_write_error_check_test",
    "apb_reset_then_immediate_write_test",
    "apb_reset_retains_readonly_init_test",
    "apb_reset_mid_transaction_test",
    "apb_back_to_back_reset_pulses_test",
    "apb_idle_setup_access_test",
    "apb_paddr_pwdata_stability_test",
    "apb_pready_wait_state_test",
    "apb_random_addr_data_mixed_test",
    "apb_random_back_to_back_burst_test",
    "apb_random_with_idle_gaps_test",
    "apb_full_regression_soak_test",
]
# Excluded (stub/never implemented): apb_partial_write_pstrb_test,
# apb_power_on_reset_values_test, apb_consecutive_transfer_no_idle_test

RANDOM_SEEDS = {
    "apb_full_regression_soak_test": [1, 2],
}

# Tests that need the driver's reset-abort watcher — these two set
# enable_reset_watch themselves inside their own build_phase(), so no
# extra flag is needed here; listed for documentation only.
RESET_WATCH_TESTS = {"apb_reset_mid_transaction_test", "apb_back_to_back_reset_pulses_test"}

COV_DIR = "coverage_runs"
MERGED_UCDB = os.path.join(COV_DIR, "merged_final.ucdb")
MERGED_REPORT = os.path.join(COV_DIR, "merged_coverage_report.txt")
HTML_DIR = os.path.join(COV_DIR, "coverage_html_report")

UVM_DPI_LIB = "C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi"

MAX_RETRIES = 3
RETRY_DELAY_SEC = 20


def run_cmd(script_text, description):
    print(f"\n{'='*70}\n{description}\n{'='*70}")
    with open("_temp_run.do", "w") as f:
        f.write(script_text)
    result = subprocess.run(["bash", "-c", "vsim -c -do _temp_run.do"],
                             capture_output=True, text=True, errors='replace')
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    return result


def compile_once():
    """Steps 1-6 from your run.do -- compile everything ONE time, verbatim."""
    script = r"""
        if {[file exists work]} {
        vdel -lib work -all
        }
        vlib work
        vlog -sv -cover bcst +incdir+D:/uvm-1.2/src D:/uvm-1.2/src/uvm_pkg.sv
        vlog -work work rtl/apb-master/src/apb_pkg.sv
        vlog -work work rtl/common_cells-master/include/common_cells/registers.svh
        vlog -work work rtl/common_cells-master/include/common_cells/assertions.svh
        vlog -work work rtl/common_cells-master/src/deprecated/cf_math_pkg.sv
        vlog -work work rtl/common_cells-master/src/cc_addr_decode_dync.sv
        vlog -work work rtl/common_cells-master/src/cc_addr_decode.sv
        vlog -work work rtl/common_cells-master/src/deprecated/addr_decode.sv
        vlog -work work rtl/apb-master/src/apb_regs.sv
        vlog -work work tb/env/apb_if.sv
        vlog -work work \
        +incdir+D:/uvm-1.2/src \
        +incdir+tb \
        +incdir+tb/abp_reg_model \
        +incdir+tb/env \
        +incdir+tb/seq \
        +incdir+tb/test \
        +incdir+tb/top \
        tb/env/apb_uvm_pkg.sv \
        tb/top/tb_top.sv
        quit
    """
    return run_cmd(script, "COMPILING ONCE (all files)")


def run_single_test(testname, tcl_safe_ucdb_path, seed=None):
    """Same simulation section as your run.do, minus waveforms, -c batch mode."""
    seed_val = seed if seed else "random"
    script = f"""
        vsim -c -voptargs="+acc" \\
        -sv_lib {UVM_DPI_LIB} \\
        work.tb_top -sv_seed {seed_val} \\
        +UVM_VERBOSITY=UVM_LOW \\
        +UVM_TESTNAME={testname} \\
        -do "coverage save -onexit {tcl_safe_ucdb_path}; run -all; quit"
    """
    for attempt in range(1, MAX_RETRIES + 1):
        label = f"Running test: {testname}" + (f" (seed={seed})" if seed else "") + f" [attempt {attempt}/{MAX_RETRIES}]"
        result = run_cmd(script, label)

        if "vsim-160" in result.stdout and "Null foreign function pointer" in result.stdout:
            print(f"\n  -> DPI load failure (attempt {attempt}/{MAX_RETRIES}).")
            if attempt < MAX_RETRIES:
                print(f"  -> Waiting {RETRY_DELAY_SEC}s and retrying...")
                time.sleep(RETRY_DELAY_SEC)
                continue
            else:
                print(f"\n  *** ABORTING: {testname} failed after {MAX_RETRIES} attempts. ***")
                sys.exit(1)

        if not os.path.exists(tcl_safe_ucdb_path):
            print(f"  ** WARNING: {tcl_safe_ucdb_path} was not created. Check output above.")
        return result


def main():
    os.makedirs(COV_DIR, exist_ok=True)
    compile_once()

    ucdb_files = []
    for testname in TESTS:
        if testname in RANDOM_SEEDS:
            for seed in RANDOM_SEEDS[testname]:
                ucdb_path = os.path.abspath(os.path.join(COV_DIR, f"{testname}_seed{seed}.ucdb"))
                windows_ucdb_path = subprocess.check_output(['cygpath', '-w', ucdb_path]).decode().strip()
                tcl_safe_ucdb_path = windows_ucdb_path.replace('\\', '/')
                run_single_test(testname, tcl_safe_ucdb_path, seed=seed)
                ucdb_files.append(tcl_safe_ucdb_path)
        else:
            clean_testname = testname.removeprefix("apb_")
            ucdb_path = os.path.abspath(os.path.join(COV_DIR, f"{clean_testname}.ucdb"))
            windows_ucdb_path = subprocess.check_output(['cygpath', '-w', ucdb_path]).decode().strip()
            tcl_safe_ucdb_path = windows_ucdb_path.replace('\\', '/')
            run_single_test(testname, tcl_safe_ucdb_path)
            ucdb_files.append(tcl_safe_ucdb_path)

    existing = [f for f in ucdb_files if os.path.exists(f)]
    missing = [f for f in ucdb_files if f not in existing]
    if missing:
        print(f"\n** WARNING: {len(missing)} .ucdb files missing, excluded from merge:")
        for m in missing:
            print(f"    {m}")

    merge_cmd = ["vcover", "merge", "-testassociated", MERGED_UCDB] + existing
    print(f"\n{'='*70}\nMerging {len(existing)} .ucdb files\n{'='*70}")
    r = subprocess.run(merge_cmd, capture_output=True, text=True)
    print(r.stdout, r.stderr)

    r = subprocess.run(["vcover", "report", "-details", MERGED_UCDB], capture_output=True, text=True)
    with open(MERGED_REPORT, "w") as f:
        f.write(r.stdout)
    print(f"Text report saved to {MERGED_REPORT}")

    r = subprocess.run(["vcover", "report", "-html", "-htmldir", HTML_DIR, "-verbose", MERGED_UCDB],
                        capture_output=True, text=True)
    print(f"HTML report saved to {HTML_DIR}/index.html")

    r = subprocess.run(["vcover", "report", "-testdetails", MERGED_UCDB], capture_output=True, text=True)
    with open(os.path.join(COV_DIR, "testdetails_report.txt"), "w") as f:
        f.write(r.stdout)

    analyze_report(MERGED_REPORT)


def analyze_report(report_path):
    if not os.path.exists(report_path):
        print("No report file found.")
        return
    with open(report_path) as f:
        lines = f.readlines()

    print(f"\n{'='*70}\nUNCOVERED BINS (excluding ignore_bins)\n{'='*70}")
    found_any = False
    current_cp = None
    bin_re = re.compile(r'^\s*(bin|ignore_bin)\s+(\S+)\s+(\d+)\s+(\d+)')
    cp_re = re.compile(r'^\s*(Coverpoint|Cross)\s+(\S+)')

    for line in lines:
        cp_m = cp_re.match(line)
        if cp_m:
            current_cp = cp_m.group(2)
            continue
        b_m = bin_re.match(line)
        if b_m:
            btype, bname, hits, goal = b_m.groups()
            if btype == "ignore_bin":
                continue
            if int(hits) == 0:
                found_any = True
                print(f"  MISS -> Coverpoint: {current_cp:30s} Bin: {bname}")

    if not found_any:
        print("  None found -- all non-ignored bins are hit!")


if __name__ == "__main__":
    main()
