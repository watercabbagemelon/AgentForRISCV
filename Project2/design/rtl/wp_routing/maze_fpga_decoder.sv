`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/13 19:48:00
// Design Name: 
// Module Name: maze_fpga_decoder
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


module maze_fpga_decoder(
    input clk,
    input rst_n,
    input en_write,
    input [6:0]addr,
    input [7:0]data,
    output reg [15:0]row,
    output reg [15:0]col
    );

    reg [7:0] path[127:0];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < 128; i++) begin
                path[i] <= 8'b0;
            end
        end else begin
            if(en_write)
                path[addr] <= data;
        end
    end

    reg [6:0]cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 7'b0;
        end else begin
            if(en_write)
                cnt <= cnt + 1;
        end
    end

    reg [6:0]sel;
        always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sel <= 7'b0;
        end else begin
            if(sel == cnt)
                sel <= 7'b0;
            else
                sel <= sel + 1;
        end
    end

    wire [3:0]sel_row;
    wire [3:0]sel_col;
    assign sel_row = path[sel][7:4];
    assign sel_col = path[sel][3:0];
    always @(*) begin
        row = 16'b1 << sel_row;
        col = 16'b1 << sel_col; 
    end


endmodule
