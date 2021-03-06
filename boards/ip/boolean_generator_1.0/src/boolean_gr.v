`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: boolean_gr
// Project Name: PYNQ_Interface
// Target Devices: Z7020
// Description: This module converts relatively longer start pulse from GPIO write
//			    to a single clock pulse which is fed to the fsm. The 32-bit init 
//				value is provided by the 32-bit register. The fsm generates cdi and 
//				ce which are used by the boolean_bit0 to shift data in. boolean_sel takes
//              20 header pins + 4 push buttons input and routes up to 5 selected pins 
//              to the input of boolean_bit0 which generates computed output according to  
//              the programmed function. Output of boolean_bit0 can be driven to the 
//				corresponding header pin and/or LED. 
// 
//////////////////////////////////////////////////////////////////////////////////


module boolean_gr(
    input clk,                          // clock to shift init value in
    input [23:0] boolean_data_i,    	// 24 header pins input
    input start,                        // start reconfigure CFGLUT
    input [31:0] fn_init_value,         // reconfigure CFGLUT value
    input [24:0] boolean_input_sel,      // 5 bits per input pin, 5 input 
    output boolean_data_o            	// output result
    );
    
    wire ce;
    wire CLR;
    wire [4:0] boolean_i;
     
    // Convert longer then 1 clocks pulse generated by GPIO write to one clock pulse
    FDCE #(
           .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
        ) FDCE_inst (
           .Q(Q1),      // 1-bit Data output
           .C(start),      // 1-bit Clock input
           .CE(1'b1),    // 1-bit Clock enable input
           .CLR(CLR),  // 1-bit Asynchronous clear input
           .D(1'b1)       // 1-bit Data input
        );

    FDCE #(
           .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
        ) FDCE_inst_1 (
           .Q(CLR),      // 1-bit Data output
           .C(clk),      // 1-bit Clock input
           .CE(1'b1),    // 1-bit Clock enable input
           .CLR(1'b0),  // 1-bit Asynchronous clear input
           .D(Q1)       // 1-bit Data input
        );

    boolean_fsm fsm(.clk(clk), .start(CLR), .fn_init_value(fn_init_value), .cdi(cdi), .ce(ce), .done(done));
    
    boolean_input input_sel (.sel(boolean_input_sel), .datapin(boolean_data_i), .boolean_o(boolean_i));
    
    boolean_lut boolean_bit0 (.clk(clk), .ce(ce), .data_in(boolean_i), .CDI(cdi), .result(boolean_data_o));
    
endmodule
