`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 03:48:00 AM
// Design Name: 
// Module Name: shake128_top
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
//|---------------- Rate (1344 bits) -----------------|--- Capacity (256 bits) ---|
//| Word 0 | Word 1 | ... | Word 19 | Word 20         | Word 21 | ... | Word 24 |
//| 0...63 | 64..127| ... |         | 1280...1343     | 1344... | ... | ...1599 |
//^                                   ^           ^
//Start                               Start       End of Rate
//                                    of Word 20

//|------------------- RATE (An toàn để xuất) -------------------|--- CAPACITY (CẤM) ---|
//[Word 0] [Word 1] ... [Word 9] [Word 10 (Nửa nạc nửa mỡ)] ...
//|128bit| |128bit| ... |128bit| |64 bit Rate | 64 bit Capacity| ...
//                               ^              ^
//                               Valid          DANGER ZONE!


module shake128_top(
    input  wire             i_clk,
    input  wire             i_rst_n,
    
    input  wire [63:0]      i_data,
    input  wire             i_valid, // report have data
    input  wire             i_last, // report this is the last data package
    output reg              o_ready, //module ready to receive data
    
    output reg  [127:0]     o_data,
    output reg              o_valid, // o_data valid
    input  wire             i_ack, // bao da nhan data de lay data moi
    
    output wire             o_squeeze_mode // bao chuyen qua che do Squeeze (vat kiet)
    );
    
    //Internal Signals
    
    // SHAKE128: Rate = 1344 bits = 21 words (64-bit)
    localparam RATE_WORDS = 21;
    
    // output 128bit: 1344 / 128 = 10.5
    //=> 10 word full 128 bit, the last qord just have 64 bit valid
    localparam SQUEEZE_FULL_WORDS = 10; 
    localparam SQUEEZE_LAST_IDX   = 10; // Word thứ 11 (Index 10) 
    
    reg [1599:0] state; // registter state Bot bien
    reg [4:0]    word_index; // con tro vi tri dang ghi
    
    // connect with keccak_f1600
    reg             f1600_start;
    wire            f1600_done;
    wire            f1600_busy;
    wire [1599:0]   f1600_out;
    
    // FSM States
    localparam S_IDLE       = 3'd0;
    localparam S_ABSORB     = 3'd1; // Đang hút dữ liệu
    localparam S_PAD        = 3'd2; // Chèn padding
    localparam S_PERM_WAIT  = 3'd3; // Chờ f1600 tính toán
    localparam S_SQUEEZE    = 3'd4; // Xuất dữ liệu
    
    reg [2:0] current_state_fsm, next_state_fsm;
    reg       is_padding_phase; // Cờ đánh dấu đang hoan doi cho pha padding hay pha đầy buffer
    
    //Instance
    keccak_f1600 u_core (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_start    (f1600_start),
        .i_state    (state),       // Nạp state hiện tại vào
        .o_state    (f1600_out),   // Nhận state mới ra
        .o_done     (f1600_done),
        .o_busy     (f1600_busy)
    );
    
    assign o_squeeze_mode = (current_state_fsm == S_SQUEEZE);
    
    
    //FSM
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            current_state_fsm <=  S_IDLE;
            state             <= 0;
            word_index        <= 0;
            f1600_start       <= 0;
            is_padding_phase  <= 0;
            o_ready           <= 0;
            o_valid           <= 0;
            o_data            <= 0;
        end
        else begin
            f1600_start <= 0;
            case (current_state_fsm)
                S_IDLE: begin
                    o_ready <= 1;
                    state <= 0;
                    word_index <= 0;
                    if (i_valid) begin
                        state[63:0] <= i_data;
                        if (i_last) begin
                            // Nếu gói đầu tiên cũng là gói cuối cùng -> Chuyển thẳng sang Padding
                            word_index <= 1; // Padding sẽ chèn vào word tiếp theo
                            current_state_fsm <= S_PAD;
                            o_ready <= 0;
                        end else begin
                            // Nếu chưa hết -> Sang Absorb chờ tiếp
                            word_index <= 1;
                            current_state_fsm <= S_ABSORB;
                        end 
                    end
                end
                //------------------------------------
                S_ABSORB: begin
                    o_ready <= 1;
                    if (i_valid) begin
                        //logic xor data into state
                        //calc the locate of start bit: word_index * 64
                        state[word_index * 64 +: 64] <= state[word_index*64 +: 64] ^ i_data;
                        
                        //kiem tra last input
                        if (i_last) begin
                            // if this is the last package, go to Padding
                            word_index <= word_index + 1;
                            current_state_fsm <= S_PAD;
                            o_ready <= 0; //ngung nhan data
                        end
                        else begin
                            // neu chua phair last, check buffet day chua
                            if (word_index == RATE_WORDS - 1) begin
                                // da day 1344 bits -> chay f1600
                                o_ready <= 0;
                                f1600_start <= 1;
                                is_padding_phase <= 0;
                                current_state_fsm <= S_PERM_WAIT;
                            end
                            else begin
                                word_index <= word_index + 1;
                            end
                        end
                    end else if (i_last) begin
                        current_state_fsm <= S_PAD;
                        o_ready <= 0;
                    end
                end
                //------------------------------------
                S_PAD: begin
                    // XOR 0x1F into current word
                    state[word_index*64 +: 64] <= state[word_index*64 +: 64] ^ 64'h1F;
                    
                    // XOR 0x80...00 into the last word of RATE (word 20) 
                    // if word_index == 20, dòng 1 và dòng 2 tác động vào cùng 1 word. 
                    state[RATE_WORDS*64 - 1] <= state[RATE_WORDS*64 - 1] ^ 1'b1; // Bit 1343
                    
                    // Kích hoạt Permutation lần cuối
                    f1600_start <= 1;
                    is_padding_phase <= 1; // Đánh dấu là sau khi xong cái này thì sang Squeeze
                    current_state_fsm <= S_PERM_WAIT;
                end
                //------------------------------------
                S_PERM_WAIT: begin
                    if (f1600_done) begin
                        // Cập nhật State từ kết quả máy xay
                        state <= f1600_out;
                        word_index <= 0; // Reset con trỏ
                        
                        if (is_padding_phase) begin
                            // Nếu vừa chạy xong pha padding -> Xong việc -> Squeeze
                            current_state_fsm <= S_SQUEEZE;
                        end else begin
                            // Nếu chỉ là đầy buffer -> Quay lại hút tiếp
                            current_state_fsm <= S_ABSORB;
                            o_ready <= 1;
                        end
                    end
                end
                //------------------------------------
                S_SQUEEZE: begin
                    // Xuất dữ liệu ngẫu nhiên ra ngoài
                    o_valid <= 1;
                    
                    // Logic to choose the 128 bit data
                    if (word_index < SQUEEZE_FULL_WORDS) begin
                        // 0 ... 9 full 128bit
                        o_data  <= state[word_index*128 +: 128];
                    end
                    else begin
                        //the last word (word 10 : just have 64 bit of RATE (1280 -> 1343)
                        // 1344-> last is capacity -> bis mats
                        // insert 0 to high 64bit
                        o_data  <= {64'd0, state[1280 +: 64]};
                    end
                    
                    if (i_ack) begin
                        // Bên ngoài đã đọc xong, chuẩn bị số tiếp theo
                        if (word_index == RATE_WORDS - 1) begin
                            // Hết dữ liệu trong State hiện tại -> Cần chạy f1600 tiếp (Squeeze more)
                            o_valid <= 0;
                            f1600_start <= 1;
                            is_padding_phase <= 1; // Vẫn giữ ở mode Squeeze
                            current_state_fsm <= S_PERM_WAIT;
                        end else begin
                            word_index <= word_index + 1;
                        end
                    end
                end
                //------------------------------------
            endcase
        end
    end
    
endmodule
