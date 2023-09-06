`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ehsan Ghasemi
// 
// Create Date: 05/10/2015 11:13:35 AM
// Design Name: K_Means
// Module Name: Collect
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
//   C_M_AXIS_TDATA_WIDTH >= 64 bits for fixed_pt and 32bits for floating point
// Revision History:
//   June 28th:
//     In order to meet timing, add more pipelining stages in collect_v2 module.
//     The ce and address to the reducers have a pipeline stages. all the m_axis stages
//     are also registered.
//////////////////////////////////////////////////////////////////////////////////

module collect # (
		  parameter integer NUMBER_OF_REDUCERS = 8,
                  parameter integer CENTRE_WIDTH = 32,
                  parameter integer SUM_WIDTH = 64,
                  parameter integer DIMENSION = 4,
                  parameter integer K = 10,
                  parameter integer ADDR_BITS = 4,// log2(K-1)
                  parameter integer BRAM_BITS = 3,
                  parameter integer C_M_AXIS_TDATA_WIDTH = 32

		  )
   (
    clock,
    reset_n,

    i_start,
    i_sum_pts,
    i_count_pts,

    o_ce_counters,
    o_ce_sums,
    o_counter_address,
    o_sum_address,

   

    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tstrb,
    m_axis_tlast,
    m_axis_tready,

    o_done


    );

   //localparam READY = 1'b0, RUNNING = 1'b1;
   //reg 				    current_state, next_state;


   // INPUTS SIGNALS
   input 			    clock,reset_n; // enable is when !fifo_full
   input 			    i_start;
   input [(NUMBER_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] i_sum_pts;
   input [(NUMBER_OF_REDUCERS*32)-1 : 0 ] 		   i_count_pts;
   input wire 						   m_axis_tready;
   
   /* CHANGES FOR FLOATING_POINT */
   output [NUMBER_OF_REDUCERS-1:0] 			   o_ce_counters;
   output [NUMBER_OF_REDUCERS-1:0] 			   o_ce_sums;
   output [BRAM_BITS-1:0] 				   o_counter_address;
   output  [BRAM_BITS-1:0] 				   o_sum_address;

   output wire 						   m_axis_tvalid;
   output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] 		   m_axis_tdata;
   output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] 	   m_axis_tstrb;
   output wire 						   m_axis_tlast;
   
   output wire 						   o_done;


   generate
      if (C_M_AXIS_TDATA_WIDTH == SUM_WIDTH*DIMENSION)
	begin
	      collect_v1 #(

	     .NUMBER_OF_REDUCERS(NUMBER_OF_REDUCERS),
             .CENTRE_WIDTH(CENTRE_WIDTH),
             .SUM_WIDTH(SUM_WIDTH),
             .DIMENSION(DIMENSION),
             .K(K),
             .ADDR_BITS(ADDR_BITS),// log2(K-1)
             .BRAM_BITS(BRAM_BITS),
             .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH)
	     ) collect_inst (
	       .clock(clock),
	       .reset_n(reset_n),
	       .i_start(i_start),
	       .o_done(o_done),
	       .i_sum_pts(i_sum_pts),
	       .i_count_pts(i_count_pts),

	       .o_ce_counters(o_ce_counters),
	       .o_ce_sums(o_ce_sums),
	       .o_sum_address(o_sum_address),
	       .o_counter_address(o_counter_address),
	      
	       
	       .m_axis_tdata(m_axis_tdata),
	       .m_axis_tvalid(m_axis_tvalid),
	       .m_axis_tstrb(m_axis_tstrb),
	       .m_axis_tlast(m_axis_tlast),
	       .m_axis_tready(m_axis_tready)
	       
	       );
	end
      else
	begin
	      collect_v2 #(

	     .NUMBER_OF_REDUCERS(NUMBER_OF_REDUCERS),
             .CENTRE_WIDTH(CENTRE_WIDTH),
             .SUM_WIDTH(SUM_WIDTH),
             .DIMENSION(DIMENSION),
             .K(K),
             .ADDR_BITS(ADDR_BITS),// log2(K-1)
             .BRAM_BITS(BRAM_BITS),
             .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH)
	     ) collect_inst (
	       .clock(clock),
	       .reset_n(reset_n),
	       .i_start(i_start),
	       .o_done(o_done),
	       .i_sum_pts(i_sum_pts),
	       .i_count_pts(i_count_pts),

	       .o_ce_counters(o_ce_counters),
	       .o_ce_sums(o_ce_sums),
	       .o_sum_address(o_sum_address),
	       .o_counter_address(o_counter_address),
	      
	       
	       .m_axis_tdata(m_axis_tdata),
	       .m_axis_tvalid(m_axis_tvalid),
	       .m_axis_tstrb(m_axis_tstrb),
	       .m_axis_tlast(m_axis_tlast),
	       .m_axis_tready(m_axis_tready)
	       
	       );
	end 
      
   endgenerate  
endmodule // collcet


/*****************************************/
/*****************************************/
/*************** collect_v1 **************/
/*****************************************/
/*****************************************/

module collect_v1 # (
		     parameter integer NUMBER_OF_REDUCERS = 8,
                     parameter integer CENTRE_WIDTH = 32,
                     parameter integer SUM_WIDTH = 64,
                     parameter integer DIMENSION = 4,
                     parameter integer K = 10,
                     parameter integer ADDR_BITS = 4,// log2(K-1)
                     parameter integer BRAM_BITS = 3,
                     parameter integer C_M_AXIS_TDATA_WIDTH = 32

		     )
   (
    clock,
    reset_n,

    i_start,
    i_sum_pts,
    i_count_pts,

    o_ce_counters,
    o_ce_sums,
    o_counter_address,
    o_sum_address,

   

    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tstrb,
    m_axis_tlast,
    m_axis_tready,

    o_done


    );


   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction // clogb2

   localparam REDUCE_BITS = clogb2(NUMBER_OF_REDUCERS-1);
   localparam TOTAL_BITS = REDUCE_BITS+BRAM_BITS;
   localparam integer addr_bits = clogb2(K);
   localparam [1:0] IDLE = 2'b00, SUM_OUT = 2'b01, COUNT_OUT = 2'b10, COUNT_INIT = 2'b11;
   reg [1:0]				    current_state, next_state;


   // INPUTS SIGNALS
   input 			    clock,reset_n; // enable is when !fifo_full
   input 			    i_start;
   input [(NUMBER_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] i_sum_pts;
   input [(NUMBER_OF_REDUCERS*32)-1 : 0 ] 		   i_count_pts;
   input wire 						   m_axis_tready;
   
   /* CHANGES FOR FLOATING_POINT */
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_counters;
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_sums;
   output reg [BRAM_BITS-1:0] 				   o_counter_address;
   output reg [BRAM_BITS-1:0] 				   o_sum_address;

   output reg 						   m_axis_tvalid;
   output reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 		   m_axis_tdata;
   output reg [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] 		   m_axis_tstrb;
   output wire 						   m_axis_tlast;

   output reg 						   o_done;

  
   // INTERNAL WIRES
   reg [addr_bits-1:0] 					   counter;
   reg 							   counter_en;
   reg 							   sum_ce;
   reg 							   counter_ce;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_counter_reg;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_sum_reg;

      // INTERNAL REGISTERS
   reg [(SUM_WIDTH*DIMENSION)-1:0] 			   temp_sum;
   reg [31:0] 						   temp_count;

   integer 						   i;
   

   always @(*/*ads*/)
     begin
	case (current_state)
	  IDLE:
	    begin
	       if (i_start)
		 next_state = SUM_OUT;
	       else
		 next_state = IDLE;
	       
	    end
	  SUM_OUT:
	    begin
	       if(counter==K)
		 next_state = COUNT_INIT;
	       else
		 next_state = SUM_OUT;
	       
	    end
	  COUNT_INIT:
	    begin
	       next_state = COUNT_OUT;
	    end
	  COUNT_OUT:
	    begin
	       if (counter==K)
		 next_state = IDLE;
	       else
		 next_state = COUNT_OUT;
	    end
	endcase // case (current_state)
	
     end // always @ (*...
   

   always @ (posedge clock)
     begin
	if (!reset_n)
	  current_state <= IDLE;
	else
	  current_state <= next_state;

     end
   
   always @(*/*ads*/)
     begin
	m_axis_tvalid = 1'b0;
	m_axis_tstrb = 0;
	sum_ce = 1'b0;
	counter_en = 1'b0;
	counter_ce = 1'b0;
	o_done = 1'b0;
	
	case (current_state)
	  IDLE:
	    begin
	       if (i_start)
		 begin
		    counter_en = 1'b1;
		    sum_ce = 1'b1;
		 end
	    end
	  SUM_OUT:
	    begin
	       m_axis_tvalid = 1'b1;
	       m_axis_tstrb = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	       m_axis_tdata = temp_sum;
	       if (m_axis_tready)
		 begin
		    counter_en  = 1'b1;
		    if (counter < K)
		      sum_ce = 1'b1;
		 end
	    end // case: SUM_OUT
	  COUNT_INIT: // THIS STATE IS REQUIRED SINCE THE COUNTER VALUE IS RESET WHEN COUNTER == K IN PREVIOUS STATE
	    begin
	       counter_en = 1'b1;
	       counter_ce = 1'b1;
	    end
	  
	  COUNT_OUT:
	    begin
	       m_axis_tvalid = 1'b1;
	       m_axis_tstrb = {(4){1'b1}}; // 4 bytes are valid i.e. 32bits
	       m_axis_tdata = temp_count;
	       if (m_axis_tready)
		 begin
		    counter_en  = 1'b1;
		    if (counter < K)
		      counter_ce = 1'b1;
		 end
	       if (counter == K)
		 o_done = 1'b1;
	       
	    end
	endcase
     end // always @ (*...
   

   // REQUEST OUT REGISTER
   always @(posedge clock)
     begin
	if(!reset_n || counter == K)
	  counter <= 0;
	else if (counter_en)
	  counter <= counter + 1'b1;
	else
	  counter <= counter;
     end


   always @ (*/*asd*/)
     begin
	o_ce_counters = 0;
	o_ce_sums = 0;
	o_counter_address = 0;
	o_sum_address = 0;

	if (sum_ce)
	  begin
	     o_sum_address = counter / NUMBER_OF_REDUCERS;
	     o_ce_sums[counter % NUMBER_OF_REDUCERS] = 1'b1;
	   end
	if (counter_ce)
	  begin
	     o_counter_address = counter / NUMBER_OF_REDUCERS;
	     o_ce_counters[counter % NUMBER_OF_REDUCERS] = 1'b1;   
	  end
	
     end // always @ (*...


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
	     ce_sum_reg = 0;
	else if (sum_ce)
	     ce_sum_reg = o_ce_sums;
     end

    always @ (posedge clock)
     begin
	if (!reset_n)
	     ce_counter_reg = 0;
	else if (counter_ce)
	     ce_counter_reg = o_ce_counters;
     end
   
   
   assign m_axis_tlast = o_done;
   
   
   //assign m_axis_tdata = should either be i_sum_pts or the output of fifo
endmodule // collcet



/*****************************************/
/*****************************************/
/*************** collect_v2 **************/
/*****************************************/
/*****************************************/

module collect_v2 # (
		     parameter integer NUMBER_OF_REDUCERS = 8,
                     parameter integer CENTRE_WIDTH = 32,
                     parameter integer SUM_WIDTH = 64,
                     parameter integer DIMENSION = 4,
                     parameter integer K = 10,
                     parameter integer ADDR_BITS = 4,// log2(K-1)
                     parameter integer BRAM_BITS = 3,
                     parameter integer C_M_AXIS_TDATA_WIDTH = 32

		     )
   (
    clock,
    reset_n,

    i_start,
    i_sum_pts,
    i_count_pts,

    o_ce_counters,
    o_ce_sums,
    o_counter_address,
    o_sum_address,

   

    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tstrb,
    m_axis_tlast,
    m_axis_tready,
   
    o_done


    );



   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction // clogb2

   localparam REDUCE_BITS = clogb2(NUMBER_OF_REDUCERS-1);
   localparam TOTAL_BITS = REDUCE_BITS+BRAM_BITS;
   localparam integer addr_bits = clogb2(K);
   localparam integer width_multiple = (SUM_WIDTH*DIMENSION)/C_M_AXIS_TDATA_WIDTH;
   localparam integer data_bits = width_multiple*addr_bits;
   localparam integer last = width_multiple*K;
   
   localparam [2:0] IDLE = 3'b00, SUM_OUT = 3'b001, COUNT_OUT = 3'b010, DELAY_A = 3'b011, DELAY_B = 3'b101, DELAY_C = 3'b110  , COUNT_INIT = 3'b100;
   reg 	[2:0]			    current_state, next_state;

   // INPUTS SIGNALS
   input 			    clock,reset_n; // enable is when !fifo_full
   input 			    i_start;
   input [(NUMBER_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] i_sum_pts;
   input [(NUMBER_OF_REDUCERS*32)-1 : 0 ] 		   i_count_pts;

   input wire 						   m_axis_tready;
   
   /* CHANGES FOR FLOATING_POINT */
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_counters;
   output reg [NUMBER_OF_REDUCERS-1:0] 			   o_ce_sums;
   output reg [BRAM_BITS-1:0] 				   o_counter_address;
   output reg [BRAM_BITS-1:0] 				   o_sum_address;

   output reg 						   m_axis_tvalid;
   output reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 		   m_axis_tdata;
   output reg [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] 		   m_axis_tstrb;
   output reg 						   m_axis_tlast;
   
   output reg 						   o_done;

 
   // INTERNAL WIRES
   reg [data_bits-1:0] 					   counter;
   reg 							   counter_en;
   reg [addr_bits-1:0] 					   sum_addr;
   reg 							   addr_en;
   reg [addr_bits-1:0] 					   counter_addr;
   reg 							   counter_addr_en;
   
   reg 							   sum_ce;
   reg 							   counter_ce;
   
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_counter_reg;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_sum_reg;

      // INTERNAL REGISTERS
   reg [(SUM_WIDTH*DIMENSION)-1:0] 			   temp_sum;
   reg [31:0] 						   temp_count;

   reg [(SUM_WIDTH*DIMENSION)-1:0] 			   temp_sum_reg;
   reg [31:0] 						   temp_count_reg;


   reg 							   tvalid;
   reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 			   tdata;
   reg  [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] 		   tstrb;
   wire 						   tlast;
   
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_counters;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_sums;
   reg [BRAM_BITS-1:0] 					   counter_address;
   reg [BRAM_BITS-1:0] 					   sum_address;
   reg [NUMBER_OF_REDUCERS-1:0] 			   ce_sum_reg_delay;
   integer 						   i;

   always @(*/*ads*/)
     begin
	case (current_state)
	  IDLE:
	    begin
	       if (i_start)
		 next_state = DELAY_A;
	       else
		 next_state = IDLE;   
	    end
	  DELAY_A:
	    begin
	       next_state = DELAY_B;
	    end
	  DELAY_B:
	    begin
	       next_state = SUM_OUT;
	    end
	 /* DELAY_C:
	    begin
	       next_state = SUM_OUT;
	       
	    end
	  */
	  SUM_OUT:
	    begin
	       if (counter == last-1)
		 next_state = COUNT_INIT;
	       else
		 next_state = SUM_OUT;       
	    end
	  COUNT_INIT:
	    begin
	       next_state = COUNT_OUT;
	    end
	  COUNT_OUT:
	    begin
	       if (counter_addr == K)
		 next_state = IDLE;
	       else
		 next_state = COUNT_OUT;
	       
	    end
	  default:
	    next_state = IDLE;
	  
	endcase // case (current_state)
	
     end // always @ (*...
   
   always @ (posedge clock)
     begin
	if (!reset_n)
	  current_state <= IDLE;
	else
	  current_state <= next_state;

     end
   
   always @(*/*ads*/)
     begin
	tvalid = 1'b0;
	tstrb = 0;
	tdata = 0;
	sum_ce = 1'b0;
	counter_en = 1'b0;
	addr_en = 1'b0;
	counter_addr_en = 1'b0;
	counter_ce =1'b0;
	o_done = 1'b0;
	case (current_state)
	  IDLE:
	    begin
	       if (i_start)
		 begin
		    addr_en = 1'b1;
		    sum_ce = 1'b1;
		 end
	    end
	  DELAY_A:
	    begin
	       
	    end
	  SUM_OUT:
	    begin
	       tvalid = 1'b1;
	       tstrb = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	       
	       tdata = temp_sum_reg [( ((counter)%width_multiple+1)*C_M_AXIS_TDATA_WIDTH)-1 -:C_M_AXIS_TDATA_WIDTH];
	       if (m_axis_tready)
	       begin
	        counter_en  = 1'b1;
	        if ((counter+3)% width_multiple == 0) // counter+2
		  begin
		     addr_en = 1'b1;
		     sum_ce = 1'b1;
		  end
	       end
	    end // case: SUM_OUT
	  COUNT_INIT:
	    begin
	       counter_addr_en = 1'b1;
	       counter_ce = 1'b1;
	    end
	  COUNT_OUT:
	    begin
	       tvalid = 1'b1;
	       tstrb = {(4){1'b1}}; // 4 bytes are valid i.e. 32bits
	       tdata = temp_count;
	       if (m_axis_tready)
		 begin
		    counter_addr_en  = 1'b1;
		    if (counter_addr < K)
		      counter_ce = 1'b1;
		 end
	       if (counter_addr == K)
		 o_done = 1'b1;
	    end
	endcase // case (current_state)
	
     end // always @ (*...
   

   // REQUEST OUT REGISTER
   always @(posedge clock)
     begin
	if(!reset_n || counter == last-1)
	  counter <= 0;
	else if (counter_en)
	  counter <= counter + 1'b1;
	else
	  counter <= counter;
     end
   
   // REQUEST OUT REGISTER
   always @(posedge clock)
     begin
	if(!reset_n || counter == last - 1 )
	  sum_addr <= 0;
	else if (addr_en)
	  sum_addr <= sum_addr + 1'b1;
	else
	  sum_addr <= sum_addr;
     end
   
     // REQUEST OUT REGISTER
   always @(posedge clock)
     begin
	if(!reset_n || counter_addr == K)
	  counter_addr <= 0;
	else if (counter_addr_en)
	  counter_addr <= counter_addr + 1'b1;
	else
	  counter_addr <= counter_addr;
     end


   always @ (*/*asd*/)
     begin
	o_ce_counters = 0;
	ce_sums = 0;
	o_counter_address = 0;
	sum_address = 0;

	if (sum_ce)
	  begin
	     sum_address = sum_addr / NUMBER_OF_REDUCERS;
	     ce_sums[sum_addr % NUMBER_OF_REDUCERS] = 1'b1;
	  end
	
	if (counter_ce)
	  begin
	     o_counter_address = counter_addr / NUMBER_OF_REDUCERS;
	     o_ce_counters[counter_addr % NUMBER_OF_REDUCERS] = 1'b1;   
	  end
	 
	
     end // always @ (*...

   always @ (posedge clock)
     begin
	if (!reset_n)
	  begin
	     o_sum_address <= 0;
	     o_ce_sums <= 0;
	     
	  end
	else 
	  begin
	     o_sum_address <= sum_address;
	     o_ce_sums <= ce_sums;
	  end
     end
/*
   always @ (posedge clock)
     begin
	if (!reset_n)
	  begin
	     o_counter_address <= 0;
	     o_ce_counters <= 0;
	     
	  end
	else 
	  begin
	     o_counter_address <= sum_address;
	     o_ce_counters <= ce_sums;
	  end
     end
 */  
   // COMBINATIONAL BLOCK AS A MULTIPLEXER
   always @ (*)
     begin:mux_sum
	temp_sum = 0;
	for ( i = 0 ; i < NUMBER_OF_REDUCERS ; i = i + 1 )
	  begin
	     if (ce_sum_reg_delay[i] == 1'b1)
	       begin
		  temp_sum = i_sum_pts[((i+1)*DIMENSION*SUM_WIDTH)-1 -: DIMENSION*SUM_WIDTH];
	       end
	  end
     end // block: mux_sum

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
   

   // REGISTER THE OUTPUT OF MULTIPLEXERS TO GET THE SUM AND COUNT VALUES
   always @(posedge clock)
     begin
	if (!reset_n)
	  begin
	     temp_sum_reg <= 0;
	     temp_count_reg <= 0;   
	  end
	else
	  begin
	     temp_sum_reg <= temp_sum;
	     temp_count_reg <= temp_count;
	  end

     end // always @ (posedge clock)

   always @ (posedge clock)
     begin
	if (!reset_n)
	  ce_counter_reg = 0;
	else if (counter_ce)
	  ce_counter_reg = o_ce_counters;
     end
   
     // DELAY CE_REDUCER SIGNALS AS THE INPUT TO THE MUX ABOVE
   always @ (posedge clock)
     begin
	if (!reset_n)
	     ce_sum_reg <= 0;
	else if (sum_ce)
	     ce_sum_reg <= ce_sums;
     end

   
    // DELAY CE_REDUCER SIGNALS AS THE INPUT TO THE MUX ABOVE
   always @ (posedge clock)
     begin
	if (!reset_n)
	     ce_sum_reg_delay <= 0;
	else 
	     ce_sum_reg_delay <= ce_sum_reg;
     end

   always @ (posedge clock)
     begin
	if (!reset_n)
	  begin
	     m_axis_tvalid = 0;
	     m_axis_tdata = 0;
	     m_axis_tstrb = 0;    
 	     m_axis_tlast = 0;
	  end
	else
	  begin
	     m_axis_tvalid = tvalid;
	     m_axis_tdata = tdata;
	     m_axis_tstrb = tstrb;    
 	     m_axis_tlast = tlast;
	  end // else: !if(!reset_n)
     end // collect_v2

	
   //assign o_done = (counter == last-1);
   assign tlast = o_done;
   
   assign tlast = o_done;

   
endmodule // collcet

