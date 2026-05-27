module dsp_tb(); 

    reg [17:0] A ;
    reg [17:0] B ;
    reg [17:0] D ;
    reg [47:0] C ;
    reg        CLK ;
    reg        CARRYIN ;
    reg  [7:0] opmode_in ;
    reg [17:0] BCIN ;
    reg        RSTA ;
    reg        RSTB ;
    reg        RSTM ;
    reg        RSTP ;
    reg        RSTC ;
    reg        RSTD ;
    reg        RSTCARRYIN ;
    reg        RSTOPMODE ;
    reg        CEA ;
    reg        CEB ;
    reg        CEM ;
    reg        CEP ;
    reg        CEC ;
    reg        CED ;
    reg        CECARRYIN ;
    reg        CEOPMODE ;
    reg [47:0] PCIN ;
    
    wire [17:0] BCOUT_dut;   
    wire [47:0] PCOUT_dut; 
    wire [47:0] P_dut;
    wire [35:0] M_dut;   
    wire        CARRYOUT_dut ;
    wire        CARRYOUTF_dut ;

    // Clock generation
    initial CLK = 0;
    always #5 CLK = ~CLK;

    // DUT instantiation
    dsp dut(
        A, B, D, C,
        CLK, CARRYIN, opmode_in, BCIN,
        RSTA, RSTB, RSTM, RSTP, RSTC, RSTD,
        RSTCARRYIN, RSTOPMODE,
        CEA, CEB, CEM, CEP, CEC, CED,
        CECARRYIN, CEOPMODE,
        PCIN,
        BCOUT_dut, PCOUT_dut, P_dut, M_dut,
        CARRYOUT_dut, CARRYOUTF_dut
    );

    initial begin 
        A  = $random;
        B  = $random;
        D  = $random;
        C  = $random;
        CARRYIN  = 0;
        opmode_in  = $random;
        BCIN  = $random;
        RSTA  = 1; RSTB  = 1; RSTM  = 1; RSTP  = 1;
        RSTC  = 1; RSTD  = 1; RSTCARRYIN  = 1; RSTOPMODE  = 1;
        CEA  = 0; CEB  = 0; CEM  = 0; CEP  = 0;
        CEC  = 0; CED  = 0; CECARRYIN  = 0; CEOPMODE  = 0;
        PCIN  = $random;

        @(negedge CLK); 

        if (BCOUT_dut != 0 || PCOUT_dut != 0 || P_dut != 0 || M_dut != 0 || CARRYOUT_dut != 0 || CARRYOUTF_dut != 0) begin 
            $display("error in resetting"); 
            $stop; 
        end 

        RSTA  = 0; RSTB  = 0; RSTM  = 0; RSTP  = 0;
        RSTC  = 0; RSTD  = 0; RSTCARRYIN  = 0; RSTOPMODE  = 0;
        CEA  = 1; CEB  = 1; CEM  = 1; CEP  = 1;
        CEC  = 1; CED  = 1; CECARRYIN  = 1; CEOPMODE  = 1;

        // path1
        opmode_in = 8'b11011101;
        A = 18'd20; B = 18'd10; C = 48'd350; D = 18'd25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat (4) @(negedge CLK);

        if (BCOUT_dut != 18'hf || M_dut != 36'h12c || P_dut != 48'h32 || PCOUT_dut != 48'h32 || CARRYOUT_dut != 0 || CARRYOUTF_dut != 0) begin 
            $display("error in path1"); 
            $stop; 
        end 

        // path2
        opmode_in = 8'b00010000;
        A = 18'd20; B = 18'd10; C = 48'd350; D = 18'd25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat (4) @(negedge CLK);

        if (BCOUT_dut != 18'h23 || M_dut != 36'h2bc || P_dut != 0 || PCOUT_dut != 0 || CARRYOUT_dut != 0 || CARRYOUTF_dut != 0) begin 
            $display("error in path2"); 
            $stop; 
        end 

        // path3
        opmode_in = 8'b00001010;
        A = 18'd20; B = 18'd10; C = 48'd350; D = 18'd25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat (4) @(negedge CLK);

        if (BCOUT_dut != 18'ha || M_dut != 36'hc8 || P_dut != PCOUT_dut || CARRYOUT_dut != CARRYOUTF_dut) begin 
            $display("error in path3"); 
            $stop; 
        end 

        // path4
        opmode_in = 8'b10100111;
        A = 18'd5; B = 18'd6; C = 48'd350; D = 18'd25;
        BCIN = $random; PCIN = 48'd3000; CARRYIN = $random;

        repeat (4) @(negedge CLK);

        if (BCOUT_dut != 18'h6 || M_dut != 36'h1e || P_dut != 48'hfe6fffec0bb1 || PCOUT_dut != 48'hfe6fffec0bb1 || CARRYOUT_dut != 1 || CARRYOUTF_dut != 1) begin 
            $display("error in path4"); 
            $stop; 
        end 

        $stop;
    end 

endmodule
