`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2026 11:27:09 PM
// Design Name: 
// Module Name: AES_CRYPT
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


module AES_CRYPT;
   
    reg  [127:0] plaintext; 
    reg  [127:0] key;
    reg  [127:0] iv;
    wire [127:0] ciphertext; 
   
    integer errors;

    
    aes_enc_top uut (
        .in (plaintext),   
        .iv (iv),         
        .key(key),        
        .out(ciphertext)   
    );

  
    task check_result;
        input [127:0] expected_cipher;
        input integer vector_id;
        begin
            #100; 
            
            if (ciphertext === expected_cipher) begin
                $display("Vector %0d: [PASS]", vector_id);
            end else begin
                $display("Vector %0d: [FAIL]", vector_id);
                $display("  - Input Plain: %h", plaintext);
                $display("  - Input IV   : %h", iv);
                $display("  - Expected   : %h", expected_cipher);
                $display("  - Received   : %h", ciphertext);
                errors = errors + 1;
            end
        end
    endtask

    
    initial begin
        $display("================ START AES-128 CBC TEST ================");
        errors = 0;

       
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        // ==========================================================
        // SET 1 - VECTOR 1
        // ==========================================================
        iv        = 128'h000102030405060708090A0B0C0D0E0F;
        plaintext = 128'h6bc1bee22e409f96e93d7e117393172a;
        
        check_result(128'h7649abac8119b246cee98e9b12e9197d, 1);

        // ==========================================================
        // SET 1 - VECTOR 2
        // ==========================================================
        iv        = 128'h7649ABAC8119B246CEE98E9B12E9197D;
        plaintext = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
       
        check_result(128'h5086cb9b507219ee95db113a917678b2, 2);

        // ==========================================================
        // SET 1 - VECTOR 3
        // ==========================================================
        iv        = 128'h5086CB9B507219EE95DB113A917678B2;
        plaintext = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
      
        check_result(128'h73bed6b8e3c1743b7116e69e22229516, 3);

        // ==========================================================
        // SET 1 - VECTOR 4
        // ==========================================================
        iv        = 128'h73BED6B8E3C1743B7116E69E22229516;
        plaintext = 128'hf69f2445df4f9b17ad2b417be66c3710;
        
        check_result(128'h3ff1caa1681fac09120eca307586e1a7, 4);

        // 5. Kết luận
        $display("--------------------------------------------------------");
        if (errors == 0) begin
            $display("RESULT: ALL TESTS PASSED SUCCESSFULLY! (CONGRATS)");
        end else begin
            $display("RESULT: FAILED with %0d error(s).", errors);
        end
        $display("========================================================");
        
        $finish;
    end
endmodule
