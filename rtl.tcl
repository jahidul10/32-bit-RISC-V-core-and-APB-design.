##rtl.tcl file adapted from http://ece.colorado.edu/~ecen5007/cadence/
##this tells the compiler where to look or the libraries


set_attribute lib_search_path /home/vlsi05/library

## This defines the libraries to use

set_attribute library {slow_vdd1v0_basicCells.lib fast_vdd1v0_basicCells.lib}

##This must point to your VHDL/verilog file


read_hdl -sv alu.sv
read_hdl -sv aludec.sv
read_hdl -sv bu.sv
read_hdl -sv extend.sv
read_hdl -sv instrdec.sv
read_hdl -sv regfile.sv
read_hdl -sv flopr.sv
read_hdl -sv flopenr.sv
read_hdl -sv lsu.sv
read_hdl -sv mux2.sv
read_hdl -sv mux3.sv
read_hdl -sv mainfsm.sv
read_hdl -sv controller.sv
read_hdl -sv datapath.sv
read_hdl -sv riscvmulti.sv


## This builts the general block
elaborate

##this allows you to define a clock and the maximum allowable delays
## READ MORE ABOUT THIS SO THAT YOU CAN PROPERLY CREATE A TIMING FILE
#set clock [define_clock -period 300 -name clk]
#external delay -input 300 -edge rise clk
#external delay -output 2000 -edge rise p1

##This synthesizes your code
synthesize -to_mapped

## This writes all your files
## change the tst to the name of your top level verilog
## CHANGE THIS LINE: CHANGE THE "accu" PART REMEMBER THIS
## FILENAME YOU WILL NEED IT WHEN SETTING UP THE PLACE & ROUTE
write -mapped > synth_codes/core_synth.v

## THESE FILES ARE NOT REQUIRED, THE SDC FILE IS A TIMING FILE
write_script > script