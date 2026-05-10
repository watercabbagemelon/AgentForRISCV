`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/22 15:43:19
// Design Name: 
// Module Name: maze_fpga_ctrl
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


module maze_fpga_ctrl(
    input clk,
    input rst_n,
    input start_signal,
    input load_buzy,
    input prop_buzy,
    input back_buzy,

    output en_load,
    output en_prop,
    output en_back,
    output finish_signal,

    input fail_signal
    );
    
    reg [1:0]cur_state; // 2'b00: wait, 2'b01: load, 2'b10: prop, 2'b11: back
    reg [1:0]next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cur_state <= 2'b0;
        end
        else begin
            cur_state <= next_state;
        end
    end


    reg load;
    reg prop;
    reg back;
    always @(*) begin
        case(cur_state)
            2'b00: begin
                load = 1'b1;
                prop = 1'b0;
                back = 1'b0;
            end
            2'b01: begin
                load = 1'b0;
                prop = 1'b1;
                back = 1'b0;
            end
            2'b10: begin
                load = 1'b0;
                prop = 1'b0;
                back = 1'b1;
            end
            2'b11: begin
                load = 1'b0;
                prop = 1'b0;
                back = 1'b0;
            end
            default: begin
                load = 1'b0;
                prop = 1'b0;
                back = 1'b0;

            end
        endcase
    end


    reg load_buzy_buffer;
    reg prop_buzy_buffer;
    reg back_buzy_buffer;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            load_buzy_buffer <= 1'b0;
            prop_buzy_buffer <= 1'b0;
            back_buzy_buffer <= 1'b0;
        end
        else begin
            load_buzy_buffer <= load_buzy;
            prop_buzy_buffer <= prop_buzy;
            back_buzy_buffer <= back_buzy;
        end
    end

    assign en_load = start_signal;
    assign en_prop = load_buzy_buffer & !load_buzy;
    assign en_back = prop_buzy_buffer & !prop_buzy;
    assign finish_signal = back_buzy_buffer & !back_buzy;


    always @(*) begin
        case(cur_state)
            2'b00: begin
                if(en_load)
                    next_state = 2'b01;
                else
                    next_state = cur_state;
            end
            2'b01: begin
                if(en_prop)
                    next_state = 2'b10;
                else
                    next_state = cur_state;
            end
            2'b10: begin
                if(en_back)
                    next_state = 2'b11;
                else
                    next_state = cur_state;
            end
            2'b11: begin
                if(finish_signal)
                    next_state = 2'b00;
                else
                    next_state = cur_state;
            end
            default: begin
                next_state = 2'b00;
            end
        endcase
    end



endmodule
