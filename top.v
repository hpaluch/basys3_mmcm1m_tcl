//////////////////////////////////////////////////////////////////////////////////
// Engineer:       Henryk Paluch, https://github.com/hpaluch
// 
// Create Date:    11/15/2024 03:28:08 PM
// Design Name:    Basys 3 MMCM TCL
// Module Name:    top
// Project Name:   https://github.com/hpaluch/basys3_mmcm_tcl
// Target Devices: xc7a35tcpg236-1
// Tool Versions:  Vivado 2024.1
// Description: 
//      Example how to use MMCM clock module via "Clock Wizard" to create 1 MHz clock from 100 MHz input clock
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,
    input btnC,
    output [3:0]led,
    output [3:0]JA,
    output [3:0]an // common anodes of 4 digit display, Active low - used here to stop glowing
    );

  wire locked;
  wire CLK_OUT;
  wire safe_clk; // use safe_clk (before ODDR) to internal safe clocking with synchronous safe_reset
  wire safe_reset;
  wire ex_count_out;
  
  wire led_btnc, led_sr;
  wire pmod_btnc, pmod_sr;
    
  OBUF obuf_led_btnc( .I(btnC), .O(led_btnc) );
  OBUF obuf_pmod_btnc( .I(btnC), .O(pmod_btnc) );
  OBUF obuf_led_sr( .I(safe_reset), .O(led_sr) );
  OBUF obuf_pmod_sr( .I(safe_reset), .O(pmod_sr) );
    
  assign led = { ex_count_out, locked, led_sr, led_btnc };
  assign JA  = {      CLK_OUT, locked, pmod_sr, pmod_btnc };

  // tie 4-digit 7-segment display anodes to 1 (PNP transistor off) to stop glowing display
  genvar ii;
  for(ii=0 ; ii<4 ;ii = ii+1) begin: gen_anx_obuf
    OBUF anx_obuf ( .I(1'b1), .O(an[ii]) );
  end
    
  clk_wiz_0_exdes exdes_inst1 (// Clock in ports
    // Reset for logic in example design
    .CLK_OUT            (CLK_OUT), // must be always FPGA Output Pin, because it uses ODDR
    // Status and control signals
    .reset              (btnC),
    .locked             (locked),
    .clk_in1            (clk),
    // safe synchronous signals - see ex_count for usage below
    .safe_reset( safe_reset ), .safe_clk( safe_clk ) );

  // example counter using 1 Mhz MMCM clock (safe_clock) and synchronous reset (safe_reset):
  // NOTE: We can't use CLK_OUT because it is Output buffer (usable for Output Pin on FPGA only)
  ex_count ex_count_inst1 (
    .safe_reset( safe_reset ), .safe_clk( safe_clk ),
    .ex_count_out( ex_count_out) );
    
endmodule
