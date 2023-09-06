`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ehsan Ghasemi
// 
// Create Date: 03/26/2015 17:55:53 PM
// Design Name: Ehsan Ghasemi
// Module Name: reduce arbiter
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
//    
// Assumptions:
// This module contains an instatiation of an arbiter
// as well as an implementation of the mux which communicates
// with partitioners, Value_in fifos, and one instance of a reducer
// Revision:
//
// Apr 22:
//   In order to meet timing, o_ack is registered and the registered value
//    is used as the select line to the muxes
// Apr 26:
//   In order to meet timing, the o_KV_valid signal is registred to reduce the
//   routing delay of this wire to inputs to the reducers
// Apr 27:
//   Changes from Apr 26 is reverted back because it would cause the core to not terminate
//   it's execution
// May 18
//   The Xbar to pass the data_pts between the partitioner is reduced
//   to PRECISION rather than DIMENSION*PRECISION. This way, sending
//   data elements with more than one DIMENSION takes N cycles where N
//   is number of dimensions.
//   In order to support that, this module now has a state machine 
//   which takes the value from each dimesion every cycle and
//   combine it to pass to the reducer.
//////////////////////////////////////////////////////////////////////////////////


module reduce_arbiter #(
			parameter integer NUM_OF_PARTITIONERS = 4,
			parameter integer PRECISION = 16,
			parameter integer DIMENSION = 2

			)(
			  clock,
			  reset_n,
			  //fifo_re, // this specifies that there is an idle mapper and an available data point
			  i_request,
			  i_reduce_en,
			  i_value_data_in,
			  i_key_data_in,

			  o_acknowledged,  // the request is granted. This connects to the START port of the mappers
			  //o_acknowledged, // specify the request is acknowledged
			  o_value_data_out,
			  o_key_data_out,
			  o_KV_valid
			  //fifo_empty

			  );

   // INPUTS
   input 				  clock,reset_n; // enable is when !fifo_full
   input [NUM_OF_PARTITIONERS-1:0] 	  i_request;
   input 				  i_reduce_en; // the reduce core is idle and ready to accept new data
   input [ (NUM_OF_PARTITIONERS*PRECISION)-1:0] i_value_data_in;
   input [ (NUM_OF_PARTITIONERS*16)-1:0] 		  i_key_data_in;
   // input 		      fifo_re;
   
   //OUTPUTS
   output [NUM_OF_PARTITIONERS-1:0] 			  o_acknowledged;
   output [(PRECISION*DIMENSION)-1:0] 			  o_value_data_out;
   output [15:0] 					  o_key_data_out;
   output 						  o_KV_valid; // valid signal that indicates to reducer the <key,val> pair is valid
   
   
   

   //INTERNAL WIRES

   wire [NUM_OF_PARTITIONERS-1:0] 			  grant;
   wire 						  grant_valid;
   
   reg [NUM_OF_PARTITIONERS-1:0] 			  acknowledged_reg;
   reg 							  grant_valid_delay;

   // VARIABLES FOR COMBINING THE DIMENSION BACK TOGETHER
   reg [7:0] 						  counter;
   reg 							  counter_en;
   localparam READY = 2'b00, RECEIVING = 2'b10, DELAY = 2'b01;
   reg [1:0] 						  current_state, next_state;
   wire [(PRECISION)-1:0] 			  value_data_out;
   reg [(PRECISION*DIMENSION)-1:0] 			  value_data_out_reg;
   reg 							  ready;
   

   /******** FSM *********/
   
   // COMBINATIONAL LOGIC FOR NEXT STATE
   always @(*)
     begin
	case(current_state)
	  READY:
            begin
               if (grant_valid)
		 next_state = DELAY;
	       else 
		 next_state = READY;
            end
	  DELAY:
	    next_state = RECEIVING;
	  RECEIVING:
            begin
	       // hold the value for one cycle after i_ack is received
               if (counter == DIMENSION-1) 
		 next_state = READY;
	       else
		 next_state = RECEIVING;
            end
	  default:
	    next_state =READY;
	  
	endcase // case (current_state)
	
     end // always @ always
   
  // STATE TRANSITION
   always @(posedge clock)
     begin
	if (!reset_n)
	  current_state <= READY;	
	else
	  current_state <= next_state;
     end
   
    // OUTPUT LOGIC   
   always @(* /*asd*/ )
     begin
	counter_en = 1'b0;
	ready = 1'b0;
	
	case(current_state)
	  READY:
	    begin
	       ready = 1'b1;
	    end
          RECEIVING:
            begin
	       counter_en  = 1'b1;
//	       data_out =mux_value_out_reg[((counter+1)*PRECISION)-1-:PRECISION];
	       
            end
        endcase // case (current_state)
	
     end // always
   
//  
   // ARBITER INSTANTIATION 	
   arbiter #(
	     .NUM_OF_MAPPERS (NUM_OF_PARTITIONERS)
	     ) arb (
		    .clock(clock),
		    .reset_n(reset_n),
		    .enable(i_reduce_en && i_request && ready /*& reset_n*/),
		    .request(i_request),
		    .grant(grant),
		    .grant_valid(grant_valid)
		    );



   // MUX INSTANTIATION FOR VALUE OUTPUT
   mux # (
	  .NUM_OF_PARTITIONERS(NUM_OF_PARTITIONERS),
	  .PRECISION(PRECISION),
	  .DIMENSION(1)
	  ) value_mux (
		       
		       //ack is used instead of grant since the correct
		       //value takes one cycle to be read from value fifo
		       .in(i_value_data_in),
		       .sel(acknowledged_reg), 
		       .out(value_data_out)
		       );
   
   // MUX INSTATITAION FOR KEY OUTPUT
   mux # (
	  .NUM_OF_PARTITIONERS(NUM_OF_PARTITIONERS),
	  .PRECISION(16),
	  .DIMENSION(1)
	  ) key_mux (
		     .in( i_key_data_in),
		     .sel(acknowledged_reg),
		     .out(o_key_data_out)
		     );

   
   assign o_acknowledged = (grant_valid) ? grant : 0; // setup grant signal to the requesting appropriate value in fifo


   // THIS DELAY IS TO PIPELINE THE PATH BETWEEN THE ARBITER AND THE TWO MUXES
   // THE ACK_DELAY SIGNAL REPLACE THE O_ACK AS THE SELECT LINE TO THE MUXES
   always @(posedge clock)
     begin
	if(!reset_n)
	  acknowledged_reg <= 0;
	else if (grant_valid)
	  acknowledged_reg <= o_acknowledged;
	

     end

   // THE DATA PTS IS PASSED ONE CYCLE AFTER GRANT_VALID AND O_ACK IS SENT
   always @(posedge clock)
     begin
	if(!reset_n)
	  grant_valid_delay <= 0;
	else
	  grant_valid_delay <= grant_valid;
	

     end

     // COUNTER FOR COUTING NUMBER OF DIMENSION TO BE SENT

   always @(posedge clock)
     begin
	if (!reset_n || counter == DIMENSION)
	  counter <= 0;
	else if (counter_en)
	  counter <= counter + 1'b1;
     end
   
   // registers input_data and max_in
   // with synch resent and enable to
   // get new input and max value
   always @(posedge clock)
     begin
        if(!reset_n)
	  begin
             value_data_out_reg <= 0;
	  end
     else if (counter_en)
       value_data_out_reg [((counter+1)*PRECISION)-1 -: PRECISION] <= value_data_out ;
     end    
   //assign o_KV_valid = (o_grant != 0);
   //assign o_KV_valid = o_acknowledged !=0;
   // SIGNAL THE REDUCER THAT A VALID SIGNAL IS AVAILABLE
   assign o_KV_valid = (counter == DIMENSION-1);
//grant_valid;//_delay;
   assign o_value_data_out = value_data_out_reg;

endmodule // data_controller





//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name: Mux
//    
// Additional Comments:
//   This module is a parametrizable multiplexer 
//////////////////////////////////////////////////////////////////////////////////



module mux # (
	      parameter integer NUM_OF_PARTITIONERS = 4,
	      parameter integer PRECISION = 16 ,
	      parameter integer DIMENSION = 2
	      )
   (
    in,
    sel,
    out
    );

   // INPUTS
   //input clock, reset_n;
   input [(NUM_OF_PARTITIONERS*PRECISION*DIMENSION)-1:0] in;
   input [NUM_OF_PARTITIONERS-1:0] 			 sel;
   //OUTPUTS
   output reg [(PRECISION*DIMENSION)-1:0] 		 out;
   reg [NUM_OF_PARTITIONERS-1:0] 			 index;
   // INTERNAL VARS
   integer						 i;
   
   // COMBINATIONAL
   always @ (*)
     begin
        index = 0;  
	// DECODING AND MULTIPLEXING
	for ( i = 0 ; i < NUM_OF_PARTITIONERS ; i = i + 1 )
	  begin
             
             if ( sel[i] == 1'b1)
               //out = in [((i+1)*PRECISION*DIMENSION)-1:0 ];
               index = i;
             
             out = in >> (index*PRECISION*DIMENSION);
	  end
	
     end
   
   // assign out = in >> (index*PRECISION*DIMENSION);
   
   /* for ( i = 0 ; i < NUM_OF_PARTITIONERS ; i = i + 1)
    begin
    assign out  = sel[i] ? in >> (i*PRECISION*DIMENSION) : 0;
     end 
    
    */  
   

endmodule // mux

