module dsp #(
    // Parameters 
    parameter A0REG         = 0,
    parameter A1REG         = 1,
    parameter B0REG         = 0,
    parameter B1REG         = 1,
    parameter CREG          = 1,
    parameter DREG          = 1,
    parameter MREG          = 1,
    parameter PREG          = 1,
    parameter CARRYINREG    = 1,
    parameter CARRYOUTREG   = 1,
    parameter OPMODEREG     = 1,
    parameter CARRYINSEL    =  "OPMODE5",
    parameter B_INPUT       = "DIRECT", 
    parameter RSTTYPE       = "SYNC"    
)(
    // Input Ports
    input  wire [17:0] A,
    input  wire [17:0] B,
    input  wire [17:0] D,
    input  wire [47:0] C,
    input  wire        CLK,
    input  wire        CARRYIN,
    input  wire  [7:0] opmode_in,
    input  wire [17:0] BCIN,
    input  wire        RSTA,
    input  wire        RSTB,
    input  wire        RSTM,
    input  wire        RSTP,
    input  wire        RSTC,
    input  wire        RSTD,
    input  wire        RSTCARRYIN,
    input  wire        RSTOPMODE,
    input  wire        CEA,
    input  wire        CEB,
    input  wire        CEM,
    input  wire        CEP,
    input  wire        CEC,
    input  wire        CED,
    input  wire        CECARRYIN,
    input  wire        CEOPMODE,
    input  wire [47:0] PCIN,

    // Output Ports
    output wire [17:0] BCOUT,   // assign BCOUT =  B1_OUT ; // CONCAT_D_A_B { D[11:0] , A1_OUT , B1_OUT  }
    output wire [47:0] PCOUT, // assign pcout = p ;
    output wire [47:0] P,
    output reg [35:0] M,   
    output wire        CARRYOUT,
    output wire        CARRYOUTF
);
// internal signals 
wire [ 17:0 ] D_OUT ;
wire [ 17:0 ] A0_OUT ;
wire [ 17:0 ] A1_OUT ;
wire [ 17:0 ] B0_OUT ;
wire [ 17:0 ] B1_OUT ;
wire [ 47:0 ] C_OUT ;
wire [ 47:0 ] CONCAT_D_A_B ;
reg [ 17:0 ] B_MUX_BCIN ;
wire [ 17:0 ] PRE_OUT ;
wire [ 35:0 ] MULT_OUT ;
wire [ 35:0 ] M_OUT ;
reg  OPMAODE_MUX_CARRYIN ;
reg [ 47:0 ] MUX_X_OUT ;
reg [ 47:0 ] MUX_Z_OUT ;
wire [ 47:0 ] POST_OUT ;
wire [47:0] P_OUT ; 
wire CARRYOUT_OUT ;
wire CARRYOUT_IN ;
wire [17:0] PRE_OUT_MUX_B0_OUT ;
wire CARRYIN_OUT ;
wire [7:0] opmode ;



// CONNECTIONS 
assign  CONCAT_D_A_B  = { D[11:0] , A1_OUT , B1_OUT  } ;
assign BCOUT = B1_OUT ;
assign CARRYOUT = CARRYOUT_OUT ;
assign CARRYOUTF = CARRYOUT_OUT ;
assign PCOUT = P_OUT ;
assign P = P_OUT ;

// mux for carryin 

always @(*) begin
    case (CARRYINSEL)
    "OPMODE5" :  OPMAODE_MUX_CARRYIN = opmode [5] ;
    "CARRYIN" : OPMAODE_MUX_CARRYIN = CARRYIN ; 
     default : OPMAODE_MUX_CARRYIN = 1'b0 ;
        
        
    endcase
end

// mux for B
always @(*) begin
    case (B_INPUT)
    "DIRECT" :  B_MUX_BCIN = B ;
    "CASCADE" : B_MUX_BCIN = BCIN ; 
     default : B_MUX_BCIN = 18'b0 ;
        
        
    endcase
