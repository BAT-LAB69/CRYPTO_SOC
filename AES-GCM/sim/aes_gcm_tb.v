`timescale 1ns / 1ps

module tb_aes_gcm_encdec;

    reg         clk, rst, start, mode;
    reg  [255:0] key;
    reg  [95:0]  nonce;
    reg  [127:0] plaintext1, plaintext2, plaintext3, plaintext4;
    reg  [159:0] aad;
    reg  [127:0] tag_received;

    wire [127:0] ciphertext1, ciphertext2, ciphertext3, ciphertext4;
    wire [127:0] tag;
    wire         done, tag_match;

    // Luu ket qua encrypt
    reg [127:0] saved_ct1, saved_ct2, saved_ct3, saved_ct4;
    reg [127:0] saved_tag;
    reg [127:0] saved_pt1, saved_pt2, saved_pt3, saved_pt4;

    aes_gcm_top uut (
        .clk(clk), .rst(rst), .start(start), .mode(mode),
        .key(key), .nonce(nonce),
        .plaintext1(plaintext1), .plaintext2(plaintext2),
        .plaintext3(plaintext3), .plaintext4(plaintext4),
        .aad(aad), .tag_received(tag_received),
        .ciphertext1(ciphertext1), .ciphertext2(ciphertext2),
        .ciphertext3(ciphertext3), .ciphertext4(ciphertext4),
        .tag(tag), .done(done), .tag_match(tag_match)
    );

    initial clk = 0;
    always #4.4 clk = ~clk;

    initial begin
        rst = 1; start = 0; mode = 0; tag_received = 0;
        key = 0; nonce = 0; aad = 0;
        plaintext1 = 0; plaintext2 = 0; plaintext3 = 0; plaintext4 = 0;

        repeat(10) @(posedge clk);
        rst = 0;
        repeat(5) @(posedge clk);

        $display("\n========================================");
        $display("  ENCRYPT -> luu bien -> DECRYPT");
        $display("========================================\n");

        // =============================================
        // BUOC 1: ENCRYPT
        // =============================================
        mode = 0;
        key   = 256'hfeffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308;
        nonce = 96'hcafebabefacedbaddecaf888;
        aad   = 160'hfeedfacedeadbeeffeedfacedeadbeefabaddad2;
        plaintext1 = 128'hd9313225f88406e5a55909c5aff5269a;
        plaintext2 = 128'h86a7a9531534f7da2e4c303d8a318a72;
        plaintext3 = 128'h1c3c0c95956809532fcf0e2449a6b525;
        plaintext4 = 128'hb16aedf5aa0de657ba637b391aafd255;
        tag_received = 128'h0;

        // Luu PT goc truoc khi encrypt
        saved_pt1 = plaintext1;
        saved_pt2 = plaintext2;
        saved_pt3 = plaintext3;
        saved_pt4 = plaintext4;

        @(posedge clk); start = 1;
        @(posedge clk); start = 0;
        @(posedge done);
        @(posedge clk);

        // Luu CT + Tag tu ket qua encrypt
        saved_ct1 = ciphertext1;
        saved_ct2 = ciphertext2;
        saved_ct3 = ciphertext3;
        saved_ct4 = ciphertext4;
        saved_tag = tag;

        $display("  [ENCRYPT] Done");
        $display("  CT1 = %h", saved_ct1);
        $display("  CT2 = %h", saved_ct2);
        $display("  CT3 = %h", saved_ct3);
        $display("  CT4 = %h", saved_ct4);
        $display("  TAG = %h\n", saved_tag);

        repeat(5) @(posedge clk);

        // =============================================
        // BUOC 2: DECRYPT (dung CT + Tag vua luu)
        // =============================================
        mode = 1;
        plaintext1 = saved_ct1;
        plaintext2 = saved_ct2;
        plaintext3 = saved_ct3;
        plaintext4 = saved_ct4;
        tag_received = saved_tag;

        @(posedge clk); start = 1;
        @(posedge clk); start = 0;
        @(posedge done);
        @(posedge clk);

        $display("  [DECRYPT] Done");
        $display("  PT1 = %h  %s", ciphertext1, (ciphertext1 === saved_pt1) ? "OK" : "FAIL!");
        $display("  PT2 = %h  %s", ciphertext2, (ciphertext2 === saved_pt2) ? "OK" : "FAIL!");
        $display("  PT3 = %h  %s", ciphertext3, (ciphertext3 === saved_pt3) ? "OK" : "FAIL!");
        $display("  PT4 = %h  %s", ciphertext4, (ciphertext4 === saved_pt4) ? "OK" : "FAIL!");
        $display("  TAG match = %b  %s", tag_match, (tag_match === 1'b1) ? "OK" : "FAIL!");

        if (ciphertext1 === saved_pt1 && ciphertext2 === saved_pt2 &&
            ciphertext3 === saved_pt3 && ciphertext4 === saved_pt4 && tag_match === 1'b1)
            $display("\n  >>> PASS: Decrypt ra dung plaintext goc! <<<");
        else
            $display("\n  >>> FAIL <<<");

        $display("\n========================================\n");
        $finish;
    end

    initial begin
        #2000000;
        $display("ERROR: TIMEOUT!");
        $finish;
    end

endmodule
