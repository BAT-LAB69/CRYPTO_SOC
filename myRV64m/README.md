# Bộ Vi Xử Lý RV64M (RISC-V 64-bit với M-Extension) 🚀

Dự án này là một bộ vi xử lý **RISC-V 64-bit** (kiến trúc RV64I + M extension) được thiết kế đặc biệt để tối ưu hóa tần số tối đa (**Fmax**) hướng tới triển khai trên **ASIC**, với thiết kế Pipeline 5 bước tiêu chuẩn và hệ thống xử lý lỗi (Hazard) cùng bộ chuyển tiếp (Forwarding) mạnh mẽ.

---

## 📌 Cấu Trúc Pipeline 5 Bước

Bộ vi xử lý được chia thành 5 giai đoạn pipeline hoàn chỉnh để đảm bảo thông lượng 1 lệnh/chu kỳ (CPI = 1) trong hầu hết các trường hợp:

1. **IF (Instruction Fetch)**: Nạp lệnh. Sử dụng bộ đếm chương trình (PC) và bộ nhớ lệnh (IMEM bọc dưới dạng Block RAM/ROM để tương thích với tổng hợp mảng FPGA/ASIC). 
2. **ID (Instruction Decode)**: Giải mã lệnh. Sử dụng `ImmGen` để tạo immediate, `Controller` để phát sinh tín hiệu điều khiển, và đọc dữ liệu từ `RegFile`. Mạch giải quyết nhảy nhánh (Branch) được di dời đến bước EX để giảm tải độ trễ chuỗi (combinational depth) cho tần số cao.
3. **EX (Execute)**: Thực thi lệnh. Tích hợp `ALU` hỗ trợ đầy đủ số học số nguyên 64-bit, mạch nhánh (Branch Compare), bộ cộng `Adder` cho địa chỉ nhảy, và khối đặc biệt **`MulDiv`** xử lý các lệnh `MUL`, `DIV`, `REM` đa chu kỳ.
4. **MEM (Memory Access)**: Truy cập bộ nhớ. Quản lý Đọc/Ghi dữ liệu thông qua `DMEM`, với formatter cho kích thước Byte, Half-Word, Word và Double-Word.
5. **WB (Write Back)**: Ghi ngược dữ liệu trở lại tập thanh ghi (Register File). Nút cổ chai "Đọc-Sau-Ghi" (Read-After-Write) trong cùng một chu kỳ được triệt tiêu bằng hệ thống bọc chuyển tiếp đồng bộ tự động bên trong `RegFile`.

---

## ⚡ Các Tối Ưu Hóa Tần Số (Fmax Optimization)

Nhằm ép xung nhịp cực đại hỗ trợ quy trình thiết kế phần cứng ASIC mượt mà, một loạt đánh giá phân tích WNS / TNS đã được áp dụng:

* **Slicing Bus Muxes (Phân Tách Fanout)**:
  Tín hiệu từ Register Pipeline xuống Forwarding Muxes trước đó chịu fanout > 130 khiến Vivado ghép chung logic và gây ra delay lưới (net delay) khổng lồ ~14ns. Chúng tôi đã khắc phục bằng phần mềm bằng cách sao chép song song (Replication) `ForwardingUnit` thành 4 khối quản lý 16-bit độc lập (`_0` đến `_3`). Sử dụng hằng số `(* DONT_TOUCH = "TRUE" *)`, trình dịch không thể gộp chúng lại, làm giảm fanout tuyệt đối trên mỗi đường tín hiệu và tăng Fmax đáng kể.
* **Cấu Trúc Điều Khiển Phân Nhánh Tuần Tự**:
  Module `ControlStall.v` trước đây sử dụng tổ hợp tĩnh đã được đổi thành *Sequential Logic* (`always @(posedge clk)`), loại bỏ đường critical path quá sâu nằm trên chuỗi `Hazards -> Flush -> PC Mux`.
* **Sửa Lỗi Đồng Bộ Pipeline BRAM Bị Mất Reset**:
  Kiểm soát chặt IF/ID và giải quyết độ trễ bù lệch do đọc đồng bộ trên Block RAM bằng cách không đánh sập `pc_current` trong quy trình flush rẽ nhánh, loại trừ lỗ hổng "Reset Lặp PC=0" hoàn toàn.
