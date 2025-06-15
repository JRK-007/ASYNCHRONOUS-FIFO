`timescale 1ns/1ps

module async_fifo_tb;

  // Declare testbench signals
  reg wr_clk = 0;
  reg rd_clk = 0;
  reg rst = 1;
  reg wr_en = 0;
  reg rd_en = 0;
  reg [7:0] din = 0;
  wire [7:0] dout;
  wire full, empty;

  // Instantiate DUT
  async_fifo uut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  // Clock generators
  always #5 wr_clk = ~wr_clk; // 10ns write clock
  always #7 rd_clk = ~rd_clk; // 14ns read clock

  // Stimulus
  initial begin
    // Reset
    #10 rst = 0;

    // Write data into FIFO
    repeat(8) begin
      @(posedge wr_clk);
      wr_en = 1;
      din = din + 1;
    end
    wr_en = 0;

    // Wait a bit
    #50;

    // Read data from FIFO
    repeat(8) begin
      @(posedge rd_clk);
      rd_en = 1;
    end
    rd_en = 0;

    #50 $finish;
  end

endmodule
