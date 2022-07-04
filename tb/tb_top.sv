module tb_top
(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic en_i,
  output logic blinky_o
);

  blinky U_BLINKY (
    .clk_i,
    .rst_ni,
    .en_i,
    .blinky_o
  );

  integer blink_time;
  logic blink_q;
  logic blink;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) blink_q <= '0;
    else blink_q <= blinky_o;
  end
  assign blink = blinky_o ^ blink_q;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      blink_time <= 'd0;
    end else if (blink) begin
      blink_time <= blink_time + 1;
      if (blink_time == 'd20) $finish;
    end
  end

  initial begin
    if ($test$plusargs("trace") != 0) begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dumps.vcd");
      $dumpvars();
    end
    $display("[%0t] Model running...\n", $time);
  end


endmodule
