//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2026 19:45:05
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input btn_in,
    output reg btn_out = 0
    );
    reg [18:0] count = 0;
    reg state = 0;
    always @(posedge clk) begin
     if(btn_in != state) begin
     state <= btn_in;
     count <= 0;
     end
     else if(count < 19'd500000) begin
     count <= count + 1;
     end
     else begin
     btn_out <= state;
      end
    end
    
endmodule
