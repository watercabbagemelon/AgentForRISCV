`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/22 12:42:14
// Design Name: 
// Module Name: maze_fpga_back
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


module maze_fpga_back #(
    parameter N = 4,
    parameter SIZE = N * N,
    parameter WIDTH = $clog2(N)
)
(
    input clk,
    input rst_n,
    input en_back,
    input [N-1:0][N-1:0][1:0] prev_in,
    output back_buzy,
    output write_en,
    output [2 * WIDTH - 1: 0] addr,
    output [WIDTH-1:0] row,
    output [WIDTH-1:0] col
    );


    reg buzy;
    reg done;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buzy <= 1'b0;
        end
        else begin
            if(buzy==1'b0) begin
                buzy <= en_back;
            end
            else begin
                buzy <= !done;
            end
        end
        
    end

    reg [2*WIDTH-1:0]cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end
        else begin
            if(en_back)
                cnt <= 0;
            else if(buzy)
                cnt <= cnt + 1;
            else
                cnt <= 0;
        end
    end



    reg [WIDTH-1:0]row_reg;
    reg [WIDTH-1:0]col_reg;

    // 用组合逻辑 mux 展开动态双重索引，避免 Yosys 不支持的 packed array 动态索引
    reg [1:0] prev_sel;
    integer ii, jj;
    always @(*) begin
        prev_sel = 2'b00;
        for (ii = 0; ii < N; ii = ii + 1)
            for (jj = 0; jj < N; jj = jj + 1)
                if (row_reg == ii[WIDTH-1:0] && col_reg == jj[WIDTH-1:0])
                    prev_sel = prev_in[ii][jj];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            row_reg <= -1;
            col_reg <= -1;
        end
        else if(en_back) begin
            row_reg <= -1;
            col_reg <= -1;
        end
        else if(buzy) begin
            case(prev_sel)
                2'b00: begin
                    row_reg <= row_reg - 1;
                    col_reg <= col_reg;
                end
                2'b01: begin
                    row_reg <= row_reg + 1;
                    col_reg <= col_reg;
                end
                2'b10: begin
                    row_reg <= row_reg;
                    col_reg <= col_reg - 1;
                end
                2'b11: begin
                    row_reg <= row_reg + 1;
                    col_reg <= col_reg;
                end
                default: begin
                    row_reg <= row_reg;
                    col_reg <= col_reg;
                end
            endcase
        end
    end

    always @(*) begin
        if(!((|row) | (|col)))
            done = 1'b1;
        else
            done = 1'b0;
    end

    wire [1:0] prev = prev_sel;
    assign back_buzy = buzy;
    assign write_en = buzy;
    assign addr = cnt;
    assign row = row_reg;
    assign col = col_reg;


endmodule
