module Lab1_top ( 
    input  [2:0] X,
    input  [2:0] Y,
    input  [1:0] sel,
    output reg [7:0] out 
);

    always @(*) begin
        case (sel)
            2'b00: out = (X << 3) + Y;   // binary representation of 8X + Y
            2'b01: out = (Y << 4) + X;   // binary representation of 16Y + X
            2'b10: out = X << Y;         // Logic shift left X by Y bits
            2'b11: out = Y >> X;         // Logic shift right Y by X bits
            default: out = 8'b00000000;  // default 0
        endcase
    end

endmodule
