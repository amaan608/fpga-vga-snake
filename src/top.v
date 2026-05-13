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
    
    // Random Number Generator for Apple Spawning
    wire [11:0] random_val;
    lfsr rnd_gen (
        .clk(clk_25MHz_internal), 
        .rst(BTNC), 
        .rnd(random_val)
    );

    // 3. Movement Logic & Game State
    reg [9:0] apple_x = 400;
    reg [9:0] apple_y = 300;
    reg [9:0] head_x = 320;
    reg [9:0] head_y = 240;
    reg [21:0] move_counter = 0;
    
    // NEW: Direction Register (0=Up, 1=Down, 2=Left, 3=Right)
    // We start moving Right (3) by default
    reg [1:0] dir = 3; 
    
    // Arrays to hold up to 15 body segments + 1 head = max length 16
    reg [9:0] body_x [0:15];
    reg [9:0] body_y [0:15];
    reg [4:0] snake_length = 1; 
    reg game_over = 0;
    
    integer i;
    wire collision_apple = (head_x == apple_x) && (head_y == apple_y);

    always @(posedge clk_25MHz_internal) begin
        if (BTNC) begin 
            // Reset Game
            head_x <= 320;
            head_y <= 240;
            apple_x <= 400;
            apple_y <= 300;
            snake_length <= 1;
            game_over <= 0;
            move_counter <= 0;
            dir <= 3; // Reset direction to Right
        end else if (!game_over) begin
            
            // --- DIRECTION CONTROL ---
            // Update direction immediately when a button is pressed.
            // The extra checks (e.g., dir != 1) prevent the snake from doing a 180 
            // degree turn and instantly eating itself!
            if (up && dir != 1)    dir <= 0;
            if (down && dir != 0)  dir <= 1;
            if (left && dir != 3)  dir <= 2;
            if (right && dir != 2) dir <= 3;

            move_counter <= move_counter + 1;
            if (move_counter == 22'd2500000) begin 
                move_counter <= 0;
                
                // Shift the body segments
                for (i = 15; i > 0; i = i - 1) begin
                    body_x[i] <= body_x[i-1];
                    body_y[i] <= body_y[i-1];
                end
                // The first body segment follows the head's OLD position
                body_x[0] <= head_x;
                body_y[0] <= head_y;

                // Move the Head continuously based on 'dir'
                if (dir == 0) head_y <= head_y - 10; // Up
                if (dir == 1) head_y <= head_y + 10; // Down
                if (dir == 2) head_x <= head_x - 10; // Left
                if (dir == 3) head_x <= head_x + 10; // Right
                
                // --- COLLISION LOGIC ---
                // 1. Wall Collision (The Edge)
                // If you drive off the 640x480 screen, you die.
                if (head_x >= 640 || head_y >= 480) begin
                    game_over <= 1;
                end
                
                // 2. Self Collision
                for (i = 0; i < 15; i = i + 1) begin
                    if (i < snake_length - 1 && head_x == body_x[i] && head_y == body_y[i]) begin
                        game_over <= 1;
                    end
                end
            end
            
            // --- EATING LOGIC ---
            if (collision_apple && move_counter == 22'd2500000) begin
                apple_x <= random_val[5:0] * 10;
                apple_y <= (random_val[11:6] % 48) * 10; 
                
                if (snake_length < 16) begin
                    snake_length <= snake_length + 1;
                end
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
    wire is_head = (x_pos >= head_x && x_pos < head_x + 10) && 
                   (y_pos >= head_y && y_pos < head_y + 10);
                   
    wire is_apple = (x_pos >= apple_x && x_pos < apple_x + 10) && 
                    (y_pos >= apple_y && y_pos < apple_y + 10);

    reg is_body;
    integer j;
    always @(*) begin
        is_body = 0;
        for (j = 0; j < 15; j = j + 1) begin
            if (j < snake_length - 1) begin
                if ((x_pos >= body_x[j] && x_pos < body_x[j] + 10) && 
                    (y_pos >= body_y[j] && y_pos < body_y[j] + 10)) begin
                    is_body = 1;
                end
            end
        end
    end

    assign VGA_R = (video_active && (is_head || is_body)) ? 4'hF : 
                   (video_active && game_over) ? 4'h4 : 4'h0; 
                   
    assign VGA_G = (video_active && is_body) ? 4'hF : 
                   (video_active && is_apple && !game_over) ? 4'hF : 4'h0; 
                   
    assign VGA_B = (video_active && is_body) ? 4'hF : 
                   (video_active && !is_head && !is_apple && !game_over) ? 4'hF : 4'h0; 
endmodule