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


module maze_fpga_load#(
    parameter N = 4,
    parameter SIZE = N * N,
    parameter WIDTH = $clog2(N)
)(
    input clk,
    input rst_n,
    input en_load,

    output [2 * WIDTH-1:0]addr,
    input [N-1:0]obs_data,



    output load_buzy,
    output [N-1:0][N-1:0]obs
    );

    reg [2 * WIDTH-1:0]cnt;
    wire done;
    reg buzy;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buzy <= 0;
        end
        else begin
            if(!buzy)
                buzy <= en_load;
            else
                buzy <= !done;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end
        else begin
            if(en_load)
                cnt <= 0;
            else if(buzy)
                cnt <= cnt + 1;
            else
                cnt <= cnt;
                
        end
    end
    assign done = (cnt == N - 1);

    reg [2 * WIDTH-1:0]cnt_buffer;
        always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_buffer <= 0;
        end
        else begin
            cnt_buffer <= cnt;  
        end
    end



    reg buzy_buffer;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buzy_buffer <= 0;
        end
        else begin
            buzy_buffer <= buzy;  
        end
    end


    assign addr = cnt;

    integer i, j;
    reg [N-1:0][N-1:0] obs_reg ;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < N; i++) begin
                obs_reg[i] <= 0;
            end
        end
        else if(buzy_buffer) begin
            obs_reg[cnt_buffer] <= obs_data;
        end
    end

    assign obs = obs_reg;
    assign load_buzy = buzy;


endmodule