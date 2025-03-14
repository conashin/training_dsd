module ps2_keyboard (
    input        ps2_clk,
    input        ps2_data,
    input        reset,
    output reg [7:0] ascii_out,
    output reg       ascii_valid,
    output reg       error
);

    /* constants */
    localparam PARITY_REG_INITIAL_VALUE = 1'b1;
    localparam ERROR_REG_INITIAL_VALUE  = 1'b0;
    localparam ERROR_OCCURED            = 1'b1;

    /* main variables */
    reg [10:0] package_reg, package_next;
    reg        parity_reg, parity_next;
    reg        error_reg, error_next;

    reg [3:0] cnt_reg, cnt_next;

    /* additional variables */
    reg ps2_clk_previous_reg, ps2_clk_previous_next; // 直接追蹤 ps2_clk

    reg f0_flag_reg, f0_flag_next;
    reg e0_flag_reg, e0_flag_next;

    /* final state machine */
    localparam STATE_IDLE    = 1'b0;
    localparam STATE_RECEIVE = 1'b1;

    reg state_reg, state_next;

     // 實例化 IBUF (仍然需要)
    wire ps2clk_bufg; //BUFG輸出
    wire ps2clk_bufg_i;//IBUF輸出

    IBUF ps2clk_ibuf (
        .I(ps2_clk),
        .O(ps2clk_bufg_i)
    );

    BUFG ps2clk_bufg_inst (
        .I(ps2clk_bufg_i),
        .O(ps2clk_bufg)
     );

    // 中間 wire 變數
    wire [7:0] ascii_char_wire;

    /* sequential logic */  //在 ps2clk_bufg 的下降沿觸發
    always @(negedge ps2clk_bufg or posedge reset) begin
        if (reset) begin
            package_reg <= 11'b0;
            parity_reg  <= PARITY_REG_INITIAL_VALUE;
            error_reg   <= ERROR_REG_INITIAL_VALUE;

            cnt_reg     <= 4'b0;
            state_reg   <= STATE_IDLE;

            ps2_clk_previous_reg <= 1'b0; // 初始化
            f0_flag_reg              <= 1'b0;
            e0_flag_reg              <= 1'b0;
            ascii_out                <= 8'h00;
            ascii_valid              <= 1'b0;
            error                    <= 1'b0;

        end else begin
            package_reg <= package_next;
            parity_reg  <= parity_next;
            error_reg   <= error_next;

            cnt_reg     <= cnt_next;
            state_reg   <= state_next;

            ps2_clk_previous_reg <= ps2_clk_previous_next; // 更新 ps2_clk_previous_reg
            f0_flag_reg              <= f0_flag_next;
            e0_flag_reg              <= e0_flag_next;


            if(state_next == STATE_IDLE && cnt_next == 4'd10 && error_next != ERROR_OCCURED) begin
                if (package_next[8:1] != 8'hF0 && package_next[8:1] != 8'hE0) begin
                    ascii_out <= ascii_char_wire; //賦值
                    ascii_valid <= (ascii_char_wire != 8'h00);
                end
            end
        end
    end
    /* combinational logic */
    always @(*) begin
        /* latch prevention*/
        package_next = package_reg;
        parity_next  = parity_reg;
        error_next   = error_reg;
        cnt_next     = cnt_reg;
        state_next   = state_reg;
        f0_flag_next = f0_flag_reg;
        e0_flag_next = e0_flag_reg;
        error         = error_reg;  //直接輸出
        ps2_clk_previous_next = ps2clk_bufg; //直接使用ps2clk_bufg

        /* implementation logic */
        case (state_reg)
            STATE_IDLE : begin
                if (~ps2clk_bufg && ps2_clk_previous_reg) begin  //在 ps2clk_bufg 的下降沿
                    package_next = { ps2_data, package_reg[10:1] };
                    parity_next = PARITY_REG_INITIAL_VALUE;
                    error_next  = ERROR_REG_INITIAL_VALUE;
                    cnt_next    = 4'd0;
                    state_next  = STATE_RECEIVE;
                end
            end

            STATE_RECEIVE : begin
                if (~ps2clk_bufg && ps2_clk_previous_reg) begin //在 ps2clk_bufg 的下降沿
                    package_next = { ps2_data, package_reg[10:1] };

                    if (cnt_reg <= 4'd7) parity_next = parity_reg ^ ps2_data;
                    else if (cnt_reg == 4'd8) begin
                        if (parity_reg != ps2_data) error_next = ERROR_OCCURED;
                    end else begin
                        if (package_next[0] != 1'b0 || package_next[10] != 1'b1)
                            error_next = ERROR_OCCURED;
                    end
                    cnt_next = cnt_reg + 4'b1;
                end

                if (cnt_next == 4'd10 && error_next != ERROR_OCCURED) begin
                    case (package_next[8:1])
                        8'hF0 : f0_flag_next = 1'b1;
                        8'hE0 : e0_flag_next = 1'b1;
                        default : begin
                           // ascii_converter 例化移到下方
                            f0_flag_next = 1'b0; // 清除標誌
                            e0_flag_next = 1'b0; // 清除標誌
                        end
                    endcase
                end

                if (cnt_next == 4'd10) state_next = STATE_IDLE;
            end
        endcase
    end

    // 正確例化 ascii_converter
    ascii_converter ascii_conv (
        .scan_code(package_next[8:1]),
        .shift_pressed(f0_flag_reg), // 簡化，假設 Shift = F0
        .caps_lock(1'b0),   // 簡化，不考慮 Caps Lock
        .ascii_char(ascii_char_wire) // 連接到中間 wire
    );

endmodule
