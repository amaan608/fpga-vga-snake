module vga_controller (
    input wire clk_25MHz,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire video_active,
    output wire [9:0] x_pos,
    output wire [9:0] y_pos
);

    // VGA 640x480 @ 60Hz Timing Parameters
    parameter H_DISPLAY = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;
    parameter H_TOTAL   = 800;

    parameter V_DISPLAY = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;
    parameter V_TOTAL   = 525;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Horizontal and Vertical Counters
    always @(posedge clk_25MHz or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // VGA standard dictates active-low sync pulses for 640x480
    assign hsync = ~( (h_count >= (H_DISPLAY + H_FRONT)) && (h_count < (H_DISPLAY + H_FRONT + H_SYNC)) );
    assign vsync = ~( (v_count >= (V_DISPLAY + V_FRONT)) && (v_count < (V_DISPLAY + V_FRONT + V_SYNC)) );
    
    // active video area where it's safe to output color
    assign video_active = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
    // Pixel coordinates to use later for the game
    assign x_pos = h_count;
    assign y_pos = v_count;

endmodule