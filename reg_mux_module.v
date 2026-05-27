module r_m_m #(parameter WIDTH = 4 , parameter PIPELINE_ENABLE = 1 , parameter RSTTYP = "SYNC" ) (


   input [WIDTH-1:0] a,

   input clk , rst , ce ,

   output  [WIDTH-1:0] out

  
);

reg [WIDTH-1 :0]  out_seq ;

generate
  if ( RSTTYP == "ASYNC")begin
    always @ (posedge clk or posedge rst ) begin 
     if (rst) 
      out_seq <= {WIDTH{1'b0}};
   


    else if (ce) begin
        out_seq <= a ;
        
    end
end
  end 

else begin 
   always @ (posedge clk  ) begin 
     if (rst) 
      out_seq <= {WIDTH{1'b0}};
   


    else if (ce) begin
        out_seq <= a ;
        
    end
end
end


endgenerate

assign out = ( PIPELINE_ENABLE )?  out_seq : a ;

endmodule 
