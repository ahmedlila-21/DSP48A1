vlib work
vlog dsp48A1_tb.v dsp48A1.v reg_mux_module.v
vsim -voptargs=+acc dsp_tb
add wave *
run -all
#quit -sim