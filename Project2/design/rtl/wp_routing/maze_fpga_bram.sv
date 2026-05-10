`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/22 14:30:14
// Design Name: 
// Module Name: maze_fpga_bram
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


module maze_fpga_bram #(
    parameter N = 16,
    parameter SIZE = N * N,
    parameter WIDTH = $clog2(N)
    )
    (
    input clk,
    input rst_n,
    input [3: 0]addr_r,
    output [N - 1: 0]data_r
    );


    reg [15: 0]maze[15: 0];
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            maze[0] <= 16'b1010_1010_1010_0110;
            maze[1] <= 16'b0000_0000_0000_0100;
            maze[2] <= 16'b0010_0000_0000_1000;
            maze[3] <= 16'b0001_0001_0000_1000;

            maze[4] <= 16'b0000_0000_0000_0000;
            maze[5] <= 16'b0000_0000_0001_0000;
            maze[6] <= 16'b0000_0010_0001_0100;
            maze[7] <= 16'b0000_0000_0001_0000;

            maze[8] <= 16'b0000_0010_0001_0000;
            maze[9] <= 16'b1010_0001_0010_0000;
            maze[10] <= 16'b0000_1000_0010_0000;
            maze[11] <= 16'b1000_0000_0010_0100;

            maze[12] <= 16'b0001_0010_0010_0001;
            maze[13] <= 16'b0000_0000_1000_0001;
            maze[14] <= 16'b0001_0000_1001_0010;
            maze[15] <= 16'b0100_0001_0100_0100;

        end
    end

    reg [15:0] maze_out;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            maze_out <= 16'b0;
        end
        else begin
            maze_out <= maze[addr_r];
        end
    end
    assign data_r = maze_out;


endmodule
