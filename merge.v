`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2015 12:25:38 PM
// Design Name: 
// Module Name: merge
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
//     
//   
//    -
//////////////////////////////////////////////////////////////////////////////////
module merge #(
               parameter integer INPUT_WIDTH= 256,
               parameter integer NUMBER_OF_REDUCERS = 8,
	       parameter integer PRECISION = 16,
	       parameter integer SUM_WIDTH = 64,
	       parameter integer CENTRE_WIDTH = 16,
               parameter integer DIMENSION = 4,
               parameter integer K = 10,
               parameter integer ADDR_BITS = 4, // log2(K)
	       parameter integer BRAM_BITS = 3

               )
   (
    clock, // clk signal for both
    reset_n, // reset signal for both
    i_start, // start signal for both
    i_sum_pts, //data from reducer for centre_update
    i_count_pts,
   // o_ce_reducers, // output to the reducer for centre_update
   // o_raddress_reducers, // address to the reducer for centre_update
    o_centre_wdata, // valid data outupt for both
    o_centre_address, // valid addr output for both
    o_centre_we, // valid singnal out both
    o_done, // done signal for both
    //    axis_data_in,
    //    axis_ready_out,
    i_fifo_data,
    i_fifo_empty,
    o_fifo_rden,
    i_init, //indicates if this is the initialization of the memory modules

    o_ce_counters,
    o_ce_sums,
    o_sum_address,
    o_counter_address
    );

   // INPUTS
   input 			 clock,reset_n, i_start;
   input [(NUMBER_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] i_sum_pts;  
   input [(NUMBER_OF_REDUCERS*32)-1 : 0 ] 		   i_count_pts;
   //   input [INPUT_WIDTH-1:0] 				   axis_data_in;
   input 						   i_init;
   input [(CENTRE_WIDTH*DIMENSION)-1:0] 		   i_fifo_data;
   input 						   i_fifo_empty;

   // OUTPUTS
  // output [NUMBER_OF_REDUCERS-1:0] 			   o_ce_reducers;
  // output [BRAM_BITS-1:0] 				   o_raddress_reducers; 
   output [(CENTRE_WIDTH*DIMENSION)-1:0] 		   o_centre_wdata;
   output [ADDR_BITS-1:0] 				   o_centre_address;
   output 						   o_centre_we;
   output 						   o_done;

   //   output 						   axis_ready_out;
   
   
   output 						   o_fifo_rden;
   
   output  [NUMBER_OF_REDUCERS-1:0] 			   o_ce_counters;
   output  [NUMBER_OF_REDUCERS-1:0] 			   o_ce_sums;
   output  [BRAM_BITS-1:0] 				   o_counter_address;
   output  [BRAM_BITS-1:0] 				   o_sum_address;
   
   
   // INTERNAL WIRES
   wire [(CENTRE_WIDTH*DIMENSION)-1:0] 			   mem_update_data_out;
   wire [ADDR_BITS-1:0] 				   mem_update_addr_out;
   wire 						   mem_update_valid_out;
   wire 						   mem_update_done_out;


   wire [(CENTRE_WIDTH*DIMENSION)-1:0] 			   centre_update_data_out;
   wire [ADDR_BITS-1:0] 				   centre_update_addr_out;
   wire 						   centre_update_valid_out;
   wire 						   centre_update_done_out;

   /*
    mem_update #(
    .INPUT_WIDTH(INPUT_WIDTH), // input from dma
    .ADDR_BITS(ADDR_BITS),
    .PRECISION(CENTRE_WIDTH), // with respect to the centres
    .DIMENSION(DIMENSION),
    //.OUTPUT_WIDTH = DIMENSION*PRECISION,
    //.MAX(INPUT_WIDTH/OUTPUT_WIDTH),
    .K(K)
    ) update_mem
    (
    .clk(clock),
    .reset_n(reset_n),
    .done(mem_update_done_out),
    .data_in(axis_data_in),
    .valid_in(i_start && i_init),
    .data_out(mem_update_data_out),
    .addr_out(mem_update_addr_out),
    .valid_out(mem_update_valid_out)
    //      .ready(axis_ready_out)
    );
    */

   

   mem_update #(

		.PRECISION(PRECISION),
		.CENTRE_WIDTH(CENTRE_WIDTH),
		.DIMENSION(DIMENSION),
		.K(K),
		.ADDR_BITS(ADDR_BITS)
		) update_mem
     (
      .clock(clock),
      .reset_n(reset_n),
      .i_fifo_data(i_fifo_data),
      .i_fifo_empty(i_fifo_empty),
      .i_init(i_init),
      .o_fifo_rden(o_fifo_rden),
      .o_done(mem_update_done_out),
      .o_mem_data(mem_update_data_out),
      .o_mem_addr(mem_update_addr_out),
      .o_mem_valid(mem_update_valid_out)
      
      );
   
   merger_wrapper #(
		    .NUMBER_OF_REDUCERS(NUMBER_OF_REDUCERS),
		    .CENTRE_WIDTH(CENTRE_WIDTH),
		    .SUM_WIDTH(SUM_WIDTH),
		    .DIMENSION(DIMENSION),
		    .K(K),
		    .ADDR_BITS(ADDR_BITS), // log2(K)
		    .BRAM_BITS(BRAM_BITS)

		    ) update_centre
     (
      .clock(clock),
      .reset_n(reset_n),
      .i_start(i_start && !i_init),
      .i_sum_pts(i_sum_pts),
      .i_count_pts(i_count_pts),
      //.o_ce_reducers(o_ce_reducers), // chip enable
      //.o_raddress_reducers(o_raddress_reducers), // next_addr (counter ) / NUM_OF_REDUCERS
      .o_centre_wdata(centre_update_data_out),
      .o_centre_address(centre_update_addr_out),
      .o_centre_we(centre_update_valid_out),
      .o_done(centre_update_done_out),

      .o_ce_counters(o_ce_counters),
      .o_ce_sums(o_ce_sums),
      .o_counter_address(o_counter_address),
      .o_sum_address(o_sum_address)
      
      

      );


   assign o_centre_wdata = i_init ? mem_update_data_out : centre_update_data_out;
   assign o_centre_address = i_init ? mem_update_addr_out : centre_update_addr_out;
   assign o_centre_we = i_init ? mem_update_valid_out : centre_update_valid_out;
   assign o_done = i_init ? mem_update_done_out : centre_update_done_out;


endmodule // merge
