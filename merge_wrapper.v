`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2015 18:59:35 PM
// Design Name: 
// Module Name: merger
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
// fsm:
//  IDLE:
//    waits for scheduler to assert start signal to read data from all the reducers and update centres

// 
//////////////////////////////////////////////////////////////////////////////////



module merger_wrapper #(
			parameter integer NUMBER_OF_REDUCERS = 8,
			parameter integer CENTRE_WIDTH = 32,
			parameter integer SUM_WIDTH = 64,
			parameter integer DIMENSION = 4,
			parameter integer K = 10,
			parameter integer ADDR_BITS = 4,
			parameter integer BRAM_BITS = 3 // log2(K-1)

			)
   (
    clock,
    reset_n,
    i_start,
    i_sum_pts,
    i_count_pts,
   
   // o_ce_reducers, // chip enable
    //o_raddress_reducers, // next_addr (counter ) / NUM_OF_REDUCERS
    o_centre_wdata,
    o_centre_address,
    o_centre_we,
    o_done,
    
    /* CHANGES FOR FLOATING_POINT */
    o_ce_counters,
    o_ce_sums,
    o_counter_address,
    o_sum_address
    );

     
   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction // clogb2

   localparam REDUCE_BITS = clogb2(NUMBER_OF_REDUCERS-1);
   localparam TOTAL_BITS = REDUCE_BITS+BRAM_BITS;
   

   //INPUTS
   input 				  clock,reset_n, i_start;
   input [(NUMBER_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] i_sum_pts;
   input [(NUMBER_OF_REDUCERS*32)-1 : 0 ] 		   i_count_pts;
   

   //OUTPUTS
//   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_reducers;
 //  output reg [BRAM_BITS-1:0] 				   o_raddress_reducers; // less than ADDR_BITS number. In reality log2(NUM_OF_REDUCERS)
   output [(CENTRE_WIDTH*DIMENSION)-1:0] 		   o_centre_wdata;
   output [ADDR_BITS-1:0] 				   o_centre_address;
   output  						   o_centre_we;
   output  						   o_done;

   /* CHANGES FOR FLOATING_POINT */
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_counters;
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_sums;
   output reg [BRAM_BITS-1:0] 				   o_counter_address;
   output reg [BRAM_BITS-1:0] 				   o_sum_address;
             
  
   // INTERNAL REGISTERS
   reg [(SUM_WIDTH*DIMENSION)-1:0] 			   temp_sum;
   reg [31:0] 						   temp_count;
   
//   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_reducers_reg;

   integer 						   i;


   wire [TOTAL_BITS-1:0] 				   sum_address0;
   wire 						   sum_ce0;

   /* CHANGES FOR FLOATING_POINT */
   wire [ADDR_BITS-1:0] 				   counter_address0;
   wire 						   counter_ce0;
   
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_counter_reg;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_sum_reg;
   
  
   merger m (
             .ap_clk(clock),
             .ap_rst(!reset_n),
             .ap_start(i_start),
             .ap_done(o_done),
             .ap_idle(),
             .ap_ready(),
             .sum_address0(sum_address0),
             .sum_ce0(sum_ce0),
             .sum_q0(temp_sum),
	     .counter_address0(counter_address0),
	     .counter_ce0(counter_ce0),
	     .counter_q0(temp_count),
             .centres_address0(o_centre_address),
             .centres_ce0(), //output
             .centres_we0(o_centre_we),
             .centres_d0(o_centre_wdata)
	     );

   
   always @ (*/*asd*/)
     begin
//	o_ce_reducers = 0;
	o_ce_counters = 0;
	o_ce_sums = 0;

//	o_raddress_reducers = 0;
	o_counter_address = 0;
	o_sum_address = 0;
/*
	if (sum_ce0)
	  begin
//	     o_raddress_reducers = sum_address0 / NUMBER_OF_REDUCERS;
//	     o_ce_reducers[sum_address0 % NUMBER_OF_REDUCERS] = 1'b1;
	  end
 */
	if (sum_ce0)
	  begin
	     o_sum_address = sum_address0 / NUMBER_OF_REDUCERS;
	     o_ce_sums[sum_address0 % NUMBER_OF_REDUCERS] = 1'b1;
	  end
	if (counter_ce0)
	  begin
	     o_counter_address = counter_address0 / NUMBER_OF_REDUCERS;
	     o_ce_counters[counter_address0 % NUMBER_OF_REDUCERS] = 1'b1;   
	  end
	
     end
   
 

   // COMBINATIONAL BLOCK AS A MULTIPLEXER
   always @ (*/*asd*/)
     begin:mux_sum
	temp_sum = 0;
	for ( i = 0 ; i < NUMBER_OF_REDUCERS ; i = i + 1 )
	  begin
	     if (ce_sum_reg[i] == 1'b1)
	       begin
		  temp_sum = i_sum_pts[((i+1)*DIMENSION*SUM_WIDTH)-1 -: DIMENSION*SUM_WIDTH];
	       end
	  end
     end // block: mux_sum

   
    // COMBINATIONAL BLOCK AS A MULTIPLEXER
   always @ (*/*asd*/)
     begin:mux_counter
	temp_count = 0;
	for ( i = 0 ; i < NUMBER_OF_REDUCERS ; i = i + 1 )
	  begin
	     if (ce_counter_reg[i] == 1'b1)
	       begin
		  temp_count = i_count_pts[((i+1)*32)-1 -: 32];
		 
	       end
	  end
     end // block: mux_couter
   
   
   // DELAY CE_REDUCER SIGNALS AS THE INPUT TO THE MUX ABOVE
   always @ (posedge clock)
     begin
	if (!reset_n)
	  begin
//	     ce_reducers_reg = 0;
	     ce_sum_reg = 0;
	     ce_counter_reg = 0;
 	  end
	else
	  begin
//	     ce_reducers_reg = o_ce_reducers;
	     ce_sum_reg = o_ce_sums;
	     ce_counter_reg = o_ce_counters;
	     
	  end
     end

   

endmodule // centre_update
