   `timescale 1ns / 1ps
 //////////////////////////////////////////////////////////////////////////////////
 // Company: 
 // Engineer: Ehsan Ghasemi
 // 
 // Create Date: 04/03/2015 10:11:12 AM
 // Design Name: Ehsan Ghasemi
 // Module Name: Accumulator
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
 // Assumptions:
 //  
 //   
 // Change log:
 //
 //////////////////////////////////////////////////////////////////////////////////
module accumulator #(
     parameter integer NUM_OF_REDUCERS = 2,
     parameter integer NUM_PTS = 3
   //  parameter integer SUM_WIDTH = 32

     )(
       clock,
       reset_n,

       i_reduce_counters,
       i_res, // reset
       o_done

       );


   localparam integer  SUM_WIDTH = 32;
   
   
   // INPUTS
   input 	       clock,reset_n;//,enable; // enable is when !fifo_full
   
   input [(NUM_OF_REDUCERS*SUM_WIDTH)-1:0] i_reduce_counters;
   input 			    i_res;
   output 			    o_done;
   
   reg [SUM_WIDTH-1:0] 			    sum [NUM_OF_REDUCERS-1:0];
   
   
   integer 					   i;

   /*
   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction // clogb2

   localparam addr_bits = clogb2(NUM_OF_REDUCERS-1);
   */

   initial
     begin
	for ( i = 0; i < NUM_OF_REDUCERS; i = i + 1)
	  sum[i] = 0;
     end
   
  
  always @ (posedge clock)
    begin

       for ( i = 0 ; i < NUM_OF_REDUCERS ; i = i + 1 )
	 begin
	    if (!reset_n || i_res)
	      sum[i] <= 0;
	    else
	      begin
		 if ( i == 0 )
		   sum[i] <=  i_reduce_counters[((i+1)*SUM_WIDTH)-1-:SUM_WIDTH];
		 else
		   sum[i] <= sum[i-1] + i_reduce_counters[((i+1)*SUM_WIDTH)-1-:SUM_WIDTH]; 
	      end
	end

   end
   
   assign o_done =    (sum[NUM_OF_REDUCERS-1] == NUM_PTS ) ; 
   

   
endmodule // acknowledgement

