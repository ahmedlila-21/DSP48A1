module r_m_m_tb ();

reg clk , ce ,rst ;

reg [17:0]a_tb ;

wire [17:0] out_dut_sync ; 
wire [17:0] out_dut_async ;
wire [17:0] out_dut_comb ;  

r_m_m #( 18 ,  1 ,  "SYNC" ) dut1(


     a_tb,

    clk , rst , ce ,

     out_dut_sync 

  
);
r_m_m #( 18 ,  1 ,  "ASYNC" ) dut2(


     a_tb,

    clk , rst , ce ,

     out_dut_async 

  
);
r_m_m #( 18 ,  0 ,  "ASYNC" ) dut3(


     a_tb,

    clk , rst , ce ,

     out_dut_comb 

  
);


always begin 
    clk = 0 ;
    forever begin
         #5 clk = ~clk ;
    end
end 



initial begin
    rst = 1 ;
    ce = 1;
   
    @(negedge clk );

    rst = 0 ;
    ce = 1 ;

    repeat (100) begin 
         a_tb = $random ;
         @(negedge clk );
    end 

    $stop ;

        

end

endmodule 