`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/13 21:07:19
// Design Name: 
// Module Name: wp_routing
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wp_routing(
    input clk,
    input rst_n,
    input start_signal,
    output finish_signal,
    output [15:0] array_row,
    output [15:0] array_col

    );

  maze_fpga_top maze_fpga_top_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start_signal(start_signal),
    .finish_signal(finish_signal),
    .array_row(array_row),
    .array_col(array_col)
  );


endmodule
