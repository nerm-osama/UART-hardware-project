`timescale 1us / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:30:15 08/27/2020
// Design Name:   TX
// Module Name:   E:/digitalll/UART/test_uart.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_tx;

	// Inputs
	reg clock;
	reg tx_en;
	reg [7:0] data_in;
	reg reset;

	// Outputs
	wire tx;

	// Instantiate the Unit Under Test (UUT)
	TX uut (
		.clock(clock), 
		.tx(tx), 
		.tx_en(tx_en), 
		.data_in(data_in), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		tx_en = 0;
		data_in = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#10;
		reset =1 ;
		#5
		tx_en = 1;
		data_in=8'b11001001;
		#5
		tx_en =0;
		
      #1200
		/*tx_en = 1;
		data_in=8'b01101101;
		#5
		tx_en =0;
		#1400*/
			$finish;
		// Add stimulus here
 
	end
      always #2.5 clock = ~ clock;
endmodule

