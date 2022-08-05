//=============================================================================
// Filename      : step_counter.sv
// Author        : Qian Gu
// Email         : guqian110@gmail.com
// Created on    : 2022-08-01 09:25:37 PM
// Last Modified : 2022-08-05 03:11:43 PM
//
//=============================================================================
/// Counter with enable and reset ports.
///
/// This module count number under the control port `en_i`.
///
/// 1. has an enable port and an asynchronous reset port
/// 2. instantiate a `common_cells:delta_counter` sub-module
///
/// ## Intended Usage
///
/// This module is intended to be an general counter used by various modules.
///
/// ## Specific Reminder
///
/// This module only work **when enable port is asserted**.
module step_counter #(
  /// Counter width
  parameter int unsigned CounterWidth = 8
 ) (
  /// Rising-edge clock
  input  logic                      clk_i,
  /// Asynchronous reset, active low
  input  logic                      rst_ni,
  /// Enable port
  input  logic                      en_i,
  /// Current count number
  output logic [CounterWidth-1 : 0] count_o
);

  ////////////////////////////
  // localparam and typedef //
  ////////////////////////////

  //////////////////////
  // sub-module inst  //
  //////////////////////

  delta_counter #(
    .WIDTH(CounterWidth)
  ) i_delta_counter (
    .clk_i,
    .rst_ni,
    .clear_i   (1'b0), // synchronous clear
    .en_i      (en_i),    // enable the counter
    .load_i    (1'b0),  // load a new value
    .down_i    (1'b0),  // downcount, default is up
    .delta_i   ({{(CounterWidth-1){1'b0}}, 1'b1}),
    .d_i       ({CounterWidth{1'b0}}),
    .q_o       (count_o),
    .overflow_o()
  );

endmodule

