`timescale 1ns/1ps

module ed25519_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] seed;
    reg [255:0] msg;
    reg [6:0] msg_len;

    // Outputs
    wire [255:0] sig_r;
    wire [255:0] sig_s;
    wire done;
    wire busy;

    // Test Vectors
    reg [255:0] test_seed;
    reg [255:0] expected_pub_key;
    reg [255:0] expected_sig_r_1, expected_sig_s_1;
    reg [255:0] expected_sig_r_2, expected_sig_s_2;
    reg [255:0] expected_sig_r_3, expected_sig_s_3;
    reg [255:0] expected_pub_key_2;
    reg [255:0] expected_pub_key_3;
    
    // Messages
    reg [255:0] msg1_padded;
    reg [255:0] msg2_padded;
    reg [255:0] msg3;

    // Instantiate Ed25519 Core (Wrapper with SHAKE)
    ed25519_shake128 uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .seed(seed),
        .msg(msg),
        .msg_len(msg_len),
        .sig_r(sig_r),
        .sig_s(sig_s),
        .done(done),
        .busy(busy)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Helper function to reverse bytes
    function [255:0] reverse_bytes;
        input [255:0] in_data;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                reverse_bytes[i*8 +: 8] = in_data[(31-i)*8 +: 8];
            end
        end
    endfunction

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        start = 0;
        seed = 0;
        msg = 0;

        // TEST VECTORS FROM testcase.md (LITTLE-ENDIAN FORMAT)
        // TC1: Empty message (0 bytes)
        test_seed = 256'h9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60;
        expected_pub_key = 256'h64c5dff883e0f2ac2011542065f73060734b74c3eb4cfc2e0282290988f5dda7;
        expected_sig_r_1 = 256'he89da6a271f08a693f2689f8ba15f1efe20bb1c2d9724f4a8d903a1221d01f2d;
        expected_sig_s_1 = 256'h051bb9bd5ec90348ad23aa167f645e67d5c9bee6160a10d44aaf262045d7ad7c;
        msg1_padded = 256'h0;

        // TC2: 1-byte message (0x72)
        expected_sig_r_2 = 256'h9032f83f342930df871a1a2a769eee87af285a82106894a85d325d17ffac3ba3;
        expected_sig_s_2 = 256'h07adf8a1385998de6588da1ce8c35a7317b1695f202b76ce19eac250753a0a04;
        expected_pub_key_2 = 256'h2a9bd4434e938261e0ad0313ae9453d2a06e0026bbe397338ace3ce59d1ecb3d; // TC2 Public Key
        msg2_padded = 256'h72;

        // TC3: 2-byte message (0xaf82)
        msg3 = 256'haf82;
        expected_sig_r_3 = 256'hef3d3d84744c6d77e17f08998d99be604c941527359ca63cb530b7f9303f88ce;
        expected_sig_s_3 = 256'h05852d5c28177c95b2c8a546d1cc36918ac2473443fdf49adc2cb56cc8c8e6e7;
        expected_pub_key_3 = 256'he56f73b5103a536ad0226493384a2a1c69296697c58102d4ce992adbe7096c05;

        
        // Wait 100 ns for global reset to finish
        #100;
        rst_n = 1;
        #100;
        
        // TC1
        
        $display("--- TEST CASE 1: Empty Message (0 bytes) ---");
        seed = test_seed;
        msg = msg1_padded;
        msg_len = 7'd0;
        start = 1;
        #10 start = 0;

        wait(done);
        #10;
        
        $display("Expected PubKey: %h", expected_pub_key);
        $display("Actual   PubKey: %h", uut.u_ed_core.pub_key_y);
        
        $display("Expected Sig R: %h", expected_sig_r_1);
        $display("Actual   Sig R: %h", sig_r);
        $display("Expected Sig S: %h", expected_sig_s_1);
        $display("Actual   Sig S: %h", sig_s);

        if (uut.u_ed_core.pub_key_y == reverse_bytes(expected_pub_key)) begin
             $display(">> PubKey Check: PASS");
             if (sig_r == expected_sig_r_1 && sig_s == expected_sig_s_1)
                 $display(">> TC1 Result: PASS (All checks passed)");
             else
                 $display(">> TC1 Result: FAIL (Signature mismatch)");
        end else begin
            $display(">> PubKey Check: FAIL");
            $display(">> TC1 Result: FAIL (PubKey mismatch)");
        end
        

        #100;

        // TC2 - DIFFERENT SECRET KEY!
        $display("\n--- TEST CASE 2: 1-byte Message (0x72) ---");
        rst_n = 0; #20; rst_n = 1; #20; // Hard Reset between tests
        seed = 256'h4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb; // TC2 Secret Key
        msg = msg2_padded;
        msg_len = 7'd1;
        msg1_padded = 0; // Clear prev msg
        
        start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Expected PubKey: %h", expected_pub_key_2);
        $display("Actual   PubKey: %h", uut.u_ed_core.pub_key_y);

        $display("Expected Sig R: %h", expected_sig_r_2);
        $display("Actual   Sig R: %h", sig_r);
        $display("Expected Sig S: %h", expected_sig_s_2);
        $display("Actual   Sig S: %h", sig_s);

        if (uut.u_ed_core.pub_key_y == reverse_bytes(expected_pub_key_2)) begin
             $display(">> PubKey Check: PASS");
             if (sig_r == expected_sig_r_2 && sig_s == expected_sig_s_2)
                 $display(">> TC2 Result: PASS (All checks passed)");
             else
                 $display(">> TC2 Result: FAIL (Signature mismatch)");
        end else begin
            $display(">> PubKey Check: FAIL");
            $display(">> TC2 Result: FAIL (PubKey mismatch)");
        end

        #100;

        // TC3
        
        $display("\n--- TEST CASE 3: 2-byte Message (0xaf82) ---");
        rst_n = 0; #20; rst_n = 1; #20; // Hard Reset between tests
        seed = 256'hc5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7; // TC3 Secret Key  
        msg = msg3;
        msg_len = 7'd2;
        msg2_padded = 0; // Clear prev msg
        
        start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Expected PubKey: %h", expected_pub_key_3);
        $display("Actual   PubKey: %h", uut.u_ed_core.pub_key_y);

        $display("Expected Sig R: %h", expected_sig_r_3);
        $display("Actual   Sig R: %h", sig_r);
        $display("Expected Sig S: %h", expected_sig_s_3);
        $display("Actual   Sig S: %h", sig_s);

        if (uut.u_ed_core.pub_key_y == reverse_bytes(expected_pub_key_3)) begin
             $display(">> PubKey Check: PASS");
             if (sig_r == expected_sig_r_3 && sig_s == expected_sig_s_3)
                 $display(">> TC3 Result: PASS (All checks passed)");
             else
                 $display(">> TC3 Result: FAIL (Signature mismatch)");
        end else begin
            $display(">> PubKey Check: FAIL");
            $display(">> TC3 Result: FAIL (PubKey mismatch)");
        end
        

        #100;
        $finish;
    end

    initial begin
        $monitor("Time: %t | State: %d | Done: %b", $time, uut.u_ed_core.state, done);
    end

    always @(posedge uut.shake_done) begin
        $display("[Time %t] SHAKE DONE asserted. DOUT: %h", $time, uut.shake_dout);
        $display("            DIN: %h", uut.shake_din);
    end

endmodule

//iverilog -o ed25519_sim ed25519_tb.v ed25519_shake128.v ed25519_top.v scala_mul_25519.v point_op_25519.v add_sub_25519.v inv_25519.v mul_25519.v arithmetic.v reducer.v keccak_f1600.v keccak_round.v sponge.v shake128_top.v && vvp ed25519_sim