end

// PRE IMP 

assign PRE_OUT = ( opmode [6])?   ( D_OUT - B0_OUT ) : ( D_OUT + B0_OUT ) ;

// mux for pre or b0_out 

assign  PRE_OUT_MUX_B0_OUT = ( opmode [4])? PRE_OUT : B0_OUT ;

// mult imp 

assign MULT_OUT = B1_OUT * A1_OUT ;

// mux x 
always @(*) begin
    case (opmode [1:0])
    2'b00 : MUX_X_OUT = 48'b0 ;
    2'b01 : MUX_X_OUT = {12'b0 , M_OUT } ;
    2'b10 : MUX_X_OUT = P_OUT ;
    2'b11 : MUX_X_OUT = CONCAT_D_A_B ; 
        
    endcase
end

// mux x 
always @(*) begin
    case (opmode [3:2])
    2'b00 : MUX_Z_OUT = 48'b0 ;
    2'b01 : MUX_Z_OUT = PCIN ;
    2'b10 : MUX_Z_OUT = P_OUT ;
    2'b11 : MUX_Z_OUT = C_OUT ; 
        
    endcase
end

// POST IMP  
assign { CARRYOUT_IN , POST_OUT } = (opmode [7] )? (MUX_Z_OUT - (MUX_X_OUT+CARRYIN_OUT)) : (MUX_Z_OUT + MUX_X_OUT );

// instantiate the r_m_m



// 5 modules with WIDTH = 18
r_m_m #(18, A0REG, RSTTYPE) u0 (.a(A),                  .clk(CLK), .rst(RSTA),        .ce(CEA),        .out(A0_OUT));
r_m_m #(18, A1REG, RSTTYPE) u4 (.a(A0_OUT),             .clk(CLK), .rst(RSTA),        .ce(CEA),        .out(A1_OUT));
r_m_m #(18, B0REG, RSTTYPE) u3 (.a(B_MUX_BCIN),         .clk(CLK), .rst(RSTB),        .ce(CEB),        .out(B0_OUT));
r_m_m #(18, B1REG, RSTTYPE) u1 (.a(PRE_OUT_MUX_B0_OUT), .clk(CLK), .rst(RSTB),        .ce(CEB),        .out(B1_OUT));
r_m_m #(18, DREG, RSTTYPE) u2 (.a(D),                   .clk(CLK), .rst(RSTD),        .ce(CED),        .out(D_OUT));

// 2 modules with WIDTH = 48
r_m_m #(48, CREG, RSTTYPE) u5 (.a(C),                   .clk(CLK), .rst(RSTC),        .ce(CEC),        .out(C_OUT));
r_m_m #(48, PREG, RSTTYPE) u6 (.a(POST_OUT),            .clk(CLK), .rst(RSTP),        .ce(CEP),        .out(P_OUT));

// 1 module with WIDTH = 36
r_m_m #(36, MREG, RSTTYPE) u7 (.a(MULT_OUT),            .clk(CLK), .rst(RSTM),        .ce(CEM),        .out(M_OUT));

// 1 module with WIDTH = 8
r_m_m #(8, OPMODEREG, RSTTYPE) u8 (.a(opmode_in),       .clk(CLK), .rst(RSTOPMODE),   .ce(CEOPMODE),   .out(opmode));

// 2 modules with WIDTH = 1
r_m_m #(1, CARRYINREG, RSTTYPE)  u9  (.a(OPMAODE_MUX_CARRYIN), .clk(CLK), .rst(RSTCARRYIN),  .ce(CECARRYIN),  .out(CARRYIN_OUT));
r_m_m #(1, CARRYOUTREG, RSTTYPE) u10 (.a(CARRYOUT_IN),         .clk(CLK), .rst(RSTCARRYIN),  .ce(CECARRYIN),  .out(CARRYOUT_OUT));

 








// BUFFER FOR M 



always @(posedge CLK ) begin
    
   M <= M_OUT;

end

endmodule
