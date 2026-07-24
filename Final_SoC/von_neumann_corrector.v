`timescale 1ns/1ps

//==============================================================================
// VON NEUMANN CORRECTOR — Loại bỏ thiên lệch (bias) trong chuỗi bit
//==============================================================================
// Nguyên lý:
//   - Lấy 2 bit liên tiếp từ nguồn entropy
//   - Nếu "01" → output = 0, nếu "10" → output = 1
//   - Nếu "00" hoặc "11" → bỏ qua (không output)
//
// Hiệu quả:
//   - Chuyển đổi entropy từ ~0.97 → ~0.999+ (loại bỏ first-order bias)
//   - Đánh đổi: Throughput giảm ~75% (trung bình chỉ giữ 25% số bit)
//   - Nhưng đổi lại chất lượng entropy cực cao
//
// Resource: ~5 LUTs, ~3 FFs
//==============================================================================

module von_neumann_corrector (
    input  wire clk,
    input  wire rst,
    input  wire bit_in,       // Raw bit từ TRNG core
    input  wire bit_in_valid, // Raw bit valid
    output reg  bit_out,      // Corrected bit
    output reg  bit_out_valid // Corrected bit valid (KHÔNG đều đặn)
);

    reg        prev_bit;      // Bit trước đó
    reg        has_prev;      // Đã có bit trước hay chưa

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_bit      <= 1'b0;
            has_prev      <= 1'b0;
            bit_out       <= 1'b0;
            bit_out_valid <= 1'b0;
        end else begin
            bit_out_valid <= 1'b0;   // Default: không có output

            if (bit_in_valid) begin
                if (!has_prev) begin
                    // Lưu bit đầu tiên trong cặp
                    prev_bit <= bit_in;
                    has_prev <= 1'b1;
                end else begin
                    // So sánh cặp 2 bit
                    has_prev <= 1'b0;    // Reset, bắt đầu cặp mới
                    
                    if (prev_bit != bit_in) begin
                        // "01" → output 0, "10" → output 1
                        bit_out       <= prev_bit;
                        bit_out_valid <= 1'b1;
                    end
                    // "00" hoặc "11" → bỏ qua, không output
                end
            end
        end
    end

endmodule
