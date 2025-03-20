`timescale 1ns / 1ps

// Keyboard Module
module keyboard_controller(
    input PS2_CLK,
    input PS2_DATA,
    input reset,
    output reg start,
    output reg two,
    output reg three
);
    reg [3:0] countkey;
    reg flag;
    reg [7:0] receive_key;
    reg pre_data;

    always@(negedge PS2_CLK or negedge reset) begin
        if (!reset) begin
            countkey    <= 0;
            flag        <= 0;
            receive_key <= 0;
            two         <= 0;
            three       <= 0;
            start       <= 0;
            pre_data    <= 1;
        end
        else begin
            pre_data <= PS2_DATA;
            
            if (pre_data == 1 && PS2_DATA == 0 && countkey != 8) begin
                flag <= 1;
            end
            
            if (flag && countkey<8) begin
                receive_key[countkey] <= PS2_DATA;
                countkey              <= countkey+1;
            end
            else if (flag && countkey == 8) begin
                countkey <= 0;
                flag     <= 0;
            end
            else begin
                countkey <= 0;
                pre_data <= 1;
            end
            
            case(receive_key)
                8'b0001_1011: start <= 1; // s
                8'b0111_0010: two   <= 1; // 2
                8'b0111_1010: three <= 1; // 3
                default: begin
                    start <= 0;
                    two   <= 0;
                    three <= 0;
                end
            endcase
        end
    end
endmodule

// Debounce Module
module debouncer(
    input clk1000,
    input btn_in,
    input reset,
    output reg btn_out
);
    reg [7:0] count;
    
    always@(posedge clk1000) begin
        if (btn_in)
            count <= count + 1;
        else
            count <= 0;
            
        if (count == 50)
            btn_out <= 1;
        else
            btn_out <= 0;
    end
endmodule

// Clock Divider Module
module frequency_divider(
    input CLK,
    input reset,
    output clk1,
    output clk100,
    output clk1000
);
    reg [25:0] counter26;
    reg [19:0] counter20;
    reg [16:0] counter17;
    
    always@(posedge CLK) begin
        if (!reset) begin
            counter26 <= 26'b0;
            counter20 <= 20'b0;
            counter17 <= 17'b0;
        end
        else begin
            counter26 <= counter26 + 1'b1;
            counter20 <= counter20 + 1'b1;
            counter17 <= counter17 + 1'b1;
        end
    end
    
    assign clk1    = counter26[25];
    assign clk100  = counter20[19];
    assign clk1000 = counter17[16];
endmodule

// State Machine Module
module state_machine(
    input clk1000,
    input reset,
    input start,
    input deb_stop,
    output reg [2:0] state
);
    parameter stops = 3'd0, starts = 3'd1, check = 3'd2, inc_dec = 3'd3;
    reg [2:0] nst;
    
    always@(*) begin
        nst = stops;
        case(state)
            stops: begin
                if (start == 1)
                    nst = starts;
                else
                    nst = stops;
            end
            starts: begin
                if (deb_stop == 1)
                    nst = check;
                else
                    nst = starts;
            end
            check: nst = inc_dec;
            inc_dec: begin
                nst = inc_dec;
            end
        endcase
    end
    
    always@(posedge clk1000 or negedge reset) begin
        if (!reset)
            state <= stops;
        else
            state <= nst;
    end
endmodule

// Top Module
module lab3(
    output reg [7:0] seg,
    output reg [7:0] segg1,
    output reg [15:0] led,
    input stop, inc, dec, reset, CLK,
    input PS2_DATA,
    input PS2_CLK,
    output reg en, enl, enr
);
    wire clk1, clk100, clk1000;
    wire start, two, three;
    wire deb_stop, deb_inc, deb_dec;
    wire [2:0] state;
    
    // Register declarations
    reg right;
    reg [3:0] segn, segln, segrn, segg1n;
    reg [4:0] countled;
    reg LEDflag;
    reg countseg;
    
    // Module instantiations
    frequency_divider freq_div(
        .CLK(CLK),
        .reset(reset),
        .clk1(clk1),
        .clk100(clk100),
        .clk1000(clk1000)
    );
    
    keyboard_controller keyboard(
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .reset(reset),
        .start(start),
        .two(two),
        .three(three)
    );
    
    debouncer debounce_stop(
        .clk1000(clk1000),
        .btn_in(stop),
        .reset(reset),
        .btn_out(deb_stop)
    );
    
    debouncer debounce_inc(
        .clk1000(clk1000),
        .btn_in(inc),
        .reset(reset),
        .btn_out(deb_inc)
    );
    
    debouncer debounce_dec(
        .clk1000(clk1000),
        .btn_in(dec),
        .reset(reset),
        .btn_out(deb_dec)
    );
    
    state_machine fsm(
        .clk1000(clk1000),
        .reset(reset),
        .start(start),
        .deb_stop(deb_stop),
        .state(state)
    );
    
    // Original logic for displays and LEDs (would be better to modularize these too)
    // Group0 seg logic
    always@(posedge CLK or negedge reset) begin
        // Rest of your seg logic
    end
    
    // Group1 seg logic
    always@(posedge clk1 or negedge reset) begin
        // Rest of your segg1 logic
    end
    
    // Right check logic
    always@(posedge clk1000, negedge reset) begin
        // Right check logic implementation
    end
    
    // Display logic
    always@(posedge clk100) begin
        // Display multiplexing logic
    end
    
    // Segment decoder
    always@(*) begin
        // Segment decoder logic
    end
    
    // LED control logic
    always@(posedge clk1000 or negedge reset) begin
        // LED control implementation
    end
endmodule
