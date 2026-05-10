`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/19 19:28:43
// Design Name: 
// Module Name: maze_fpga_prop
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

// 传播结构阵列
module maze_fpga_array #(
    parameter N = 4,          // 阵列维度
    parameter SIZE = N * N,
    parameter WIDTH = $clog2(N)
) (
    input  logic clk,          // 时钟
    input  logic rst_n,        // 异步复位，低有效
    input  logic en_prop,      // 传播使能（可选，用于控制传播开始）
    output logic prop_buzy,    // 传播进行中标志（此处简化处理）
    // 障碍物配置：每个单元是否被设置为障碍物
    input  logic [N-1:0][N-1:0] en_obs,
    
    // 激活状态输出（可选，用于外部读取）
    output logic [N-1:0][N-1:0] act_out,
    output logic [N-1:0][N-1:0][1:0] prev_out
    // output logic fail_signal
);

    // 内部信号：每个单元的激活输出
    logic [N-1:0][N-1:0] act;

    // 实例化单元阵列
    generate
        genvar i, j;
        for (i = 0; i < N; i++) begin : row
            for (j = 0; j < N; j++) begin : col
                // 相邻连接信号（根据边界条件确定）
                logic up_act, down_act, left_act, right_act;

                // 上边邻居：如果 i == 0，则 up_act 为 0（无输入），否则取上一行同列的 act_out
                // if(i == 0 & j == 0) 
                //     assign up_act = en_prop;
                // else begin
                if (i == 0) 
                        assign up_act = 1'b0;
                else
                    assign up_act = act[i-1][j];
                // end

                // 下边邻居：如果 i == N-1，则 down_act 为 0，否则取下一行同列的 act_out
                if (i == N-1)
                    assign down_act = 1'b0;
                else
                    assign down_act = act[i+1][j];

                // 左边邻居：如果 j == 0，则 left_act 为 0，否则取左列同行的 act_out
                if (j == 0)
                    assign left_act = 1'b0;
                else
                    assign left_act = act[i][j-1];

                // 右边邻居：如果 j == N-1，则 right_act 为 0，否则取右列同行的 act_out
                if (j == N-1)
                    assign right_act = 1'b0;
                else
                    assign right_act = act[i][j+1];

                    
                if(i == 0 & j == 0) begin
                    assign up_act = en_prop;
                end


                // 实例化单元
                maze_fpga_cell cell_inst (
                    .clk        (clk),
                    .rst_n      (rst_n),
                    .en_obs     (en_obs[i][j]),
                    .up_act     (up_act),
                    .down_act   (down_act),
                    .left_act   (left_act),
                    .right_act  (right_act),
                    .act_out    (act[i][j]),
                    .prev_out   (prev_out[i][j])
                );
            end
        end
    endgenerate

    
    // 将内部激活信号输出到顶层
    assign act_out = act;

    // 简化 prop_buzy 控制：此处假设传播由外部状态机控制，
    // 仅输出 0 作为占位，实际应用可扩展为根据传播阶段自动拉高/拉低
    reg buzy;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buzy <= 0;
        end
        else begin
            if(buzy == 0)
                buzy <= en_prop;
            else
                buzy <= !act[N - 1][N - 1];
        end
        
    end


    assign prop_buzy = buzy;

endmodule
