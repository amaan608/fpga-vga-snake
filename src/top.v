module top (
    input wire CLK100MHZ,
    input wire BTNC,       // Center button used as reset
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
);

    wire clk_25MHz;
    wire locked;
    wire video_active;
    wire [9:0] x_pos;
    wire [9:0] y_pos;

    // 1. Instantiate the Clocking Wizard
    clk_wiz_0 clock_gen (
        .clk_in1(CLK100MHZ),
        .reset(BTNC),
        .clk_out1(clk_25MHz),
        .locked(locked) 
    );

    // 2. Instantiate the VGA Controller
    vga_controller vga_sync (
        .clk_25MHz(clk_25MHz),
        .reset(BTNC), 
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .video_active(video_active),
        .x_pos(x_pos),
        .y_pos(y_pos)
    );

     3. Pixel Color Logic (Drawing a Square)
    
    
    // (640/2 = 320, 480/2 = 240)
    wire is_square = (x_pos >= 300 && x_pos < 340) && (y_pos >= 220 && y_pos < 260);

    // Draw the square RED
    assign VGA_R = (video_active && is_square) ? 4'hF : 4'h0;
    
    // Keep green off
    assign VGA_G = 4'h0;
    
    // Draw the background BLUE
    assign VGA_B = (video_active && !is_square) ? 4'hF : 4'h0;

endmodule