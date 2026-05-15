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
    output VGA_HS, VGA_VS,
    output CA, CB, CC, CD, CE, CF, CG,
    output [7:0] AN
);
    wire clk_25MHz_internal; 
    clk_wiz_0 clk_gen (.clk_out1(clk_25MHz_internal), .clk_in1(CLK100MHZ), .reset(1'b0));

    // Input Processing
    wire up, down, left, right;
    debouncer d_u (clk_25MHz_internal, BTNU, up);
    debouncer d_d (clk_25MHz_internal, BTND, down);
    debouncer d_l (clk_25MHz_internal, BTNL, left);
    debouncer d_r (clk_25MHz_internal, BTNR, right);
    
    wire [11:0] random_val;
    lfsr rnd_gen (.clk(clk_25MHz_internal), .rst(BTNC), .rnd(random_val));

    // VGA Generation
    wire [9:0] x_pos, y_pos;
    wire video_active;
    vga_controller vga (
        .clk_25MHz(clk_25MHz_internal), 
        .reset(1'b0), 
        .hsync(VGA_HS), 
        .vsync(VGA_VS), 
        .x_pos(x_pos), 
        .y_pos(y_pos), 
        .video_active(video_active)
    );

    // The Game Brain
    wire [4:0] score;
    wire [1:0] game_state;
    wire is_head, is_body, is_apple, apple_visible;

    snake_engine engine (
        .clk(clk_25MHz_internal),
        .reset(BTNC),
        .up(up), .down(down), .left(left), .right(right),
        .random_val(random_val),
        .x_pos(x_pos), .y_pos(y_pos),
        .score(score),
        .game_state(game_state),
        .is_head(is_head),
        .is_body(is_body),
        .is_apple(is_apple),
        .apple_visible(apple_visible)
    );

    // The Scoreboard
    scoreboard display (
        .clk(clk_25MHz_internal),
        .score({3'b000, score}), 
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
        .AN(AN)
    );

    // Render Logic
    localparam STATE_INIT = 2'd0;
    localparam STATE_PLAY = 2'd1;
    localparam STATE_OVER = 2'd2;

    wire render_apple = is_apple && apple_visible;

    assign VGA_R = (video_active && (is_head || is_body)) ? 4'hF : 
                   (video_active && game_state == STATE_OVER) ? 4'h4 : 
                   (video_active && game_state == STATE_INIT && !is_head && !render_apple) ? 4'h2 : 4'h0; 
                   
    assign VGA_G = (video_active && is_body) ? 4'hF : 
                   (video_active && render_apple) ? 4'hF : 
                   (video_active && game_state == STATE_INIT && !is_head && !render_apple) ? 4'h2 : 4'h0; 
                   
    assign VGA_B = (video_active && is_body) ? 4'hF : 
                   (video_active && game_state == STATE_PLAY && !is_head && !render_apple) ? 4'hF : 
                   (video_active && game_state == STATE_INIT && !is_head && !render_apple) ? 4'h2 : 4'h0; 
endmodule