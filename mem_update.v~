`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2015 04:37:38 PM
// Design Name: 
// Module Name: mem_update
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
//  State machine consists of 3 stages:
//   IDLE: asserts ready if there is valid input and goes to UPDATE_A state
//   UPDATE_A: temporary delay for registering the valid input in width_converter block
//             move to state UPDATE_B
//   UPDATE_B: Wait for width_converter to finish. If K centres are written go back to idle
//             else assert ready and go to UPDATE_A
//    
// Assumptions:
// 	-The input data is continues in the sense that the bytes in the middle of one 
//   word is valid; i.e. ignoring the TSTRB value
//   
//	-
//////////////////////////////////////////////////////////////////////////////////


module mem_update #(

		    parameter integer PRECISION = 16,
		    parameter integer CENTRE_WIDTH = 16,
		    parameter integer DIMENSION = 4,
		    parameter integer INPUT_WIDTH= DIMENSION*CENTRE_WIDTH,
		    parameter integer OUTPUT_WIDTH = DIMENSION*CENTRE_WIDTH,
		    parameter integer K = 10,
		    parameter integer ADDR_BITS = 3
		    )
   (
    clock,
    reset_n,
    i_fifo_data,
    i_fifo_empty,
    i_init,
    o_fifo_rden,
    o_done,
    o_mem_data,
    o_mem_addr,
    o_mem_valid
   
    );

   //INPUTS
   input 			      clock,reset_n;
   input [INPUT_WIDTH-1:0] 	      i_fifo_data;
   input 			      i_fifo_empty;
   input 			      i_init;
   

   //OUTPUTS
   output 			      o_fifo_rden;
   output  			      o_done;
   output [OUTPUT_WIDTH-1:0] 	      o_mem_data;
   output [ADDR_BITS-1:0] 	      o_mem_addr;
   output  			      o_mem_valid;


   parameter integer 		      IDLE = 1'b0, RUNNING = 1'b1;

   reg 				      current_state,next_state;
   
   reg 				      fifo_rden;
   reg 				      mem_valid;
   
   // INTERNAL REGISTERS   
   reg [ADDR_BITS-1:0] 		      counter;




   always @ (*/*asd*/)
     begin
	case (current_state)
	  IDLE:
	    begin
	       if (i_init)
		 next_state = RUNNING;
	       else
		 next_state = IDLE;
	    end
	  RUNNING:
	    begin
	       if (counter == K)
		 next_state = IDLE;
	       else
		 next_state = RUNNING;
	    end
	endcase // case (current_state)
     end

   
   always @(posedge clock)
     begin
	if (!reset_n)
	  current_state = IDLE;

	else
	  current_state = next_state;
     end


   always @(* /*asd*/)
     begin
	fifo_rden = 1'b0;
	//o_mem_valid = 1'b0;
	
	case (current_state)
	  IDLE:
	    begin
	       
	    end
	  RUNNING:
	    begin
	       if (!i_fifo_empty)
		 fifo_rden = 1'b1;
	       //if (o_fifo_rden)
		//o_mem_valid <= 1'b1;
	       
	    end
	  
	endcase // case (current_state)
     end

   always @ (posedge clock)
     begin
	if (!reset_n )
	  mem_valid <= 1'b0;
	else
	  mem_valid <= fifo_rden;
     end
	     
   // counter with synch enable
   always @(posedge clock)
     begin
        if(!reset_n || counter == K)
          counter = 0;
        else if (mem_valid == 1'b1) // whenever a valid output is produced
          counter = counter + 1'b1;
        else
          counter = counter;

	
     end

   assign o_mem_addr = counter;
   assign o_done = (counter == K);
   assign o_mem_data = i_fifo_data;
   assign o_mem_valid = mem_valid;
   assign o_fifo_rden = fifo_rden;
   
   
   
endmodule 
