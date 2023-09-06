`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/018/2015 19:02:59 PM
// Design Name: 
// Module Name: input converter
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
//  -Consists of State machine to reduce the width of the input width
//   to a smaller size and prodcue an output value
//  - State machine consists of two states:
//     IDLE:
//        if (valid) read and store the data into a register and go to count
//     COUNT:
//        count max times necessary to break down the input words
// ASSUMPTION:
//   THE INPUT DATA HAS TO BE EITHER LESS THAN 256 bits and multiple of 2 or
//   A MULTIPLE OF 256 bits for values greater than 256
// ------------------------------------------------------
// Revision History:
//     March 25th 2015
//   - Modifying the design and assuming the data has to be a multiple of
//     256 bits. There can be only two cases. Data is 256bits or greater
//     Apr 25
//        In order to reduce the high fan-out of the data_points from Input converter,
//    The value of the data point read from the fifo is registered. This will allow
//    the synthesis tool to distribute the fan-out signal to make timing
//    
//////////////////////////////////////////////////////////////////////////////////


module input_converter #(
			 parameter integer INPUT_WIDTH= 256,
			 //parameter integer ADDR_BITS = 4,
			 parameter integer PRECISION = 32,
			 parameter integer DIMENSION = 4,
			 parameter integer OUTPUT_WIDTH = DIMENSION*PRECISION
			 // parameter integer MAX = 2
			 )
   (
    clk,
    reset_n,
    i_fifo_full,
    i_map,
    i_res,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tready,
    o_fifo_data,
    o_fifo_write,
    NUM_PTS
   
    );
   
   
   // INPUT SIGNALS
   input 				   clk,reset_n;
   input [INPUT_WIDTH-1:0] 		   s_axis_tdata;
   input 				   s_axis_tvalid;
   input 				   s_axis_tlast;
   input 				   i_fifo_full;
   input 				   i_map;
   input 				   i_res;
   
   
   // OUTPUT SIGNALS
   output [OUTPUT_WIDTH-1:0] 		   o_fifo_data;
   output 				   o_fifo_write; // new valid data available
   output 				   s_axis_tready;
   output [63:0] 			   NUM_PTS;
   
   // INTERNAL REGISTERS

   reg [63:0] 				   num_pts;
   
   
   // generate appropriate input_converter core with 
   // respect to the input and output width
   
   generate 
      
      if (PRECISION*DIMENSION <= INPUT_WIDTH)
	begin
           input_converter_1 # (
				.INPUT_WIDTH(INPUT_WIDTH)
				)i_c1(
				      .i_fifo_full(i_fifo_full),
				      .s_axis_tdata(s_axis_tdata),
				      .s_axis_tvalid(s_axis_tvalid),
				      .s_axis_tready(s_axis_tready),
				      .o_fifo_data(o_fifo_data),
				      .o_fifo_write(o_fifo_write)
				      );
        end        
      else
	begin
           input_converter_2 #(
			       .INPUT_WIDTH(INPUT_WIDTH),
			       .PRECISION(PRECISION),
			       .DIMENSION(DIMENSION)
			       ) i_c2 (
				       .clk(clk),
				       .reset_n(reset_n),
				       .i_fifo_full(i_fifo_full),
				       .s_axis_tdata(s_axis_tdata),
				       .s_axis_tvalid(s_axis_tvalid),
				       .s_axis_tlast(s_axis_tlast),
				       .s_axis_tready(s_axis_tready),
				       .o_fifo_data(o_fifo_data),
				       .o_fifo_write(o_fifo_write)

				       );
	end
   endgenerate 
   

   // COUNT NUMBER OF INPUT POINTS
   always @ (posedge clk)
     begin
	if (!reset_n || i_res)
	  num_pts  <= 0;
	else if (o_fifo_write & i_map)
	  num_pts <= num_pts + 1'b1;
     end
   
   assign NUM_PTS = num_pts;
   
endmodule


/***
 // 
 // Module Name: input_converter_1
 // Additional Comments:
 //   This module is part of input_converter module
 //   and it takes care of the input conversion when 
 //   the input_width == output_width
 **/



module input_converter_1  #(
			    parameter integer INPUT_WIDTH= 256,
			    parameter integer OUTPUT_WIDTH = INPUT_WIDTH // only one word at a time
			    )
   (
    //   clk,
    //  reset_n,
    i_fifo_full,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tready,
    o_fifo_data,
    o_fifo_write
   
   
    );

   //   input 		  clk,reset_n;
   
   input [OUTPUT_WIDTH-1:0] 		      s_axis_tdata;
   input 				      s_axis_tvalid;
   input 				      i_fifo_full;
   
   
   output [OUTPUT_WIDTH-1:0] 		      o_fifo_data;
   output 				      o_fifo_write; // new valid data available
   output 				      s_axis_tready;
   
   
   assign   s_axis_tready = !i_fifo_full;
   assign   o_fifo_write = (s_axis_tvalid && s_axis_tready) ? 1'b1 : 1'b0;
   assign   o_fifo_data = s_axis_tdata;
   
   
   

   
endmodule // input_converter_1



/***
 // 
 // Module Name: input_converter2
 // Additional Comments:
 //   This module is addition to input_coverter module
 //   where it handles the cases with output_data being
 //   greater than the data input.
 // Revision History:
 //  March 25th 2015
 //  - Originally the valid output would be asserted when counter == 0. This would
 //    cause an invalid output in the initial phase after the first t_read.
 //    in order to bypass this problem, the condition to check for a valid output is now
 //    if counter == 1'b1 and this value is delayed in o_fifo_valid_reg so that it is asserted
 //    when the counter is infact 0.
 **/



module input_converter_2  #(
			    parameter integer INPUT_WIDTH= 256,
			    parameter integer PRECISION = 32,
			    parameter integer DIMENSION = 4,
			    parameter integer OUTPUT_WIDTH = DIMENSION*PRECISION

			    )
   (
    clk,
    reset_n,
    i_fifo_full,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tready,
    o_fifo_data,
    o_fifo_write
   
    );
   
   // FUNCTION THAT OUTPUTS LOG2 OF THE INPUT
   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction

   // FIND THE LOG2 OF THE DEPTH OF THE RAM  
   //  localparam OUTPUT_WIDTH = width_adjusted(PRECISION*DIMENSION);
   localparam width_multiple = (OUTPUT_WIDTH/INPUT_WIDTH)-1; // 
   localparam counter_bits = clogb2(OUTPUT_WIDTH/INPUT_WIDTH);    
   
   
   // INPUT SIGNALS
   input clk,reset_n;
   
   input [INPUT_WIDTH-1:0] s_axis_tdata;
   input 		   s_axis_tvalid;
   input 		   s_axis_tlast;
   input 		   i_fifo_full;
   
   
   // OUTPUT SIGNALS
   output [OUTPUT_WIDTH-1:0] o_fifo_data;
   output 		     o_fifo_write; // new valid data available
   output 		     s_axis_tready;
   
   
   reg [counter_bits-1:0]    counter; // counter to keep track of output data numbers
   reg [OUTPUT_WIDTH-1:0]    data_out_reg; // register and accumulate the output data
   
   
   parameter [1:0] IDLE=2'b00, COUNT_A = 2'b01, COUNT_B=2'b10;
   
   
   // INTERNAL WIRES 
   reg [1:0] 		     current_state,next_state;
   reg 			     counter_en;

   wire 		     o_fifo_valid;
   reg 			     o_fifo_valid_reg;
   
   
   assign s_axis_tready = !i_fifo_full;
   assign t_read = (s_axis_tvalid & s_axis_tready /*& !s_axis_tlast*/) ? 1'b1 : 1'b0; // ready to read
   
   
   /*****FSM*****/
   
   // NEXT STATE LOGIC COMBINATIONAL
   always @(*)
     begin
	case(current_state)
          IDLE:
            begin
               if (t_read)
                 next_state = COUNT_B;
               else
                 next_state = IDLE;
            end
          COUNT_B:
            begin
               if (t_read & !s_axis_tlast) // INSTEAD OF ONLY T_READ T_LAST HAS TO BE INCLUDED *******************
                 next_state = COUNT_B;
               else
		 next_state  = IDLE;
            end
          default:
            begin
               next_state = IDLE;
            end
        endcase
	
     end
   
   
   // NEXT_STATE LOGIC
   always @ (posedge clk)
     begin
        if (!reset_n )
          current_state <= IDLE;
        else
          current_state <= next_state;
	
     end
   
   
   // OUTPUT LOGIC COMBINATIONAL
   always @(*)
			      begin
				 counter_en = 1'b0;
				 
				 case(current_state)
				   IDLE:
				     begin
					if(t_read)
					  counter_en = 1'b1;
					
					// s_axis_tready = 1'b1;
				     end
				   
				   COUNT_B:
				     begin
					//o_fifo_data = input_data[((counter+1)*OUTPUT_WIDTH)-1 -:OUTPUT_WIDTH];
					if(t_read )
					  counter_en = 1'b1;
					
					//if( counter==0)
					//  o_fifo_write = 1'b1;
				     end
				 endcase
			      end
   
   
   
   // DATA PATH
   
   // registers input_data and max_in
   // with synch resent and enable to
   // get new input and max value
   always @(posedge clk)
     begin
        if(!reset_n)
          begin
             data_out_reg <= 0;
          end
        else if (counter_en)
          data_out_reg [((counter+1)*INPUT_WIDTH)-1 -: INPUT_WIDTH] <= s_axis_tdata;
	else
	  data_out_reg <= data_out_reg;
	
     end    
   
   
   
   // counter with synch reset 
   always @( posedge clk)
     begin
        // reset when counter_en is high meaning the fsm is in count state
        // this is to take care of the case where the valid is only high for two cycles,
        // but goes low immediately. this would prevent the counter to be updated in the IDLE phase
        if (!reset_n || (counter == width_multiple && counter_en))
          counter <= 0;
        else if (counter_en)
          counter <= counter + 1;
        else
          counter <= counter;
	
	
     end
   
   
   // Register to delay o_fifo_valid signal
   always @( posedge clk)
     begin
        if (!reset_n)
          o_fifo_valid_reg = 1'b0;
        else
          o_fifo_valid_reg = o_fifo_valid;
	
     end
   
   assign o_fifo_data = (counter == 0) ? data_out_reg : 0;  
   assign o_fifo_valid = (counter == width_multiple && counter_en/*current_state == COUNT_B*/) ? 1'b1 : 1'b0; // counter_en is only high in COUNT_B state
   assign o_fifo_write = o_fifo_valid_reg; //o_fifo_valid_reg; // register used in order to bypass valid output when counter == 0. More info in Revision history
   
   
   

endmodule // input_converter_2
