module blinky
  import blinky_pkg::*;
(
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic  en_i,
  output logic  blinky_o
);

  logic [CNT_DW-1 : 0] count;

  localparam logic [CNT_DW-1 : 0] HALF = {1'b0, {(CNT_DW-1){1'b1}}};
  localparam logic [CNT_DW-1 : 0] MAX  = {CNT_DW{1'b1}};

  counter #(
    .DW(CNT_DW)
  ) U_COUNTER (
    .clk_i,
    .rst_ni,
    .en_i,
    .count_o(count)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      blinky_o <= '0;
    end else if ((count == HALF) | (count == MAX)) begin
      blinky_o <= ~blinky_o;
    end
  end

endmodule
