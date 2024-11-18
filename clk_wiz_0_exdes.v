
// file: clk_wiz_0_exdes.v
// (c) Copyright 2017-2018, 2023 Advanced Micro Devices, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.

//----------------------------------------------------------------------------
// Clocking wizard example design
//----------------------------------------------------------------------------
// This example design instantiates the created clocking network, where each
//   output clock drives a counter. The high bit of each counter is ported.
//----------------------------------------------------------------------------

`timescale 1ps/1ps

module clk_wiz_0_exdes 
 (
  // Reset that only drives logic in example design
  output [1:1]   CLK_OUT,
  // Status and control signals
  input         reset,
  output        locked,
  output        safe_clk, // use this clock in your design
  output        safe_reset, // use this RESET synchronously in your design
 // Clock in ports
  input         clk_in1
 );

  // Parameters for the counters
  //-------------------------------
 localparam  ONE_NS      = 1000;
 localparam time PER1    = 10*ONE_NS;
 localparam time PER1_1  = PER1/2;  
 // Counter width
  localparam    C_W       = 20;
  // Clock to Q delay of 100ps
  localparam TCQ  = 100;
  // When the clock goes out of lock, reset the counters
  wire          reset_int = (!locked)  || reset;

  (* ASYNC_REG = "TRUE" *)  reg rst_sync;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int1;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int2;

  // Declare the clocks and counter
  wire           clk_int;
  wire           clk;
  wire      clk_in1_buf;
  wire      clk_in2_buf;
  wire      clkfb_in_buf;
  wire clk_out1_unused, clk_out2_unused, clk_out3_unused, clk_out4_unused, clk_out6_unused, clk_out7_unused;

  assign safe_reset = rst_sync_int2;
  assign safe_clk = clk;

  // Instantiation of the clocking network
  //--------------------------------------
  clk_wiz_0 clknetwork
   (
   .clk_out1(clk_out1_unused), .clk_out2(clk_out2_unused), .clk_out3(clk_out3_unused), .clk_out4(clk_out4_unused),
    // Clock out ports // clk_out5 = CLKOUT4 = cascade out = 1 MHz output
    .clk_out5           (clk_int),
    .clk_out6 (clk_out6_unused), .clk_out7(clk_out7_unused),
    // Status and control signals
    .reset              (reset),
    .locked             (locked),
   // Clock in ports
    .clk_in1            (clk_in1)
);
  ODDR clk_out_oddr
   (.Q  (CLK_OUT[1]),
    .C  (clk_int),
    .CE (1'b1),
    .D1 (1'b1),
    .D2 (1'b0),
    .R  (1'b0),
    .S  (1'b0));


  // Connect the output clocks to the design
  //-----------------------------------------
  assign clk = clk_int;


  // Reset synchronizer
  //-----------------------------------
    always @(posedge reset_int or posedge clk) begin
       if (reset_int) begin
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;     
            rst_sync_int1 <= rst_sync_int; 
            rst_sync_int2 <= rst_sync_int1;
       end
    end

endmodule
