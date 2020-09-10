`timescale 1us / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:49:19 08/28/2020
// Design Name:   RX
// Module Name:   E:/digitalll/UART/test_rx.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: RX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_rx;

	// Inputs
	reg clock;
	reg RX_en;
	reg RX;
	reg reset;

	// Outputs
	wire data_ready;
	wire [7:0] data;
	wire Pb_error;
	wire Sb_error;

	// Instantiate the Unit Under Test (UUT)
	RX uut (
		.clock(clock), 
		.RX_en(RX_en), 
		.RX(RX), 
		.reset(reset), 
		.data_ready(data_ready), 
		.data(data), 
		.Pb_error(Pb_error), 
		.Sb_error(Sb_error)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		RX_en = 0;
		RX = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#10;
		reset = 1;
		#5
		RX_en = 1;
		#5
		RX_en = 0;
		RX=1;
		#5
		
		RX=0;
		#151
		
		RX=1;
		#100
		
		RX=1;
		#100
		
		RX=0;
      #100
		
		RX=1;
		#100
		
		RX=1;
		#100
		
		RX=0;
		#300
		RX=1;
		#100
		RX=0;
		
		#200
		$finish;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// Add stimulus here

	end
   always #2.5 clock = ~ clock;   
endmodule

