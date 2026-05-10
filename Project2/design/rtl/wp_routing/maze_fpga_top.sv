`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/22 15:40:45
// Design Name: 
// Module Name: maze_fpga_top
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


module maze_fpga_top #(
    // Parameters
    localparam  N = 16,
    localparam  SIZE = N * N,
    localparam  WIDTH = $clog2(N)
)
(
    input clk,
    input rst_n,
    input start_signal,
    output finish_signal,
    output [15:0]array_row,
    output [15:0]array_col
);
    //使能线
  wire en_load;
  wire en_prop;
  wire en_back;
//当前状态
  wire load_buzy;
  wire prop_buzy;
  wire back_buzy;



//控制模块
  maze_fpga_ctrl  maze_fpga_ctrl_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start_signal(start_signal),
    .load_buzy(load_buzy),
    .prop_buzy(prop_buzy),
    .back_buzy(back_buzy),
    .en_load(en_load),
    .en_prop(en_prop),
    .en_back(en_back),
    .finish_signal(finish_signal)
  );




//加载地址线和数据线
  //串行读取障碍物
  wire [2 * WIDTH-1:0] obs_addr;
  wire  [N-1:0] obs_data;

  //输出障碍物信息
  wire [N-1:0][N-1:0] obs;





//加载模块
  maze_fpga_load # (
    .N(N),
    .SIZE(SIZE),
    .WIDTH(WIDTH)
  )
  maze_fpga_load_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en_load(en_load),
    .addr(obs_addr),
    .obs_data(obs_data),
    .load_buzy(load_buzy),
    .obs(obs)
  );


//阵列输出信号，将迭代结果并行输出
wire [N-1:0][N-1:0] act_out;
  wire [N-1:0][N-1:0][1:0] prev_out;
  maze_fpga_array # (
    .N(N),
    .SIZE(SIZE)
  )
  maze_fpga_array_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en_prop(en_prop),
    .prop_buzy(prop_buzy),
    .en_obs(obs),
    .act_out(act_out),
    .prev_out(prev_out)
  );


  //回溯模块
  //串行寻找路径
  wire write_en;
  wire [2 * WIDTH - 1: 0] path_addr;
  wire [WIDTH-1:0] row;
  wire [WIDTH-1:0] col;

  //
  maze_fpga_back # (
    .N(N),
    .SIZE(SIZE)
  )
  maze_fpga_back_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en_back(en_back),
    .prev_in(prev_out),
    .back_buzy(back_buzy),
    .write_en(write_en),
    .addr(path_addr),
    .row(row),
    .col(col)

  );


  maze_fpga_bram # (
    .N(N),
    .SIZE(SIZE),
    .WIDTH(WIDTH)
  )
  maze_fpga_bram_inst (
    .clk(clk),
    .rst_n(rst_n),
    .addr_r(obs_addr),
    .data_r(obs_data)
  );


  maze_fpga_decoder  maze_fpga_decoder_inst (
      .clk(clk),
      .rst_n(rst_n),
      .en_write(write_en),
      .addr(path_addr),
      .data({row, col}),
      .row(array_row),
      .col(array_col)
  );


endmodule
