
        vsim -c -voptargs="+acc" \
        -sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi \
        work.tb_top -sv_seed 2 \
        +UVM_VERBOSITY=UVM_LOW \
        +UVM_TESTNAME=apb_full_regression_soak_test \
        -do "coverage save -onexit D:/my_projects/APB_PROTOCOL/apb_regs_uvm/coverage_runs/apb_full_regression_soak_test_seed2.ucdb; run -all; quit"
    