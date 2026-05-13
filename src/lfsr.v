`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2026 21:54:27
// Design Name: 
// Module Name: lfsr
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


module lfsr(
   input clk,
   input rst,
   output reg [11:0] rnd
    );
    always @(posedge clk) begin
     if(rst)
     rnd <= 12'b101010101010;
     else 
     rnd <= {rnd[10:0], rnd[11] ^ rnd[5] ^ rnd[3] ^ rnd[0]};
    end
endmodule
