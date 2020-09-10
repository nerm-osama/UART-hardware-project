`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:46:17 08/29/2020 
// Design Name: 
// Module Name:    UART 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UART( tx_en,rx_en,reset,clock,tx,rx,data_in,data_out,parity_error,stop_error,data_ready
    );
input tx_en,rx_en,reset,clock,rx;
input [7:0] data_in;
output[7:0] data_out; 
output  tx ,parity_error,stop_error,data_ready;

TX tx_(.clock(clock),.tx(tx),.tx_en(tx_en),.data_in(data_in),.reset(reset));
RX rx_(.clock(clock), .RX_en(rx_en), .RX(rx),.reset(reset),.data_ready(data_ready),.data(data_out),.Pb_error(parity_error),.Sb_error(stop_error));
endmodule
