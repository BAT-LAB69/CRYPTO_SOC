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

// 25 Additional Random Test Cases

        // TC4: Random test 1
        $display("\n--- TEST CASE 4: Random Input (msg_len=23) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'hfbe2b0a91d0af8e6388dc3e26aa090dd7185fb2500fea8b3f6ef4263f1614632;
        msg = 256'h000000000000000000df885e09706a8cf221bf60a38df602d463db741f257326;
        msg_len = 7'd23;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC4 Complete (no crash)");
        #100;

        // TC5: Random test 2
        $display("\n--- TEST CASE 5: Random Input (msg_len=12) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h435b4beb44d55d879efa78387c69b757dfbabb170129afa93c731f141b891ed3;
        msg = 256'h000000000000000000000000000000000000000022f3e2ac0ae1f2721536ed6b;
        msg_len = 7'd12;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC5 Complete (no crash)");
        #100;

        // TC6: Random test 3
        $display("\n--- TEST CASE 6: Random Input (msg_len=24) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h74f53b7c0704260263a8bbaec3ca04cf3de806c56bfb14593d520470d2707a60;
        msg = 256'h0000000000000000fd48b132dbf9113e7de1a64c9956cec7049d3733ff7768b3;
        msg_len = 7'd24;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC6 Complete (no crash)");
        #100;

        // TC7: Random test 4
        $display("\n--- TEST CASE 7: Random Input (msg_len=23) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h97627ee472f809f4fc5670f5a3898971b1fe48893b7c8a4da4107d7adc777f81;
        msg = 256'h00000000000000000020499f127cdef0571d3f5fece1c1a0db45036bbf6e729b;
        msg_len = 7'd23;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC7 Complete (no crash)");
        #100;

        // TC8: Random test 5
        $display("\n--- TEST CASE 8: Random Input (msg_len=24) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h522f1ec5f15e24f26eafbaf81a8145fa18af328ce8400ebafa7d43f14c59aabd;
        msg = 256'h000000000000000049388e2764d006a31aca50cf3ad1fd3cddfb6439b5c0533f;
        msg_len = 7'd24;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC8 Complete (no crash)");
        #100;

        // TC9: Random test 6
        $display("\n--- TEST CASE 9: Random Input (msg_len=21) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'he85de9b225fb4446cf798ca6cff24fe19671a28600186194526f1c5852656756;
        msg = 256'h000000000000000000000024d89827cb7be9908cea69579ca3f22c188c7f75da;
        msg_len = 7'd21;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC9 Complete (no crash)");
        #100;

        // TC10: Random test 7
        $display("\n--- TEST CASE 10: Random Input (msg_len=7) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'hdf789c98f54b68c034a9ed5ed50128b638b53eb48c40a37377d9665dfc9c9346;
        msg = 256'h000000000000000000000000000000000000000000000000002f1c87c955adb3;
        msg_len = 7'd7;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC10 Complete (no crash)");
        #100;

        // TC11: Random test 8
        $display("\n--- TEST CASE 11: Random Input (msg_len=21) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'hf0f6a73ca59cc4bb5b0c161429efbf226af0f6686429e21c2ba5eebf8ba03381;
        msg = 256'h00000000000000000000005da511b12a7d961ecb9d365b806b7e71d2322ad7cb;
        msg_len = 7'd21;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC11 Complete (no crash)");
        #100;

        // TC12: Random test 9
        $display("\n--- TEST CASE 12: Random Input (msg_len=6) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h8be1e1e5fc57e4c5eb6a84313a855e0a31d7c9f266e834b2f097048e0d4f10ce;
        msg = 256'h0000000000000000000000000000000000000000000000000000685538c236b2;
        msg_len = 7'd6;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC12 Complete (no crash)");
        #100;

        // TC13: Random test 10
        $display("\n--- TEST CASE 13: Random Input (msg_len=6) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h5b1911116853f65677cdd31cfb5b1e9ac9275e89bb153df3eeec7460a8b638ee;
        msg = 256'h0000000000000000000000000000000000000000000000000000b4ec624f976f;
        msg_len = 7'd6;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC13 Complete (no crash)");
        #100;

        // TC14: Random test 11
        $display("\n--- TEST CASE 14: Random Input (msg_len=14) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h335cdad2c9ea47080c60c77e5c403e28be0d92f1ede2fc125bb2d0d37df9feba;
        msg = 256'h00000000000000000000000000000000000044eefda94ab4d009a9c758ff3409;
        msg_len = 7'd14;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC14 Complete (no crash)");
        #100;

        // TC15: Random test 12
        $display("\n--- TEST CASE 15: Random Input (msg_len=15) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'hc7f17a5653dc544d95ec560512fa8521c9bac6acfb04e49580d9ee13b7b4c0ac;
        msg = 256'h00000000000000000000000000000000007e405a7a440035bce26a2074d95ed9;
        msg_len = 7'd15;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC15 Complete (no crash)");
        #100;

        // TC16: Random test 13
        $display("\n--- TEST CASE 16: Random Input (msg_len=11) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h8a9b2bbd65faa0b6d33f81b036a14a7c55bbc00b2d6d85495e9484b671b7e433;
        msg = 256'h000000000000000000000000000000000000000000b14ad075de25b590146c0d;
        msg_len = 7'd11;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC16 Complete (no crash)");
        #100;

        // TC17: Random test 14
        $display("\n--- TEST CASE 17: Random Input (msg_len=4) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h6d0b26b36325a12aaec7dd0ff7f1b4b972b2b039a126a137752e4424cf37c65b;
        msg = 256'h000000000000000000000000000000000000000000000000000000008556972f;
        msg_len = 7'd4;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC17 Complete (no crash)");
        #100;

        // TC18: Random test 15
        $display("\n--- TEST CASE 18: Random Input (msg_len=17) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'ha5ff1b147f58e54a40d4975a39890ba5912c7cee3a0bd0af2e8944f5f2a3ea1d;
        msg = 256'h000000000000000000000000000000b6607809d097cc4c3178c426d23d072d95;
        msg_len = 7'd17;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC18 Complete (no crash)");
        #100;

        // TC19: Random test 16
        $display("\n--- TEST CASE 19: Random Input (msg_len=5) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h5dbecfb6a01225c614e1d4e42a67ebd51d43623a4a21bc0e30f9a7e0378cabf4;
        msg = 256'h000000000000000000000000000000000000000000000000000000af52c9e847;
        msg_len = 7'd5;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC19 Complete (no crash)");
        #100;

        // TC20: Random test 17
        $display("\n--- TEST CASE 20: Random Input (msg_len=5) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'hea461c1dc26792f108794bf099b643a1e74297753df8e1d96cb785be807751de;
        msg = 256'h0000000000000000000000000000000000000000000000000000005981fabca3;
        msg_len = 7'd5;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC20 Complete (no crash)");
        #100;

        // TC21: Random test 18
        $display("\n--- TEST CASE 21: Random Input (msg_len=14) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h26953aaf67bb4fae61809e77df4f33a4bb6677d94fd92c09632f5ba4ce2055d9;
        msg = 256'h000000000000000000000000000000000000b6de3fcefc5d4f0ec296e383777c;
        msg_len = 7'd14;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC21 Complete (no crash)");
        #100;

        // TC22: Random test 19
        $display("\n--- TEST CASE 22: Random Input (msg_len=19) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h9ab098f1e53965dda3b96e6d78cb87906180ca45292353e0b96ff53de8824074;
        msg = 256'h00000000000000000000000000f05b3b5289cf9b21776dc1cf1f3c9dea084981;
        msg_len = 7'd19;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC22 Complete (no crash)");
        #100;

        // TC23: Random test 20
        $display("\n--- TEST CASE 23: Random Input (msg_len=28) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h990973c01cf8fda9d3a4cc026d7869b0d405311dee8c61836c67c1572a03a731;
        msg = 256'h000000000982c120435df7c6a552d3c33d38d5adf095123c670b740c48a16724;
        msg_len = 7'd28;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC23 Complete (no crash)");
        #100;

        // TC24: Random test 21
        $display("\n--- TEST CASE 24: Random Input (msg_len=0) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h8cce4b6b98bc8dc8a20d2e8be2e4a5993cab3a97e7235fd8b8db83e5761abdac;
        msg = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        msg_len = 7'd0;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC24 Complete (no crash)");
        #100;

        // TC25: Random test 22
        $display("\n--- TEST CASE 25: Random Input (msg_len=0) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h669e3d9da3887ca9a7110ffbabb46da874f50a79bca3a7dd4f5e4bfcf4d6eb45;
        msg = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        msg_len = 7'd0;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC25 Complete (no crash)");
        #100;

        // TC26: Random test 23
        $display("\n--- TEST CASE 26: Random Input (msg_len=26) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'haab163823a8aebfad1ddb64e50d1440d17da66ace1ab88a3d1c855ceb68a389b;
        msg = 256'h00000000000091abb2636c9b5964ceabfae2245a530a2981fb3694e696d178e4;
        msg_len = 7'd26;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC26 Complete (no crash)");
        #100;

        // TC27: Random test 24
        $display("\n--- TEST CASE 27: Random Input (msg_len=21) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h165ebfca75ab49331241f43ca1088a5d7192897f87da6e2f8fa63bdf06aea1cf;
        msg = 256'h000000000000000000000071af8eaaf4a58160908a50f287190ee9e397890346;
        msg_len = 7'd21;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC27 Complete (no crash)");
        #100;

        // TC28: Random test 25
        $display("\n--- TEST CASE 28: Random Input (msg_len=29) ---");
        rst_n = 0; #20; rst_n = 1; #20;
        seed = 256'h0180ae714c23c414abff17103e68dcd5fa600e16ebef61d1b2845b63f61a4a43;
        msg = 256'h00000096b2810499b0682c543c7bdbc39501d87aaff2e2bddacc5389a0c91a43;
        msg_len = 7'd29;
        start = 1; #10 start = 0;
        wait(done); #10;
        $display("Sig R: %h", sig_r);
        $display("Sig S: %h", sig_s);
        $display(">> TC28 Complete (no crash)");
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

// cd /Users/vohoangnguyen/Documents/Ed25519_Shake128
// iverilog -o test_28 ed25519_tb_clean.v ed25519_shake128.v ed25519_top.v scala_mul_25519.v point_op_25519.v add_sub_25519.v inv_25519.v mul_25519.v arithmetic.v reducer.v keccak_f1600.v keccak_round.v sponge.v shake128_top.v
// vvp test_28