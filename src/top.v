//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2026 19:48:46
// Design Name: 
// Module Name: top
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


module top(
    input CLK100MHZ,
    input BTNC, BTNU, BTND, BTNL, BTNR,
    output [3:0] VGA_R, VGA_G, VGA_B,
    output VGA_HS, VGA_VS
);
    // 1. Clock Generation
    wire clk_25MHz_internal;
    clk_wiz_0 clk_gen (.clk_out1(clk_25MHz_internal), .clk_in1(CLK100MHZ), .reset(1'b0));

    // 2. Button Debouncing
    wire up, down, left, right;
    debouncer d_u (clk_25MHz_internal, BTNU, up);
    debouncer d_d (clk_25MHz_internal, BTND, down);
    debouncer d_l (clk_25MHz_internal, BTNL, left);
    debouncer d_r (clk_25MHz_internal, BTNR, right);

    // 3. Movement Logic 
    reg [9:0] head_x = 320;
    reg [9:0] head_y = 240;
    reg [21:0] move_counter = 0;
    
    always @(posedge clk_25MHz_internal) begin
        if (BTNC) begin // Reset to center
            head_x <= 320;
            head_y <= 240;
        end else begin
            move_counter <= move_counter + 1;
            if (move_counter == 22'd2500000) begin // ~10 movements per second
                move_counter <= 0;
                if (up)    head_y <= head_y - 10;
                if (down)  head_y <= head_y + 10;
                if (left)  head_x <= head_x - 10;
                if (right) head_x <= head_x + 10;
            end
        end
    end

    // 4. VGA Controller
    wire [9:0] x_pos, y_pos;
    wire video_active;
    

    vga_controller vga (
        .clk_25MHz(clk_25MHz_internal), 
        .reset(BTNC), 
        .hsync(VGA_HS), 
        .vsync(VGA_VS), 
        .x_pos(x_pos), 
        .y_pos(y_pos), 
        .video_active(video_active)
    );

    // 5. Drawing Logic
    // Snake head is a 10x10 square
    wire is_head = (x_pos >= head_x && x_pos < head_x + 10) && 
                   (y_pos >= head_y && y_pos < head_y + 10);

    assign VGA_R = (video_active && is_head) ? 4'hF : 4'h0; // Red Head
    assign VGA_G = 4'h0;
    assign VGA_B = (video_active && !is_head) ? 4'hF : 4'h0; // Blue Background
endmodule
