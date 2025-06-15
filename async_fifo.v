`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rahul Krishna J
// 
// Create Date: 06/15/2025
// Design Name: Asynchronous FIFO
// Module Name: async_fifo
// Project Name: Async FIFO Project
// Description: Asynchronous FIFO with independent read and write clocks
// 
//////////////////////////////////////////////////////////////////////////////////

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4  // 2^4 = 16 entries in FIFO
)(
    input wr_clk,
    input rd_clk,
    input rst,
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output full,
    output empty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write and read pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin = 0, rd_ptr_bin = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray = 0, rd_ptr_gray = 0;

    // Synchronized pointers (across clock domains)
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1 = 0, rd_ptr_gray_sync2 = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1 = 0, wr_ptr_gray_sync2 = 0;

    // Binary versions of synced gray pointers
    reg [ADDR_WIDTH:0] rd_ptr_bin_sync = 0, wr_ptr_bin_sync = 0;

    // FULL and EMPTY flags
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    // Write side logic
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);  // Binary to Gray
        end
    end

    // Read side logic
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_bin <= 0;
            rd_ptr_gray <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);  // Binary to Gray
        end
    end

    // Cross clock domain synchronization
    // Sync read pointer into write clock domain
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Sync write pointer into read clock domain
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

endmodule
