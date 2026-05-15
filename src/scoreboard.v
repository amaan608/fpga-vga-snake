`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2026 17:26:53
// Design Name: 
// Module Name: scoreboard
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


module scoreboard(
    input clk,             // 25MHz clock
    input [7:0] score,     // Snake length
    output reg CA, CB, CC, CD, CE, CF, CG, // 7 segments
    output reg [7:0] AN    // 8 Anodes (digit selectors)
);
    // 1. Clock divider for multiplexing (~760 Hz refresh rate)
    reg [14:0] refresh_counter = 0;
    always @(posedge clk) refresh_counter <= refresh_counter + 1;
    wire [2:0] active_digit = refresh_counter[14:12];

    // 2. Math to separate the score into Tens and Ones (Binary to Decimal)
    wire [3:0] tens = score / 10;
    wire [3:0] ones = score % 10;

    // 3. Select which number to draw based on the active digit
    reg [3:0] current_number;
    always @(*) begin
        case(active_digit)
            3'd0: current_number = ones;
            3'd1: current_number = tens;
            default: current_number = 4'hF; // F means "Blank"
        endcase
    end

    // 4. Hex to 7-Segment Decoder (Active Low for Nexys A7)
    // Map: {CG, CF, CE, CD, CC, CB, CA}
    reg [6:0] seg_data;
    always @(*) begin
        case(current_number)
            4'h0: seg_data = 7'b1000000;
            4'h1: seg_data = 7'b1111001;
            4'h2: seg_data = 7'b0100100;
            4'h3: seg_data = 7'b0110000;
            4'h4: seg_data = 7'b0011001;
            4'h5: seg_data = 7'b0010010;
            4'h6: seg_data = 7'b0000010;
            4'h7: seg_data = 7'b1111000;
            4'h8: seg_data = 7'b0000000;
            4'h9: seg_data = 7'b0010000;
            default: seg_data = 7'b1111111; // All off
        endcase
    end

    // Wire up the individual outputs
    always @(*) begin
        {CG, CF, CE, CD, CC, CB, CA} = seg_data;
    end

    // 5. Digit Selector (Active Low)
    always @(*) begin
        AN = 8'hFF; // Turn all digits OFF
        if (active_digit == 0) AN[0] = 1'b0; // Turn on Right-most digit
        if (active_digit == 1 && tens > 0) AN[1] = 1'b0; // Turn on Tens digit (but hide it if score < 10)
    end
endmodule