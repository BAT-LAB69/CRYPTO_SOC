`timescale 1ns/1ps


/* --------- PADDING ----------
Input  : M (bit string bất kỳ)
Padding: 11111 || 0* || 1
Output : P sao cho len(P) % r = 0

VD: Giả sử:

r = 16 bit   (ví dụ nhỏ, không phải SHAKE thật)
M = 101011

Bước 1: Gắn domain
101011 || 11111 = 10101111111   (11 bit)

Bước 2: Chèn 0
10101111111 || 0000  (để đủ 15 bit)

Bước 3: Bit kết thúc
10101111111 0000 1 = 16 bit

*/

/* --------- ABSORB ----------
b = 16 bit

r = 10 bit

c = 6 bit

State = [ r | c ]

Ban đầu
S = 0000000000 | 000000

Absorb block P0
P0 = 1010110011
S = 1010110011 | 000000
→ permute
S = 1101000110 | 101101

Absorb block P1
S[0:9] ^= P1
→ permute

-> r là nơi đổ data vào, c là phần làm nhiễu khi trộn toàn bộ b bit data
-> r càng lớn thì 1 lần đổ đc càng nhiều data
-> c càng lớn thì an ninh càng cao
*/


module shake_top(
    input wire clk,
    input wire rst,

    input wire start,
    input wire [2:0] out_len_type, //0: 256-bit output, 1:512-bit output 
    input wire mode, // 0: SHAKE128, 1: SHAKE256
    input wire [1023:0] din,
    input wire [6:0] byte_len, // Added for dynamic padding

    output wire [511:0] dout,
    output wire done,
    output wire busy
);

    reg i_valid;
    reg i_last;
    wire i_ack;
    wire sponge_done;
    wire [511:0] sponge_dout;


    localparam IDLE = 2'd0;
    localparam START_ABS = 2'd1; //start absorb
    localparam WAIT_DONE = 2'd2;

    reg [1:0] state;

    
    sponge sponge_inst(
        .clk(clk),
        .rst(rst),
        .din(din),
        .byte_len(byte_len),
        .i_valid(i_valid),
        .i_last(i_last),
        .mode(mode),
        .i_ack(i_ack),
        .dout(sponge_dout),
        .done(sponge_done),
        .busy(busy)
    );

    //ed25519 require both 256bit & 512bit tuy giai doan
    assign dout = (out_len_type == 3'd0) ? {256'b0, sponge_dout[255:0]} : sponge_dout;
    assign done = sponge_done;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            i_valid <= 1'b0;
            i_last <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        i_valid <= 1'b1;
                        i_last <= 1'b1;
                        state <= START_ABS;
                    end
                end
                START_ABS: begin
                    if (i_ack) begin
                        i_valid <= 1'b0;
                        i_last <= 1'b0;
                        state <= WAIT_DONE;
                    end
                end
                WAIT_DONE: begin
                    if (sponge_done) begin
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