* **SRAI Shift Bugfix**:
  Ngôn ngữ Verilog không bảo toàn `$signed` trong toán tử 3 ngôi nếu một nhánh là `unsigned`. Chúng tôi phân tách tính toán `>>` và `>>>` dứt khoát tại `ALU.v` để khôi phục xử lý đúng lệnh *Shift Right Arithmetic* mà không tăng logic.

---

## 🧮 Gói M-Extension Đa Chu Kỳ (Multi-Cycle Mul/Div)

Thay vì tích hợp tổ hợp cồng kềnh, khối M được triển khai thành các state machine linh hoạt đảm bảo Fmax cho đường dữ liệu dài. Khối M có thể gây *Stall* hoàn toàn các giai đoạn (PC, IF_ID) nhờ `HazardDetection` khi lệnh bị nán lại.

### 1. `BoothMultiplier.v` 
Xử lý các phép toán (`MUL`, `MULH`, `MULHSU`, `MULHU`, `MULW`). Sử dụng hệ thống Shift-and-Add 64 chu kỳ (Radix-2/4 concept) trên thanh ghi Accumulator 128-bit. Quản lý dứt khoát bit dấu (Signed x Signed), (Signed x Unsigned), (Unsigned x Unsigned).

### 2. `NonRestoringDivider.v`
Chịu trách nhiệm (`DIV`, `DIVU`, `REM`, `REMU` và Word variant). Triển khai cơ chế rẽ nhánh chia Non-Restoring 64 chu kỳ. Bao gồm cả mạch bắt ngoại lệ tuân thủ chặt chuẩn của RISC-V: Chia x/0 (Divide by Zero) trả về thương toàn số 1, dư số gốc; Lỗi tràn Min_Int / -1 trả đúng Max Signed Boundary.

### 3. `CLA64.v` (Carry-Lookahead Adder)
Bộ cộng 64-bit ASIC hoàn chỉnh. Phục vụ cho `ALU` và các module cộng (`Adder`). Khối thiết lập cấu trúc tháp 4 tầng Lookahead nhanh (CLU4 -> CLA16 -> CLA64). Được ưu tiên để tổng quát thay vì khai thác dấu `+` mặc định của FPGA, hỗ trợ quá trình synthesize lên cấp độ C-MOS standard cells tốt hơn.

---

## 🧪 Hệ Thống Mô Phỏng & Kiểm Thử (Testbench)

Toàn bộ lệnh đã được tổ hợp thành máy (machine code) thông qua script Python `asm.py` tích hợp. 

**Chương Trình Test Thống Nhất (`RV64_Full_tb.v`)**:
Tất cả các phép tính cơ bản I-Type, R-Type, nhảy JAL/Branch, Memory Load/Store và toàn bộ các mã lệnh M-Extension được trộn lẫn liền kề nhau để thử lửa tính năng chống Hazard (như Read-After-Write) lẫn năng lực giữ trạng thái 64 chu kỳ.

**Kết quả Simulation:**
Mọi bài test (total 30 lệnh và kiểm tra register) đều **PASS 100%**. Lệnh `MULHU`, `DIV` hay `REM` được xử lý đa khung nhịp cũng đồng bộ ghi xuất đúng giá trị mong muốn ngược về thanh ghi, kể cả trong tình trạng chèn đè cực gắt của vi kiến trúc.

```text
  PASS: x5 = 20 (0x0...14) - ADDI x5, x0, 20
  PASS: x7 = 30 (0x0...1e) - ADD  x7, x1, x5
  PASS: x12 = 10485760 - SLL  x12, x1, x5
  PASS: x21 = -3 - SRAI x21, x3, 1
  PASS: x30 = -1 - MULH x30, x3, x2
  PASS: x1 = 0 - MULHU x1, x1, x2
  PASS: x2 = 3 - DIV  x2, x10, x27
  PASS: x3 = 0 - REM  x3, x10, x27
====================================================================
  ALL 30 TESTS PASSED!
====================================================================
```
