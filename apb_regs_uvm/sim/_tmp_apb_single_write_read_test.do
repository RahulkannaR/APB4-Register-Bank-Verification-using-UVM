# ============================================================================
# UVM Compilation and Execution Script for APB Regs (apb_regs, pulp-platform)
# ============================================================================

# //1. Clean the environment (Delete old compiled libraries)
if {[file exists work]} {
    vdel -lib work -all
}

# //2. Create a fresh work library
vlib work

# //3. UVM 1.2 folder
vlog -sv -cover bcst +incdir+D:/uvm-1.2/src D:/uvm-1.2/src/uvm_pkg.sv

# //4. Compile the RTL (Hardware Design)
# //Assuming you are running this from the sim/ directory
# //>>> CONFIRM this folder name matches your actual clone/download of
# //>>> pulp-platform/apb before running <
vlog -work work rtl/apb-master/src/apb_pkg.sv
vlog -work work rtl/common_cells-master/include/common_cells/registers.svh
vlog -work work rtl/common_cells-master/include/common_cells/assertions.svh
vlog -work work rtl/common_cells-master/src/deprecated/cf_math_pkg.sv
vlog -work work rtl/common_cells-master/src/cc_addr_decode_dync.sv
vlog -work work rtl/common_cells-master/src/cc_addr_decode.sv
vlog -work work rtl/common_cells-master/src/deprecated/addr_decode.sv
vlog -work work rtl/apb-master/src/apb_regs.sv

# //5. Compile the Interface (Must compile before UVM classes)
vlog -work work tb/env/apb_if.sv

# //6. Compile the UVM Environment (The Top Level)
# //+incdir+ tells Questa where to find files `included inside apb_uvm_pkg.sv
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

# //7. Load the Simulation
# //+acc ensures our signals aren't optimized away so we can see them in waveforms
# //+UVM_TESTNAME tells the UVM factory exactly which test to run!
vsim -voptargs="+acc" \
     -sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi \
     work.tb_top -sv_seed random \
	 +UVM_VERBOSITY=UVM_HIGH \
     +UVM_TESTNAME=apb_single_write_read_test \
	 -do "coverage save -onexit sim/coverage/apb_single_write_read_test.ucdb;"

# //8. Add Waveforms
# //Physical interface + DUT internal state



# //Format the waves to be easily readable






# //9. Run the Simulation completely
run -all

# //10. Generate and print the Functional Coverage Report to the transcript
#coverage report -detail -cvg

quit -sim
quit -f
