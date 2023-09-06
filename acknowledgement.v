   `timescale 1ns / 1ps
 //////////////////////////////////////////////////////////////////////////////////
 // Company: 
 // Engineer: Ehsan Ghasemi
 // 
 // Create Date: 03/27/2015 08:33:12 PM
 // Design Name: Ehsan Ghasemi
 // Module Name: Acknowledgement
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
module acknowledgement #(
     parameter integer NUM_OF_REDUCERS = 2,
     parameter integer NUM_OF_PARTITIONERS = 3

     )(
       clock,
       reset_n,

       i_ack,
       o_ack


       );

   
   
   // INPUTS
   input clock,reset_n;//,enable; // enable is when !fifo_full

   input [(NUM_OF_REDUCERS*NUM_OF_PARTITIONERS)-1:0] i_ack;

   output reg [NUM_OF_PARTITIONERS-1:0] 		   o_ack;

   //reg 						   ack;
   
   
   integer 					   i, j;


   always @ (*)
     begin

	for (i = 0 ; i < NUM_OF_PARTITIONERS; i= i+1)
	  begin
        o_ack[i] = 0;
	     for ( j = 0 ; j < NUM_OF_REDUCERS; j = j+1)
	       begin
		      //if (i_ack[(j*NUM_OF_REDUCERS)+i] == 1'b1)
		        o_ack[i] = o_ack[i] | i_ack[(j*NUM_OF_PARTITIONERS)+i]; //1'b1;
		  
	       end
	     

	  end
	

     end

   

   
endmodule // acknowledgement

