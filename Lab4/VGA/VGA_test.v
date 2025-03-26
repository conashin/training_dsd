module VGA_test(

);
    parameter False = 0, True = 1;
    parameter LOGO_LENGTH = 169, LOGO_HEIGHT = 78;

    wire pclk;
    wire valid;
    wire [9:0] hCnt, vCnt;

    reg [11:0] vgaDat;
    wire [11:0] romDout;
    reg [13:0] romAddr;
    
    wire logoArea;
    reg [9:0] logoX, logoY, nextLogoX, nextLogoY;
    reg [7:0] speedCnt;
    wire speedCtrl;

    reg [3:0] flagEdge;
    reg [1:0] flagAddSub;


    assign logoArea = ((vCnt >= logoY) & (vCnt <= logoY + LOGO_HEIGHT -1) & (hCnt >= logoX) & (hCnt <= logoX + LOGO_LENGTH -1)) ? True : False;
    assign {vgaR, vgaG, vgaB} = logoArea ? romDout : 12'b0;


    dcm_25M u0(
        .clk_in1(clk),
        .clk_out1(pclk),
        .reset(rst)
    );

    logo_rom u1(
        .clk(pclk),
        .addr(romAddr),
        .dout(romDout)
    );

    syncGeneration u2(
        .pclk(pclk),
        .rst(rst),
        .hSync(hSync),
        .vSync(vSync),
        .dataValid(valid),
        .hDatCnt(hCnt),
        .vDatCnt(vCnt)
    );

    debouncer u3(
        .clk(pclk),
        .rst(rst),
        .in(speedCnt[5]),
        .out(speedCtrl)
    );


    always @(posedge pclk or posedge rst) 
    begin: LOGO_DISPLAY
        if (rst) begin
            romAddr <= 0;
            vgaDat <= 0;
        end
        else begin 
            if (valid == 1) begin
                if (logoArea == 1) begin
                    romAddr <= romAddr + 1;
                    vgaDat <= romDout;
                end
                else begin
                    romAddr <= romAddr;
                    vgaDat <= 0;
                end
            end
            else begin
                vgaDat <= 0;
                if (vCnt == 0) begin
                    romAddr <= 0;
                end
                else begin
                    romAddr <= romAddr;
                end
            end
        end
    end

    always @(posedge pclk or posedge rst) 
    begin: SPEED_CONTROL
        if (rst) begin
            speedCnt <= 0;
        end
        else begin
            if ((vCnt[5] == 1) & (hCnt == 1)) begin
                speedCnt <= speedCnt + 1;
            end
            else begin
                speedCnt <= speedCnt;
            end
        end
    end

    always @(posedge pclk or posedge rst)
    begin: LOGO_MOVE
        if (rst == 1) begin
            flagAddSub <= 1;
            flagEdge <= 4'ha;
        end
        else begin
            if (speedCtrl == 1) begin
                if (nextLogoX == 1) begin
                    if (nextLogoY == 1) begin
                        flagEdge <= 4'h1;
                        flagAddSub <= 0;
                    end
                    else if (nextLogoY == 480 - LOGO_HEIGHT) begin
                        flagEdge <= 4'h2;
                        flagAddSub <= 1;
                    end
                    else begin
                        flagEdge <= 4'h3;
                        flagAddSub[1] <= (~flagAddSub[1]);
                    end
                end
                else if (nextLogoX == 640 - LOGO_LENGTH) begin
                    if (nextLogoY == 1) begin
                        flagEdge <= 4'h4;
                        flagAddSub <= 2'b10;
                    end
                    else if (nextLogoY == 480 - LOGO_HEIGHT) begin
                        flagEdge <= 4'h5;
                        flagAddSub <= 2'b11;
                    end
                    else begin
                        flagEdge <= 4'h6;
                        flagAddSub[1] <= (~flagAddSub[1]);
                    end
                end
                else if (nextLogoY == 1) begin
                    flagEdge <= 4'h7;
                    flagAddSub[0] <= (~flagAddSub[0]);
                end
                else if (nextLogoY == 480 - LOGO_HEIGHT) begin
                    flagEdge <= 4'h8;
                    flagAddSub[0] <= (~flagAddSub[0]);
                end
                else begin
                    flagEdge <= 4'h9;
                    flagAddSub <= flagAddSub;
                end
            end

        end
    end

    always @(*) begin
        if (speedCtrl == 1) begin
            case (flagAddSub)
                2'b00: begin 
                    nextLogoX = logoX + 1;
                    nextLogoY = logoY + 1;
                end
                2'b01: begin
                    nextLogoX = logoX + 1;
                    nextLogoY = logoY - 1;
                end
                2'b10: begin
                    nextLogoX = logoX - 1;
                    nextLogoY = logoY + 1;
                end
                2'b11: begin
                    nextLogoX = logoX - 1;
                    nextLogoY = logoY - 1;
                end
                default: begin
                    nextLogoX = logoX + 1;
                    nextLogoY = logoY + 1;
                end
            endcase     
        end
        else begin
            nextLogoX = logoX;
            nextLogoY = logoY;
        end
    end

    always @(posedge pclk or posedge rst) begin
        if (rst) begin
            logoX <= 10'd430;
            logoY <= 10'd50;
        end
        else begin
            logoX <= nextLogoX;
            logoY <= nextLogoY;
        end
    end   
endmodule