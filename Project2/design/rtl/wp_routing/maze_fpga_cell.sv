`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/21 23:14:40
// Design Name: 
// Module Name: maze_fpga_cell
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



// 重复单元
module maze_fpga_cell(
    input clk,
    input rst_n,
    input en_obs,
    input up_act,
    input down_act,
    input left_act,
    input right_act,
    output act_out,
    output [1:0]prev_out
);

// 三类寄存器，用于保存1.上一个结点 2.是否激活 3.是否是障碍物
reg [1:0]prev; //2'b00: up, 2'b01:down, 2'b10: left, 2'b11: right
reg obs;
reg act;

//对选择后的信号进行处理
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        obs <= 1'b0;
    end
    else begin
        obs <= en_obs | obs;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        act <= 1'b0;
    end
    else begin
        act <= (act | up_act | down_act | left_act | right_act) & ! obs;
    end
end

//符合条件即更新
reg [1:0] new_prev;
always @(*) begin
    casez({up_act, down_act, left_act, right_act})
        4'b1???: new_prev = 2'b00;
        4'b01??: new_prev = 2'b01;
        4'b001?: new_prev = 2'b10;
        4'b0001: new_prev = 2'b11;
        default: new_prev = 2'b00;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        prev <= 2'b0;
    end
    else begin
        if(!act) begin
            prev <= new_prev & {!obs, !obs};
        end
    end
end

assign act_out = act;
assign prev_out = prev;

endmodule