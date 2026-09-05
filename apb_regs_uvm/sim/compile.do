if {[file exists work]} {
    vdel -lib work -all
}
vlib work

vlog -sv -cover bcst "+incdir+D:/uvm-1.2/src" D:/uvm-1.2/src/uvm_pkg.sv

vlog -work work +incdir+rtl/apb-master/include +incdir+rtl/common_cells-master/include rtl/common_cells-master/src/deprecated/addr_decode.sv
vlog -work work +incdir+rtl/apb-master/include +incdir+rtl/common_cells-master/include rtl/apb-master/src/apb_pkg.sv
vlog -work work +incdir+rtl/apb-master/include +incdir+rtl/common_cells-master/include rtl/apb-master/src/apb_regs.sv

vlog -work work tb/env/apb_if.sv

vlog -work work \
    +incdir+D:/uvm-1.2/src \
    +incdir+tb/env \
    +incdir+tb/abp_reg_model \
    +incdir+tb/seq \
    +incdir+tb/test \
    +incdir+tb/top \
    tb/env/apb_uvm_pkg.sv \
    tb/top/tb_top.sv

quit -f
