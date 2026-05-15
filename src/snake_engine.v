
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2026 17:57:51
// Design Name: 
// Module Name: snake_engine
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


module snake_engine(
    input clk,
    input reset,
    input up, down, left, right,
    input [11:0] random_val,
    input [9:0] x_pos,  
    input [9:0] y_pos,  
    output [4:0] score,
    output reg [1:0] game_state,
    output is_head,
    output reg is_body,
    output is_apple,
    output apple_visible
);
    localparam STATE_INIT = 2'd0;
    localparam STATE_PLAY = 2'd1;
    localparam STATE_OVER = 2'd2;

    reg [9:0] apple_x = 400;
    reg [9:0] apple_y = 300;
    reg [9:0] head_x = 320;
    reg [9:0] head_y = 240;
    
    reg [21:0] move_counter = 0;
    reg [21:0] speed_limit = 22'd2500000; 
    
    reg [1:0] dir = 3; 
    reg [9:0] body_x [0:15];
    reg [9:0] body_y [0:15];
    reg [4:0] snake_length = 1; 
    
    assign score = snake_length - 1;
    
    integer i;
    wire collision_apple = (head_x == apple_x) && (head_y == apple_y);

    reg [23:0] blink_counter = 0;
    always @(posedge clk) blink_counter <= blink_counter + 1;
    assign apple_visible = blink_counter[23]; 

    initial game_state = STATE_INIT;

    always @(posedge clk) begin
        case (game_state)
            STATE_INIT: begin
                head_x <= 320; head_y <= 240;
                apple_x <= 400; apple_y <= 300;
                snake_length <= 1; move_counter <= 0;
                speed_limit <= 22'd2500000; dir <= 3; 

                if (up || down || left || right) begin
                    game_state <= STATE_PLAY;
                    if (up) dir <= 0;
                    if (down) dir <= 1;
                    if (left) dir <= 2;
                    if (right) dir <= 3;
                end
            end

            STATE_PLAY: begin
                if (reset) game_state <= STATE_INIT;

                if (up && dir != 1)    dir <= 0;
                if (down && dir != 0)  dir <= 1;
                if (left && dir != 3)  dir <= 2;
                if (right && dir != 2) dir <= 3;

                move_counter <= move_counter + 1;
                if (move_counter >= speed_limit) begin 
                    move_counter <= 0;
                    
                    for (i = 15; i > 0; i = i - 1) begin
                        body_x[i] <= body_x[i-1]; body_y[i] <= body_y[i-1];
                    end
                    body_x[0] <= head_x; body_y[0] <= head_y;

                    if (dir == 0) head_y <= head_y - 10; 
                    if (dir == 1) head_y <= head_y + 10; 
                    if (dir == 2) head_x <= head_x - 10; 
                    if (dir == 3) head_x <= head_x + 10; 
                    
                    // REVERTED: Standard 640x480 boundary.
                    // Because head_x and head_y are unsigned, if they go below 0 (e.g., moving left from 0), 
                    // they wrap around to a huge number like 1014. This single line catches all 4 walls!
                    if (head_x >= 640 || head_y >= 480) begin
                        game_state <= STATE_OVER;
                    end
                    
                    for (i = 0; i < 15; i = i + 1) begin
                        if (i < snake_length - 1 && head_x == body_x[i] && head_y == body_y[i]) begin
                            game_state <= STATE_OVER;
                        end
                    end
                end
                
                if (collision_apple && move_counter == speed_limit - 1) begin
                    // REVERTED: Apples spawn anywhere on the full 640x480 grid
                    apple_x <= random_val[5:0] * 10;
                    apple_y <= (random_val[11:6] % 48) * 10; 
                    
                    if (snake_length < 16) begin
                        snake_length <= snake_length + 1;
                        if (speed_limit > 22'd1000000) speed_limit <= speed_limit - 22'd100000;
                    end
                end
            end

            STATE_OVER: begin
                if (reset) game_state <= STATE_INIT;
            end
        endcase
    end

    // --- DRAWING COORDINATE OUTPUT ---
    assign is_head = (x_pos >= head_x && x_pos < head_x + 10) && (y_pos >= head_y && y_pos < head_y + 10);
    assign is_apple = (x_pos >= apple_x && x_pos < apple_x + 10) && (y_pos >= apple_y && y_pos < apple_y + 10);

    integer j;
    always @(*) begin
        is_body = 0;
        for (j = 0; j < 15; j = j + 1) begin
            if (j < snake_length - 1) begin
                if ((x_pos >= body_x[j] && x_pos < body_x[j] + 10) && (y_pos >= body_y[j] && y_pos < body_y[j] + 10)) begin
                    is_body = 1;
                end
            end
        end
    end
endmodule