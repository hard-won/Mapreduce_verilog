`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ehsan Ghasemi
// 
// Create Date: 03/29/2015 11:19:40 AM
// Design Name: Ehsan Ghasemi
// Module Name: partition
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
// Revision History:
//   
//    - Apr 22
//        In order to meet timing, the reduce_arbiter.v reads the <key,val> pair
//         one cycle after it sends i_acknowledged signal. Therefore, the state transition
//         from RUNNING to READY is delayed by one cycle but the request signal is
//         still dependent on the current value of i_ack rather than the delayed value.
//   -  Apr 27
//        The design of the partitioner is changed. The partitioner now also includes
//         an arbiter to handle multiple (NUM_OF_MAPPERS) mapper at the same time. 
//         It also include two mux for selecting the key/val of the correct mapper. 
//         It also uses a special arbiter called partition_arbiter which 
//         takes requests only when enable is high
//   -  May 18
//        This module now breaks down data point with greater than 
//        1 dimension and send each dimension seperately. Therefore,
//        everytime a request from the partitioner is granted by one 
//        of the reducers, the data is sent per dimension.
//////////////////////////////////////////////////////////////////////////////////
module partition #(
		   parameter integer NUM_OF_PARTITIONERS = 4,
		   parameter integer NUM_OF_REDUCERS = 4,
		   parameter integer PRECISION = 16,
		   parameter integer DIMENSION = 2,
		   parameter integer NUM_OF_MAPPERS = 8

		   )(
		     clock,
		     reset_n,

		     i_fifo_val_data,
		     i_fifo_val_empty,
		     o_fifo_val_rden,

		     i_fifo_key_data,
		     i_fifo_key_empty,
		     o_fifo_key_rden,


		     i_acknowledged,
		     o_request,

		     o_value_data,
		     o_mem_index


		     );


   localparam READY = 2'b00, RUNNING = 2'b01, SENDING = 2'b10;
   reg [1:0] 			     current_state, next_state;
   
   
   
   // INPUTS
   input 			     clock,reset_n; // enable is when !fifo_full
   
   // SIGNALS VALUE FIFO IN
   input [(NUM_OF_MAPPERS*DIMENSION*PRECISION)-1:0] i_fifo_val_data;
   input [NUM_OF_MAPPERS-1:0] 			    i_fifo_val_empty;
   output [NUM_OF_MAPPERS-1:0] 			    o_fifo_val_rden;
   
   // SIGNALS KEY FIFO IN
   input [(16*NUM_OF_MAPPERS)-1:0] 		    i_fifo_key_data;
   input [NUM_OF_MAPPERS-1:0] 			    i_fifo_key_empty;
   output [NUM_OF_MAPPERS-1:0] 			    o_fifo_key_rden;

   
   input 					    i_acknowledged;
   output [NUM_OF_REDUCERS-1:0] 		    o_request;
   
   output [PRECISION-1:0] 			    o_value_data;
   output [15:0] 				    o_mem_index;
   

   // INTERNAL WIRES

   reg [NUM_OF_REDUCERS-1:0] 			    request_reg;
   wire [NUM_OF_REDUCERS-1:0] 			    request;
   reg 						    acknowledged_delay;
   
   wire [NUM_OF_MAPPERS-1:0] 			    mapper_request; // REQUEST FROM THE MAPPERS
   reg 						    arbiter_enable;
   
   wire [NUM_OF_MAPPERS-1:0] 			    grant;
   wire 					    grant_valid;
   reg 						    grant_valid_delay;

   
   wire [NUM_OF_MAPPERS-1:0] 			    fifo_rden;
   reg [NUM_OF_MAPPERS-1:0] 			    fifo_rden_reg;
   
   wire [15:0] 					    mux_key_out;
   reg [15:0] 					    mux_key_out_reg;
   wire [(DIMENSION*PRECISION)-1:0] 		    mux_value_out;
   reg [(DIMENSION*PRECISION)-1:0] 		    mux_value_out_reg;
   reg 						    request_valid;

   // REGS FOR FIXING THE CROSSBAR SIZE
   reg [7:0] 					    counter; // counter for counting number of dimension
   reg 						    counter_en;
   reg [PRECISION-1:0] 				    data_out;
   reg [PRECISION-1:0] 				    data_out_reg;
   
   
   
   /******** FSM *********/
   
   // COMBINATIONAL LOGIC FOR NEXT STATE
   always @(*)
     begin
	case(current_state)
	  READY:
            begin
               if (mapper_request)
		 next_state = RUNNING;
	       else 
		 next_state = READY;
            end
	  RUNNING:
            begin
	       // hold the value for one cycle after i_ack is received
               if (i_acknowledged) 
		 next_state = SENDING;
	       else
		 next_state = RUNNING;
            end
	  SENDING:
	    begin
	       if (counter == DIMENSION-1)
		 next_state = READY;
	       else
		 next_state = SENDING;
	    end
	  default:
            begin
               next_state = READY;
            end
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
	// fifo_rden = 1'b0;
	arbiter_enable = 1'b0;
	counter_en = 1'b0;
	data_out = 0;
	case(current_state)
          READY:
            begin
               if (mapper_request)
		 begin
		    //fifo_rden = 1'b1;
		    arbiter_enable = 1'b1;
		 end
            end
          SENDING:
            begin
	       counter_en  = 1'b1;
	       data_out =mux_value_out_reg[((counter+1)*PRECISION)-1-:PRECISION];
	       
            end
        endcase // case (current_state)
	
     end // always
   
   
   
   /******** DATAPATH *********/
   
   // REGISTER FIFO_RDEN AS SELECT LINE TO MUXES TO REDUCE CLOCK PERIOD
   // GRANT_VALID_DELAY AS ENABLE TO MUX_KEY/VAL REGISTERS
   always @ (posedge clock)
     begin
	if (!reset_n)
	  begin
	     fifo_rden_reg <= 0;
	     grant_valid_delay <= 1'b0;
	     request_valid <= 1'b0;
	  end
	else
	  begin
	     fifo_rden_reg <= fifo_rden;
	     grant_valid_delay <= grant_valid;
	     request_valid <= grant_valid_delay;
	  end
	
     end
   
   // REQUEST OUT REGISTER
   always @(posedge clock)
     begin
	if(!reset_n || i_acknowledged)
	  request_reg <= 0;
	else if (request_valid)
	  request_reg <= request;
	//else
	//request_reg <= request_reg;
     end
   
   // DELAY ACKNOWLEDGE SIGNAL BY 1 CYCLE
   // TO ENABLE THE REDUCER READ THE RIGHT DATA
   always @(posedge clock)
     begin
	if (!reset_n)
	  begin
	     acknowledged_delay = 1'b0;
	     data_out_reg <= 0;
	  end
	else
	  begin
	     acknowledged_delay = i_acknowledged;
	     data_out_reg <= data_out;
	     
	  end
     end
   
   // MUX_KEY/VAL_OUT_REG ARE REGISTERS
   // WHICH HOLD THE OUTPUT OF KEY/VAL MUXES
   
   always @(posedge clock)
     begin
	if (!reset_n)
	  mux_key_out_reg <= 0;
	else if (grant_valid_delay)
	  mux_key_out_reg <= mux_key_out;
     end
   
   always @(posedge clock)
     begin
	if (!reset_n)
	  mux_value_out_reg <= 0;
	else if (grant_valid_delay)
	  mux_value_out_reg <= mux_value_out;
	
     end
   // PARTITIONER INSTATIATION
   partitioner par (
		    .key_in(mux_key_out_reg),
		    .request_V(request),
		    .key_out(o_mem_index)
		    );



   // ARBITER INSTANTIATION 	
   arbiter #(
		       .NUM_OF_MAPPERS (NUM_OF_MAPPERS)
		       ) arb (
			      .clock(clock),
			      .reset_n(reset_n),
			      .enable(arbiter_enable),
			      .request(mapper_request),
			      .grant(grant),
			      .grant_valid(grant_valid)
			      );

   // MUX INSTANTIATION FOR VALUE OUTPUT
   mux # (
	  .NUM_OF_PARTITIONERS(NUM_OF_MAPPERS),
	  .PRECISION(PRECISION),
	  .DIMENSION(DIMENSION)
	  ) value_mux (
		       
		       //ack is used instead of grant since the correct
		       //value takes one cycle to be read from value fifo
		       .in(i_fifo_val_data),
		       .sel(fifo_rden_reg), 
		       .out(mux_value_out)
		       );
   
   // MUX INSTATITAION FOR KEY OUTPUT
   mux # (
	  .NUM_OF_PARTITIONERS(NUM_OF_MAPPERS),
	  .PRECISION(16),
	  .DIMENSION(1)
	  ) key_mux (
		     .in( i_fifo_key_data),
		     .sel(fifo_rden_reg),
		     .out(mux_key_out)
		     );
   

   // COUNTER FOR COUTING NUMBER OF DIMENSION TO BE SENT

   always @(posedge clock)
     begin
	if (!reset_n || counter == DIMENSION)
	  begin
	     counter <= 0;
	  end
	else if (counter_en)
	  counter <= counter + 1'b1;
     end
   
   
   assign mapper_request = ~i_fifo_key_empty;
   assign fifo_rden = grant_valid ? grant : 0;
   
   assign o_fifo_key_rden = fifo_rden;
   assign o_fifo_val_rden = fifo_rden;
   
   assign o_request = request_reg;
   assign o_value_data = data_out_reg;
   
endmodule // arbiter


//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name: Mux
//    
// Additional Comments:
//   This module is a parametrizable multiplexer 
//////////////////////////////////////////////////////////////////////////////////


