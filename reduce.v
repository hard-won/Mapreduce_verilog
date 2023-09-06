`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2015 10:59:35 AM
// Design Name: 
// Module Name: reduce
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
// March 27th 2015
// - The HLS design for reducer was done.
//   Now modifying the reduce to incorporate the HLS design
// Apr 22:
//   In order to meet timing, the correct <K,V> pair is provided by
//    the reduce arbiter one cycle after the i_KV_valid is received.
//    Therefore, the execution is delayed by one cycle by delaying the i_KV_valid signal
//    using i_KV_valid_delay_delay signal
// Apr 25
//   In order to meet timing, the i_KV_valid signal is registred from inside of reduce_arbiter.
//   therefore, to synch the signals There is no need to have i_KV_valid_delay_delay.
// Apr 27:
//   Changes from Apr 25 is reverted back because the core would not terminate
//   the execution for any NUM_PTS greater than 20. Initial inspection showed that
//   the accumulate value of all the node processed would remain at 20. needed more
//   investigation
// Jun 05:
//   A bug was found with respect to i_KV_valid_delay_delay signal. Blocking statement was
//   used which made i_KV_delay signal and i_KV_delay_delay signal change at the same cycle.
//////////////////////////////////////////////////////////////////////////////////


module reduce #(
		parameter integer DIMENSION = 2,
		parameter integer PRECISION = 16,
		parameter integer DATA_WIDTH = PRECISION*DIMENSION,
		parameter integer SUM_WIDTH = 64,
		//parameter integer K = 10,
		parameter integer ADDR_BITS = 4, // bits required for number of cluster centres
		parameter integer BRAM_DEPTH = 8
		//parameter integer REDUCER_ADDR_BITS = 3 // 4 bits to address 16 different centres for each reducer
        
    )
   (
    clock,
    reset_n,
    merge, // send by the scheduler to indicate centres are being merged
    merge_done, // restart for next iteration

//    i_raddress,
//    i_ce,
    i_counter_address,
    i_sum_address,
    i_ce_sum,
    i_ce_counter,
    
    o_sum_data,
    o_counter_data,
    o_reduce_counters,
    
    i_value_data,
    i_key_data,
    i_KV_valid,
    o_reducer_ready
    
    
    );

   
   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction
   

   localparam bram_addr = clogb2(BRAM_DEPTH-1);
   
   // INPUTS
   input 			  clock, reset_n, merge_done,merge;
//   input [bram_addr-1:0] 	  i_raddress;
//   input 			  i_ce;
			  
   input [bram_addr-1:0] 	  i_sum_address;
   input 			  i_ce_sum;
   input [bram_addr-1:0] 	  i_counter_address;
   input 			  i_ce_counter;

 
   input [(PRECISION*DIMENSION)-1:0] i_value_data;
   input [15:0] 		     i_key_data;
   input 			     i_KV_valid;
   
   //OUTPUTS
   output [ (DIMENSION*SUM_WIDTH)-1 : 0 ] o_sum_data;
   output [31:0] 			  o_counter_data;
   output reg 				  o_reducer_ready;
   output [31:0] 			  o_reduce_counters;
   

  

   // fsm variables 
   parameter [1:0] IDLE=2'b00, RUNNING = 2'b01, MERGE=2'b10;
   reg [1:0] current_state, next_state;

   // INTERNAL WIRES

   
   reg 	     i_KV_valid_delay; // register to apply the start signal one cycle after valid data
   reg 	     i_KV_valid_delay_delay;
   
   reg [31:0] reduce_counter; // counter to show how many data has been processed
   
   // CONTROL SIGNALS FOR REDUCER HLS BLOCK
   reg 					reducer_start;
   wire 				reducer_idle;
   wire 				reducer_done;

   // REGISTER FOR INPUT DATA
   reg [(PRECISION*DIMENSION)-1:0] 	i_value_data_reg;
   reg [15:0] 				i_key_data_reg;

   // WIRES CONNECTED TO COUNTER REDUCER
   wire [bram_addr-1:0] 		counter_address0;
   wire 				counter_ce0;
   wire [31:0] 				counter_q0;
   wire [bram_addr-1:0] 		counter_address1;
   wire 				counter_ce1;
   wire 				counter_we1;
   wire [31:0] 				counter_d1;
   
   // WIRES CONNECTED TO SUM REDUCER
   wire [bram_addr-1:0] 		sum_address0;
   wire 				sum_ce0;
   wire [(DIMENSION*SUM_WIDTH)-1:0] 	sum_q0;
   wire [bram_addr-1:0] 		sum_address1;
   wire 				sum_ce1;
   wire 				sum_we1;
   wire [(DIMENSION*SUM_WIDTH)-1:0] 	sum_d1;
   
   // DELAY FOR SETTING THE MERGED VALUES TO ZERO
//   reg [ADDR_BITS-1:0] 			i_raddress_delay;
//   reg 					i_ce_delay;
   
   reg [ADDR_BITS-1:0] 			i_counter_address_delay;
   reg 					i_ce_counter_delay;
   reg [ADDR_BITS-1:0] 			i_sum_address_delay;
   reg 					i_ce_sum_delay;
   

   // WIRE FOR THE SIMPLE DUAL PORT BRAM FOR COUNTER
   wire [bram_addr-1:0] 		i_counter_waddr;
   wire 				i_counter_wen;
   wire [31:0] 				i_counter_wdata;
   wire [bram_addr-1:0] 		i_counter_raddr;
   wire 				i_counter_ce;
   wire [31:0] 				o_counter_rdata;
   
 // WIRE FOR THE SIMPLE DUAL PORT BRAM FOR SUM
   wire [bram_addr-1:0] 		i_sum_waddr;
   wire 				i_sum_wen;
   wire [(DIMENSION*SUM_WIDTH)-1:0] 	i_sum_wdata;
   wire [bram_addr-1:0] 		i_sum_raddr;
   wire 				i_sum_ce;
   wire [(DIMENSION*SUM_WIDTH)-1:0] 	o_sum_rdata;

   
   
   /////******** FSM *********/////

   // NEXT STATE COMBINATIONAL LOGIC
   always @(*/*asd*/)
     begin
	case (current_state)
	  IDLE:
	    begin
	       if (i_KV_valid)
		 next_state = RUNNING;
	       else if (merge)
		 next_state = MERGE;
	       else
		 next_state = IDLE;
	    end
	  RUNNING:
	    begin
	       if (reducer_done)
		 next_state = IDLE;
	       else
		 next_state = RUNNING;
	    end
	  MERGE:
	    begin
	       if (merge_done)
		 next_state = IDLE;
	       else
		 next_state = MERGE;
	       
	    end
	
	  default:
	    next_state = IDLE;
	  
	endcase // case (current_sate)
	
     end

   // STATE TRANSITION
   always @(posedge clock)
     begin
	if (!reset_n)
	  current_state <= IDLE;
	else
	  current_state <= next_state;
	
     end

   
   // OUTPUT LOGIC
   always @ (* /*asd*/)
     begin
	o_reducer_ready = 1'b0;
	reducer_start = 1'b0;
	case (current_state)
	  IDLE:
	    begin
	       // HAVING REDUCE_IDLE CREATE A COMBINATIONAL LOOP
	       // BETWEEN REDUCE_IDLE AND REDUCE_START 
	      // if (reducer_idle)
	       o_reducer_ready = 1'b1;
	     
	    end
	  RUNNING:
	   begin
	     // one cycle delay for the register to have the right <K,V>
	     if (i_KV_valid_delay_delay)
	       reducer_start = 1'b1;
	   end
	     
	endcase // case (curret_state)	
     end
   
   // INSTATIATION OF REDUCER MODULE
   reducer reducer_1 (
		      .ap_clk(clock),
		      .ap_rst(!reset_n),
		      .ap_start(reducer_start),
		      .ap_done(reducer_done),
		      .ap_idle(reducer_idle),
		      .ap_ready(),
		      .key(i_key_data_reg),
		      .pt(i_value_data_reg),
		      
		      .sum_address0(sum_address0),
		      .sum_ce0(sum_ce0),
		      .sum_q0(o_sum_rdata),
		      .sum_address1(sum_address1),
		      .sum_ce1(sum_ce1),
		      .sum_we1(sum_we1),
		      .sum_d1(sum_d1),
		      
		      .counter_address0(counter_address0),
		      .counter_ce0(counter_ce0),
		      .counter_q0(o_counter_rdata),
		      .counter_address1(counter_address1),
		      .counter_ce1(counter_ce1),
		      .counter_we1(counter_we1),
		      .counter_d1(counter_d1)
		     
		      );
   
   // REGISTER WITH ENABLE SIGNALS TO REGISTER THE  <K,V> pair
   always @(posedge clock)
     begin
	if (!reset_n)
	  begin
	     i_value_data_reg = 0;
	     i_key_data_reg = 0;
	     
	  end
	//else if (i_KV_valid)
	else if (i_KV_valid_delay)
	  begin
	     i_value_data_reg = i_value_data;
	     i_key_data_reg = i_key_data;
	     
	  end
	else
	  begin
	     i_value_data_reg = i_value_data_reg;
	     i_key_data_reg = i_key_data_reg;
	  end
     end




   // DUAL PORT BLOCK RAM TO COUNT NUMBER OF
   // ELEMENTS IN EACH CLUSTER
   bram_reducer #(
		  .C_WIDTH(32),
		  .C_LOG_DEPTH(bram_addr)
		  ) counter_1 (
			       .i_clk(clock),

			       .i_waddr(i_counter_waddr),
			       .i_wen(i_counter_wen),
			       .i_wdata(i_counter_wdata),

			       .i_raddr(i_counter_raddr),
			       .i_ce(i_counter_ce),
			       .o_rdata(o_counter_rdata)
			       );
   
   // DUAL PORT BLOCK RAM TO COUNT NUMBER OF
   // ELEMENTS IN EACH CLUSTER
    bram_reducer #(
		  .C_WIDTH((SUM_WIDTH*DIMENSION)),
		  .C_LOG_DEPTH(bram_addr)
		  ) sum_1 (
			       .i_clk(clock),

			       .i_waddr(i_sum_waddr),
			       .i_wen(i_sum_wen),
			       .i_wdata(i_sum_wdata),

			       .i_raddr(i_sum_raddr),
			       .i_ce(i_sum_ce),
			       .o_rdata(o_sum_rdata)
			       );
  

   // DELAY THE VALID SIGNAL TO APPLY AS START SIGNAL OF REDUCER
   always @(posedge clock)
     begin
	if(!reset_n)
	  begin
	     i_KV_valid_delay <= 0;
	     i_KV_valid_delay_delay <= 1'b0;
	     
	  end
	else
	  begin
	     i_KV_valid_delay <= i_KV_valid;
	     i_KV_valid_delay_delay <= i_KV_valid_delay;
	  end
     
     end


   // DELAY THE MERGE READ SIGNALS TO RESET THEM TO ZERO
   always @ (posedge clock)
     begin
	if(!reset_n)
	  begin
//	     i_raddress_delay = 0;
//	     i_ce_delay = 0;
	     
	     i_counter_address_delay = 0;
	     i_ce_counter_delay = 0;
	     i_sum_address_delay = 0;
	     i_ce_sum_delay = 0;
	     
	  end
	else
	  begin
//	     i_raddress_delay  = i_raddress;
//	     i_ce_delay  = i_ce;
	     
	     i_counter_address_delay = i_counter_address;
	     i_ce_counter_delay = i_ce_counter;
	     i_sum_address_delay = i_sum_address;
	     i_ce_sum_delay = i_ce_sum;
	  end
     end

   // COUNT NUMBER OF PROCESSED DATA POINT BY THIS REDUCER
   always @(posedge clock)
     begin
	if(!reset_n || merge)
	  reduce_counter = 0;
	else if (reducer_done)
	  reduce_counter = reduce_counter + 1'b1;
	else
	  reduce_counter = reduce_counter;
     end

   
   // assigning the inputs to the sum bram
   // WRITING
   assign i_sum_waddr =  (current_state == MERGE) ?  i_sum_address_delay : sum_address1 ;
   assign i_sum_wen = (current_state == MERGE) ? i_ce_sum_delay : sum_we1 ;
   assign i_sum_wdata =  (current_state == MERGE) ? 0 : sum_d1 ;
   // READING
   assign i_sum_raddr = (current_state == MERGE) ? i_sum_address : sum_address0 ;
   assign i_sum_ce = (current_state == MERGE) ? i_ce_sum : sum_ce0;
   
 
   
   // assigning the inputs to the counter bram
   //WRITING
   assign i_counter_waddr = (current_state == MERGE) ?  i_counter_address_delay : counter_address1 ;
   assign i_counter_wen = (current_state == MERGE) ? i_ce_counter_delay : counter_we1 ;
   assign i_counter_wdata = (current_state == MERGE) ? 0 : counter_d1;
   //READING
   assign i_counter_raddr = (current_state == MERGE) ? i_counter_address : counter_address0 ;
   assign i_counter_ce = (current_state == MERGE) ? i_ce_counter : counter_ce0;


   // ASSIGN THE OUTPUTS
   assign o_sum_data = o_sum_rdata;
   assign o_counter_data = o_counter_rdata;

   assign o_reduce_counters = reduce_counter;
   


endmodule
