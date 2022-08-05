//=============================================================================
// Filename      : blinky.sv
// Author        : Qian Gu
// Email         : guqian110@gmail.com
// Created on    : 2022-08-01 09:31:15 PM
// Last Modified : 2022-08-05 02:56:45 PM
//
//=============================================================================
/// Dirve a LED to blink.
///
/// ## Limitations
///
/// - this module does **NOT** support blink frequency
/// - this module instantiate a submodule([`step_counter`](module.step_counter.html)) to generate wave
/// - the counter width is set via [`package::CounterWidth`](package.blinky_pkg.html)
module blinky
  import blinky_pkg::*;
(
  /// Rising-edge clock
  input  logic  clk_i,
  /// Asynchronous reset, active low
  input  logic  rst_ni,
  /// Enable port
  input  logic  en_i,
  /// Blink output
  output logic  blinky_o
);

  /// Blink period
  localparam logic [CounterWidth-1 : 0] Max  = {CounterWidth{1'b1}};
  /// Blink half period
  localparam logic [CounterWidth-1 : 0] Half = {1'b0, {(CounterWidth-1){1'b1}}};

  /// Counter result
  logic [CounterWidth-1 : 0] count;

  ///////////////////////////
  // instantiate submodule //
  ///////////////////////////

  step_counter #(
    .CounterWidth(CounterWidth)
  ) i_step_counter (
    .clk_i,
    .rst_ni,
    .en_i,
    .count_o(count)
  );

  //////////////////////
  // sequential logic //
  //////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      blinky_o <= '0;
    end else if ((count == Half) | (count == Max)) begin
      blinky_o <= ~blinky_o;
    end
  end

endmodule
