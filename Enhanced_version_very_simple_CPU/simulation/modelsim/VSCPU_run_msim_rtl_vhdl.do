transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/intelFPGA_lite/18.1/project files/EVSCPU/my_package.vhd}
vcom -93 -work work {C:/intelFPGA_lite/18.1/project files/EVSCPU/VSCPU.vhd}

vcom -93 -work work {C:/intelFPGA_lite/18.1/project files/EVSCPU/vscputb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  vscputb

add wave *
view structure
view signals
run -all
