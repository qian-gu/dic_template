module counter #(
  parameter int unsigned DW = 8
 ) (
  input  logic            clk_i,
  input  logic            rst_ni,
  input  logic            en_i,
  output logic [DW-1 : 0] count_o
);

  logic [DW-1 : 0] count;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      count_o <= '0;
    end else if (en_i) begin
      count_o <= count_o + 1'b1;
    end
  end

endmodule

