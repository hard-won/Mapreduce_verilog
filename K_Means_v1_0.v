
`timescale 1 ns / 1 ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2015 02:01:58 PM
// Design Name: 
// Module Name: K_Means_v1
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
/*
// Change Log:
//   - 04/05/2015
//     -Testing the behaviour of the system with respect to change in num mappers:
//      for NUM_MAP = 1, The simulation would fail
//     -Problem:  wire [((NUM_OF_MAPPERS-1)*addr_bits)-1:0] 		  write_addr; 
//     -solution: ((NUM_OF_MAPPERS)*addr_bits) same for write_data
*/
//   - April 27
//     -Number of Mappers must be a multiple of 8
//     -Each partitioner handles 8 mappers
//   - May 18
//     -In an attempt to reduce routing wires, o_value_data is reduces to only
//      1 dimension rather than PRECISION*DIMENSION
//////////////////////////////////////////////////////////////////////////////////
module K_Means_v1_0 #
  (
   // Users to add parameters here
   parameter integer NUM_OF_MAPPERS = 16,
  // parameter integer MAP_PARTITION_RATIO = 8,
//   parameter integer NUM_OF_PARTITIONERS =  NUM_OF_MAPPERS/MAP_PARTITION_RATIO,
   parameter integer NUM_OF_REDUCERS = 4,
   parameter integer PRECISION = 16, // number of bits used for each dimension
   parameter integer DIMENSION = 4,
   parameter integer K = 5,
   parameter integer DATA_WIDTH = PRECISION*DIMENSION,
   parameter integer CENTRE_WIDTH = 16,
   parameter integer SUM_WIDTH = 64,
   parameter integer KEY_WIDTH = 16,
   parameter integer BRAM_DEPTH = 8,
   parameter integer ITERATIONS = 2,
   parameter integer NUM_PTS = 10,
   // User parameters ends
   // Do not modify the parameters beyond this line


   // Parameters of Axi Slave Bus Interface S_AXIS
   parameter integer C_S_AXIS_TDATA_WIDTH = 32,

   // Parameters of Axi Master Bus Interface M_AXIS
   parameter integer C_M_AXIS_TDATA_WIDTH = 64,
   parameter integer C_M_AXIS_START_COUNT = 32
   )
   (
    // Users to add ports here
    output wire 				 o_ready,

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S_AXIS
    input wire 					 s_axis_aclk,
    input wire 					 s_axis_aresetn,
    output wire 				 s_axis_tready,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] 	 s_axis_tdata,
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]  s_axis_tkeep,
    input wire 					 s_axis_tlast,
    input wire 					 s_axis_tvalid,

    // Ports of Axi Master Bus Interface M_AXIS
    input wire 					 m_axis_aclk,
    input wire 					 m_axis_aresetn,
    output wire 				 m_axis_tvalid,
    output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] 	 m_axis_tdata,
    output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tkeep,
    output wire 				 m_axis_tlast,
    input wire 					 m_axis_tready
    );
   
   /*
    // Instantiation of Axi Bus Interface S_AXIS
    K_Means_2_v1_0_S_AXIS # ( 
    .C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH)
    ) K_Means_2_v1_0_S_AXIS_inst (
    .S_AXIS_ACLK(s_axis_aclk),
    .S_AXIS_ARESETN(s_axis_aresetn),
    .S_AXIS_TREADY(s_axis_tready),
    .S_AXIS_TDATA(s_axis_tdata),
    .S_AXIS_TSTRB(s_axis_tstrb),
    .S_AXIS_TLAST(s_axis_tlast),
    .S_AXIS_TVALID(s_axis_tvalid)
    );

    // Instantiation of Axi Bus Interface M_AXIS
    K_Means_2_v1_0_M_AXIS # ( 
    .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
    .C_M_START_COUNT(C_M_AXIS_START_COUNT)
    ) K_Means_2_v1_0_M_AXIS_inst (
    .M_AXIS_ACLK(m_axis_aclk),
    .M_AXIS_ARESETN(m_axis_aresetn),
    .M_AXIS_TVALID(m_axis_tvalid),
    .M_AXIS_TDATA(m_axis_tdata),
    .M_AXIS_TSTRB(m_axis_tstrb),
    .M_AXIS_TLAST(m_axis_tlast),
    .M_AXIS_TREADY(m_axis_tready)
    );
    */
   function integer clogb2 (input integer bit_depth);
      begin
         for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
           bit_depth = bit_depth >> 1;
      end
   endfunction
   
   // FIND THE LOG2 OF THE DEPTH OF THE RAM        
   localparam addr_bits = clogb2(K-1);
   localparam map_bits = clogb2(NUM_OF_MAPPERS);
   localparam bram_bits = clogb2(BRAM_DEPTH-1);
   localparam integer MAP_PARTITION_RATIO = 8;
   localparam integer NUM_OF_PARTITIONERS = NUM_OF_MAPPERS/MAP_PARTITION_RATIO; 
   
   //localparam NUM_OF_PARTITIONERS = NUM_OF_MAPPERS;
   // User logic ends
   reg [C_S_AXIS_TDATA_WIDTH-1:0] data_in; // data coming in from the DMA
   
   // INTERNAL WIRES FOR MERGE BLOCK
   wire 			  merge_done_out, merge_valid_in;
   wire [addr_bits-1:0] 	  merge_addr_out;
   wire [(DIMENSION*CENTRE_WIDTH)-1:0] merge_data_out;
   wire 			       merge_valid_out;
   wire 			       merge_ready_out;
   wire 			       init_mem;
   wire 			       o_map;
   wire 			       merge_fifo_rden;
   
   
   
   // INTERNAL WIRE FOR INPUT_CONVERTER (IC) BLOCK
   
   wire 			       ic_valid;
   wire 			       ic_ready;
   wire 			       ic_tlast;
//   wire [63:0] 			       NUM_PTS;
   
   
   // INTERNAL WIRES FOR DATA INPUT FIFO
   
   wire [(DIMENSION*PRECISION)-1:0]    fifo_data_in;
   wire [(DIMENSION*PRECISION)-1:0]    fifo_data_out;
   reg [(DIMENSION*PRECISION)-1:0]     fifo_data_out_reg;
   wire 			       fifo_wren;
   wire 			       fifo_rden;
   wire 			       fifo_empty;
   wire 			       fifo_full;
   
   // INTERNAL WIRES FOR DATA_CONTROLLER BLOCK
   wire 			       dc_fifo_empty;
   wire [NUM_OF_MAPPERS-1:0] 	       request;
   wire [NUM_OF_MAPPERS-1:0] 	       grant;
   wire [NUM_OF_MAPPERS-1:0] 	       queued;
   
   
   // CONTROL SIGNALS FROM FIFOS
   wire [NUM_OF_MAPPERS-1:0] 	       fifo_val_full;
   wire [(NUM_OF_MAPPERS*DIMENSION*PRECISION)-1 :0] fifo_val_data_out;
   wire [NUM_OF_MAPPERS-1:0] 			    fifo_val_valid_out;
   
   wire [NUM_OF_MAPPERS-1:0] 			    fifo_key_full;
   wire [(NUM_OF_MAPPERS*16)-1 :0] 		    fifo_key_data_out;
   wire [NUM_OF_MAPPERS-1:0] 			    fifo_key_valid_out;
   
   genvar 					    i,j;
   //reg [map_bits-1:0] write_data [(CENTRE_WIDTH*DIMENSION)-1:0];
   //reg [map_bits-1:0] write_addr [addr_bits-1:0];
   wire [((NUM_OF_MAPPERS)*CENTRE_WIDTH*DIMENSION)-1:0] write_data;
   wire [((NUM_OF_MAPPERS)*addr_bits)-1:0] 		write_addr; 
   
   wire [NUM_OF_MAPPERS-1:0] 				write_en;
   wire [NUM_OF_MAPPERS-1:0] 				write_done;
   
   
   // SIGNALS VALUE FIFO IN
   wire [(NUM_OF_MAPPERS*DIMENSION*PRECISION)-1:0] i_fifo_val_data;
   wire [NUM_OF_MAPPERS-1:0] 			i_fifo_val_empty;
   wire [NUM_OF_MAPPERS-1:0] 			o_fifo_val_rden;
   
   // SIGNALS KEY FIFO IN
   wire [(NUM_OF_MAPPERS*16)-1:0] 		i_fifo_key_data;
   wire [NUM_OF_MAPPERS-1:0] 			i_fifo_key_empty;
   wire [NUM_OF_MAPPERS-1:0] 			o_fifo_key_rden;
   
   
   
   // PARTITION BLOCK SIGNALS
   wire [(NUM_OF_PARTITIONERS*PRECISION)-1:0] o_value_data;
   wire [(NUM_OF_PARTITIONERS*KEY_WIDTH)-1:0] 		o_mem_index;
   wire [(NUM_OF_PARTITIONERS*NUM_OF_REDUCERS)-1:0] 	o_request;
   
   // REDUCE_ARBITER BLOCK SIGNALS
   
   wire [(NUM_OF_REDUCERS*NUM_OF_PARTITIONERS)-1:0] 	o_acknowledged; // one cycle latency of grant
   wire [NUM_OF_REDUCERS-1:0] 				o_KV_valid; // input to start reducer
   wire [(NUM_OF_REDUCERS*PRECISION*DIMENSION)-1:0] 	o_value_data_out;
   wire [(NUM_OF_REDUCERS*KEY_WIDTH)-1:0] 		o_key_data_out;
   
   // REDUCE BLOCK SIGNALS
   wire [NUM_OF_REDUCERS-1:0] 				i_reduce_en;
   //wire [NUM_OF_REDUCERS-1:0] 				o_ce_reducers;
   wire [(NUM_OF_REDUCERS*SUM_WIDTH*DIMENSION)-1 : 0 ] 	o_sum_pts;
   wire [(NUM_OF_REDUCERS*32)-1 : 0 ] 			o_count_pts;
   //wire [bram_bits-1:0] 				o_raddress_reducers;
   wire [(NUM_OF_REDUCERS*32)-1:0] 			o_reduce_counters;

   wire [bram_bits-1:0] 				o_counter_address;
   wire [NUM_OF_REDUCERS-1:0] 				o_ce_counter;
   wire [bram_bits-1:0] 				o_sum_address;
   wire [NUM_OF_REDUCERS-1:0] 				o_ce_sum;
   
   // ACK BLOCK
   wire [(NUM_OF_PARTITIONERS*NUM_OF_REDUCERS)-1:0] 	i_request;   
   wire [NUM_OF_PARTITIONERS-1:0] 			o_ack;
   
   
   // WRITE_BACK BLOCK SIGNALS
   wire 						o_write_back_start;
   wire 						i_write_back_done;
   
   wire [(CENTRE_WIDTH*DIMENSION)-1:0] 			centre_read_data;
   wire [addr_bits-1:0] 				centre_read_address;
   wire 						centre_ce;
   
   
   wire 						sum_accum_done, sum_accum_reset;
   
   
   always @(posedge s_axis_aclk )
     begin
        if (!s_axis_aresetn)
          data_in <= {C_S_AXIS_TDATA_WIDTH{1'b0}};
        else if (s_axis_tready && s_axis_tvalid)
          data_in <= s_axis_tdata;
        else
          data_in <= data_in;
     end


   
   Scheduler  #(
		.DIMENSION(DIMENSION),
		.PRECISION(PRECISION),
		.DATA_WIDTH(DATA_WIDTH),
		.K(K),
		.ITERATIONS(ITERATIONS)
		//.ADDR_BITS(addr_bits)
		) fsm (
                       .clk(s_axis_aclk),
                       .reset_n(s_axis_aresetn),
                       //.idle(),
                       //.ready(),
                       // .start(),
                       .o_init_mem(init_mem),
		       .o_map(o_map),
                       .i_mem_update_done(merge_done_out),
                       .i_mem_map_done(write_done[NUM_OF_MAPPERS-1]),
                       //.i_mem_update_ready(merge_ready_out),
                       .o_mem_update_valid(merge_valid_in),
                       
                       
		       
                       .i_ic_ready(ic_ready),
                       .o_ic_valid(ic_valid),
                       .o_ic_tlast(ic_tlast),
                       
                       .o_ready(o_ready),
                       //.read_next(),
                       .S_AXIS_TVALID(s_axis_tvalid),
                       .S_AXIS_TLAST(s_axis_tlast),
                       .S_AXIS_TREADY(s_axis_tready),
		       
                       .i_sum_accum_done(sum_accum_done),
                       .o_sum_accum_reset(sum_accum_reset),
		       
                       .i_write_back_done(i_write_back_done),
                       .o_write_back_start(o_write_back_start)
                       
                       
                       );
   
   // INPUT_CONVERTER INSTANTIATION
   // THIS MODULE CONVERTS THE 256-bit S_AXIS_DATA
   // INPUT WORD TO 256-bit OUTPUT WORD OR HIGHER
   input_converter #(
      
                     .INPUT_WIDTH(C_S_AXIS_TDATA_WIDTH),
                     .PRECISION(PRECISION),
                     .DIMENSION(DIMENSION)//,
      
                     ) i_c (
			    .clk(s_axis_aclk),
			    .reset_n(s_axis_aresetn),
			    .i_fifo_full(fifo_full),
			     /***NEW***/
			    .i_map(o_map),
			    .i_res(sum_accum_reset),
			    .s_axis_tdata(s_axis_tdata),
			    .s_axis_tlast(ic_tlast),
			    .s_axis_tvalid(ic_valid),
			    .s_axis_tready(ic_ready),
			    .o_fifo_data(fifo_data_in),
			    .o_fifo_write(fifo_wren),
			    /***NEW***/
			    .NUM_PTS(/*NUM_PTS*/)
			    
			    );
   
   
   // FIFO DEFINITION
   // THE INPUT TO THIS FIFO IS INPUT_COVERTER WHICH CONVERTS
   // THE WIDTH OF AXI_DATA_INPUT TO APPROPRIATE WIDTH AND
   // PUSH THE NEW DATA POINT IN THE FIFO FOR PROCESSING 
   fifo # (
           .C_WIDTH(PRECISION*DIMENSION),
           .C_LOG_FIFO_DEPTH(5)
      
           ) ff( 
		 .clk(s_axis_aclk), 
		 .rst(!s_axis_aresetn), 
		 .buf_in(fifo_data_in), 
		 .buf_out(fifo_data_out), 
		 .wr_en(fifo_wren), 
		 .rd_en(fifo_rden), 
		 .buf_empty(fifo_empty), 
		 .buf_full(fifo_full), 
		 .fifo_counter() 
		 );

   
    always @(posedge s_axis_aclk )
     begin
        if (!s_axis_aresetn)
          fifo_data_out_reg <= 0;
	else
          fifo_data_out_reg <= fifo_data_out;
     end
   // read enable is high if there is valid data in both data and dc fifo
   //assign fifo_rden = !fifo_empty && !dc_fifo_empty;
   assign fifo_rden = init_mem?  merge_fifo_rden : (!fifo_empty && !dc_fifo_empty && o_map);
   
   // DATA_CONTROLLER INSTANTIATION
   // THIS BLOCK MONITORS DATA TRAFFIC
   // SCHEDULE IDLE MAPPERS TO PROCESS IF THERE ARE 
   // ANY VALID DATA INPUT AVAILABLE
   data_controller #(
                     .NUM_OF_MAPPERS(NUM_OF_MAPPERS)
      
                     ) dc (
			   .clock(s_axis_aclk),
			   .reset_n(s_axis_aresetn),
			   .fifo_re(o_map & fifo_rden),
			   .request(request),
			   .grant(grant),
			   .queued(queued),
			   .fifo_empty(dc_fifo_empty)
			   );
   
   
   // GENERATE BLOCK FOR N MAPPERS
   generate
      for (i = 0 ; i < NUM_OF_MAPPERS; i = i + 1 )
        begin: map
           if (i == 0)
             begin
                map  #(
                       .DIMENSION(DIMENSION),
                       .PRECISION(PRECISION),
                       .CENTRE_WIDTH(CENTRE_WIDTH),
                       .DATA_WIDTH(DATA_WIDTH),
                       .K(K),
                       .ADDR_BITS(addr_bits)
                       ) mapper (
				 .clock(s_axis_aclk),
				 .reset_n(s_axis_aresetn),
				 .write_addr_in(merge_addr_out),
				 .write_data_in(merge_data_out),
				 .we_in(merge_valid_out),
				 .write_done_in(merge_done_out),
				 .write_addr_out(write_addr[((i+1)*addr_bits)-1-:addr_bits]),
				 .write_data_out(write_data[((i+1)*DIMENSION*CENTRE_WIDTH)-1 -: DIMENSION*CENTRE_WIDTH]),
				 .we_out(write_en[i]),
				 .write_done_out(write_done[i]),
				 //CONTROL SIGNALS FROM DATA CONTROLLER
				 .grant(grant[i]),
				 .request(request[i]),
				 .queued(queued[i]),
				 // DATA INPUT
				 .value_data_in(fifo_data_out_reg),
				 
				 // CONTROL SIGNALS FROM FIFOS
				 .fifo_val_full(fifo_val_full[i]),
				 .fifo_val_data_out(fifo_val_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]/*fifo_val_data_out*/),
				 .fifo_val_valid_out(fifo_val_valid_out[i]),
				 .fifo_key_full(fifo_key_full[i]),
				 .fifo_key_data_out(fifo_key_data_out[((i+1)*16)-1-:16]),
				 .fifo_key_valid_out(fifo_key_valid_out[i])
				 
				 );        
             end
           else if ( i == NUM_OF_MAPPERS-1)
             begin
		map  #(
                       .DIMENSION(DIMENSION),
                       .PRECISION(PRECISION),
                       .CENTRE_WIDTH(CENTRE_WIDTH),
                       .DATA_WIDTH(DATA_WIDTH),
                       .K(K),
                       .ADDR_BITS(addr_bits)
                       ) mapper (
				 .clock(s_axis_aclk),
				 .reset_n(s_axis_aresetn),
				 .write_addr_in(write_addr[((i)*addr_bits)-1-:addr_bits]),
				 .write_data_in(write_data[((i)*DIMENSION*CENTRE_WIDTH)-1 -: DIMENSION*CENTRE_WIDTH]),
				 .we_in(write_en[i-1]),
				 .write_done_in(write_done[i-1]),
				 .write_addr_out(),
				 .write_data_out(),
				 .we_out(write_en[i]),
				 .write_done_out(write_done[i]),
				 //CONTROL SIGNALS FROM DATA CONTROLLER
				 .grant(grant[i]),
				 .request(request[i]),
				 .queued(queued[i]),
				 // DATA INPUT
				 .value_data_in(fifo_data_out_reg),
				 
				 // CONTROL SIGNALS FROM FIFOS
				 .fifo_val_full(fifo_val_full[i]),
				 .fifo_val_data_out(fifo_val_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]/*fifo_val_data_out*/),
				 .fifo_val_valid_out(fifo_val_valid_out[i]),
				 .fifo_key_full(fifo_key_full[i]),
				 .fifo_key_data_out(fifo_key_data_out[((i+1)*16)-1-:16]),
				 .fifo_key_valid_out(fifo_key_valid_out[i])
				 );        
             end
           
           else
             begin
                map  #(
                       .DIMENSION(DIMENSION),
                       .PRECISION(PRECISION),
                       .CENTRE_WIDTH(CENTRE_WIDTH),
                       .DATA_WIDTH(DATA_WIDTH),
                       .K(K),
                       .ADDR_BITS(addr_bits)
                       ) mapper (
				 .clock(s_axis_aclk),
				 .reset_n(s_axis_aresetn),
				 .write_addr_in(write_addr[((i)*addr_bits)-1-:addr_bits]),
				 .write_data_in(write_data[((i)*DIMENSION*CENTRE_WIDTH)-1 -: DIMENSION*CENTRE_WIDTH]),
				 .we_in(write_en[i-1]),
				 .write_done_in(write_done[i-1]),
				 .write_addr_out(write_addr[((i+1)*addr_bits)-1-:addr_bits]),
				 .write_data_out(write_data[((i+1)*DIMENSION*CENTRE_WIDTH)-1 -: DIMENSION*CENTRE_WIDTH]),
				 .we_out(write_en[i]),
				 .write_done_out(write_done[i]),
				 //CONTROL SIGNALS FROM DATA CONTROLLER
				 .grant(grant[i]),
				 .request(request[i]),
				 .queued(queued[i]),
				 // DATA INPUT
				 .value_data_in(fifo_data_out_reg),
				 
				 // CONTROL SIGNALS FROM FIFOS
				 .fifo_val_full(fifo_val_full[i]),
				 .fifo_val_data_out(fifo_val_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]/*fifo_val_data_out*/),
				 .fifo_val_valid_out(fifo_val_valid_out[i]),
				 
				 .fifo_key_full(fifo_key_full[i]),
				 .fifo_key_data_out(fifo_key_data_out[((i+1)*16)-1-:16]),
				 .fifo_key_valid_out(fifo_key_valid_out[i])
				 
				 );        
             end
        end
   endgenerate
   
   
   // GENERATE BLOCK FOR CREATING  FIFO FOR MAPPER KEY VALUE OUPUT
   // THESE ARE FEED INTO THE PARTITIONER AND AFTER THE REDUCER
   generate
      for (i = 0 ; i < NUM_OF_MAPPERS; i = i + 1 )
        begin: fifo
           fifo # (
		   .C_WIDTH(16),
		   .C_LOG_FIFO_DEPTH(5)
              
		   ) key( 
			  .clk(s_axis_aclk), 
			  .rst(!s_axis_aresetn), 
			  .buf_in(fifo_key_data_out[((i+1)*KEY_WIDTH)-1-:KEY_WIDTH]), 
			  .buf_out( i_fifo_key_data[((i+1)*KEY_WIDTH)-1-:KEY_WIDTH]), 
			  .wr_en(fifo_key_valid_out[i]), 
			  .rd_en(o_fifo_key_rden[i]), 
			  .buf_empty(i_fifo_key_empty[i]), 
			  .buf_full(fifo_key_full[i]), 
			  .fifo_counter() 
			  );
           fifo # (
		   .C_WIDTH(PRECISION*DIMENSION),
		   .C_LOG_FIFO_DEPTH(5)
              
		   ) value ( 
			     .clk(s_axis_aclk), 
			     .rst(!s_axis_aresetn), 
			     .buf_in(fifo_val_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]), 
			     .buf_out( i_fifo_val_data[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]), 
			     .wr_en(fifo_val_valid_out[i]), 
			     .rd_en( o_fifo_val_rden[i]), 
			     .buf_empty( i_fifo_val_empty[i]), 
			     .buf_full(fifo_val_full[i]), 
			     .fifo_counter() 
			     );
           
	end
      
   endgenerate
   
   // GENERATE BLOCK FOR PARTITIONERS
   
   generate 
      for ( i = 0 ; i < NUM_OF_PARTITIONERS; i = i + 1 )
	begin: partition
           
           partition #(
                       //     .NUM_OF_PARTITIONERS = ,
                       .NUM_OF_REDUCERS(NUM_OF_REDUCERS),
                       .PRECISION(PRECISION),
                       .DIMENSION (DIMENSION),
		       .NUM_OF_MAPPERS(MAP_PARTITION_RATIO)
              
                       )par(
			    .clock(s_axis_aclk),
			    .reset_n(s_axis_aresetn),
			    
			    .i_fifo_val_data(i_fifo_val_data[((i+1)*DIMENSION*PRECISION*MAP_PARTITION_RATIO)-1-:DIMENSION*PRECISION*MAP_PARTITION_RATIO]),
			    .i_fifo_val_empty(i_fifo_val_empty[((i+1)*MAP_PARTITION_RATIO)-1-:MAP_PARTITION_RATIO]),
			    .o_fifo_val_rden(o_fifo_val_rden[((i+1)*MAP_PARTITION_RATIO)-1-:MAP_PARTITION_RATIO]),
			    
			    .i_fifo_key_data(i_fifo_key_data[((i+1)*KEY_WIDTH*MAP_PARTITION_RATIO)-1-:KEY_WIDTH*MAP_PARTITION_RATIO]),
			    .i_fifo_key_empty(i_fifo_key_empty[((i+1)*MAP_PARTITION_RATIO)-1-:MAP_PARTITION_RATIO]),
			    .o_fifo_key_rden(o_fifo_key_rden[((i+1)*MAP_PARTITION_RATIO)-1-:MAP_PARTITION_RATIO]),
			    
			    .i_acknowledged(o_ack[i]),
			    .o_request(o_request[((i+1)*NUM_OF_REDUCERS)-1-:NUM_OF_REDUCERS]),
			    
			    .o_value_data(o_value_data[((i+1)/**DIMENSION*/*PRECISION)-1-:/*DIMENSION**/PRECISION]),
			    .o_mem_index(o_mem_index[((i+1)*KEY_WIDTH)-1-:KEY_WIDTH])
			    
			    
			    );
	end // block: partition
   endgenerate
   
   // ACKNOWLEDGEMENT BLOCK
   // THIS BLOCK TAKES ALL THE ACKNOWLEDGEMENT SIGNALS FROM ALL THE REDUCERS
   // AND COMBINES RE-ROUTES THEM TO THE CORRECT PARTITIONER
   acknowledgement #(
                     .NUM_OF_REDUCERS(NUM_OF_REDUCERS),
                     .NUM_OF_PARTITIONERS(NUM_OF_PARTITIONERS)
      
                     ) ack (
			    .clock(s_axis_aclk),
			    .reset_n(s_axis_aresetn),
			    
			    .i_ack(o_acknowledged),
			    .o_ack(o_ack)
			    );
   
   
   
   // REARRANGE THE REQUEST SIGNALS FROM PARTITIONER TO FEED TO THE REDUCE ARBITERS
   // PUTS THE ACKNOWLEDGEMENT FOR EACH REDUCER COMING FROM DIFFERENT PARTITIONERS
   // CONSECUTIVELY
   generate
      for ( i = 0 ; i < NUM_OF_REDUCERS; i = i + 1 )
	begin:routing
           for ( j = 0 ; j < NUM_OF_PARTITIONERS; j = j + 1 )
             begin
		assign i_request[(i*NUM_OF_PARTITIONERS)+j] = o_request[(j*NUM_OF_REDUCERS)+i];
             end
           
	end
   endgenerate
   
   // GENERATE BLOCK FOR REDUCE ARBITER
   // THESE ARBITERS ARBITERATE THE REQUEST TO EACH REDUCER
   generate 
      for ( i = 0 ; i < NUM_OF_REDUCERS; i = i + 1 )
	begin: arbiter
           reduce_arbiter #(
			    .NUM_OF_PARTITIONERS(NUM_OF_PARTITIONERS),
			    .PRECISION(PRECISION),
			    .DIMENSION(DIMENSION)
              
			    )_reduce(
				     .clock(s_axis_aclk),
				     .reset_n(s_axis_aresetn),
				     .i_request(i_request[((i+1)*NUM_OF_PARTITIONERS)-1-:NUM_OF_PARTITIONERS]),
				     .i_reduce_en(i_reduce_en[i]),
				     .i_value_data_in(o_value_data),
				     .i_key_data_in(o_mem_index),
				     
				     .o_acknowledged(o_acknowledged[((i+1)*NUM_OF_PARTITIONERS)-1-:NUM_OF_PARTITIONERS]), // specify the request is acknowledged
				     .o_value_data_out(o_value_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]),
				     .o_key_data_out(o_key_data_out[((i+1)*KEY_WIDTH)-1-:KEY_WIDTH]),
				     .o_KV_valid(o_KV_valid[i])
				     );
	end // block: arbiter
      
      
   endgenerate
   
   
   // GENERATE BLOCK FOR REDUCERS
   generate
      for ( i = 0 ; i < NUM_OF_REDUCERS; i = i + 1 )
	begin: reduce
           reduce #(
		    .DIMENSION(DIMENSION),
		    .PRECISION(PRECISION),
		    .SUM_WIDTH(SUM_WIDTH),
		    .ADDR_BITS(addr_bits), // bits required for number of cluster centres
		    .BRAM_DEPTH(BRAM_DEPTH)
              
		    ) red  (
			    .clock(s_axis_aclk),
			    .reset_n(s_axis_aresetn),
			    .merge(merge_valid_in && !init_mem), // send by the scheduler
			    //*** BUG FIX***//
			    .merge_done(i_write_back_done), // restart for next iteration
			    
			    //.i_raddress(o_raddress_reducers),
			    //.i_ce(o_ce_reducers[i]),
			    .i_counter_address(o_counter_address),
			    .i_sum_address(o_sum_address),
			    .i_ce_sum(o_ce_sum[i]),
			    .i_ce_counter(o_ce_counter[i]),
			    .o_sum_data(o_sum_pts[((i+1)*DIMENSION*SUM_WIDTH)-1 -: DIMENSION*SUM_WIDTH]),
			    .o_counter_data(o_count_pts[((i+1)*32)-1 -: 32]),
			    .o_reduce_counters(o_reduce_counters[((i+1)*32)-1-:32]),
			    
			    .i_value_data(o_value_data_out[((i+1)*DIMENSION*PRECISION)-1-:DIMENSION*PRECISION]),
			    .i_key_data(o_key_data_out[((i+1)*KEY_WIDTH)-1-:KEY_WIDTH]),
			    .i_KV_valid(o_KV_valid[i]),
			    .o_reducer_ready(i_reduce_en[i])
			    
			    );
	end // block: reduce
   endgenerate
   
   
   merge #(
           .INPUT_WIDTH(C_S_AXIS_TDATA_WIDTH), // input from dma
           .ADDR_BITS(addr_bits),
           .SUM_WIDTH(SUM_WIDTH),
	   .PRECISION(PRECISION),
           .CENTRE_WIDTH(CENTRE_WIDTH), // with respect to the centres
           .DIMENSION(DIMENSION),
           .NUMBER_OF_REDUCERS(NUM_OF_REDUCERS),
           .K(K),
           .BRAM_BITS(bram_bits)
           //.OUTPUT_WIDTH = DIMENSION*PRECISION,
           //.MAX(INPUT_WIDTH/OUTPUT_WIDTH),
           ) merger
     (
      .clock(s_axis_aclk),
      .reset_n(s_axis_aresetn),
      .i_start(merge_valid_in),
      .i_sum_pts(o_sum_pts),
      .i_count_pts(o_count_pts),
     // .o_ce_reducers(o_ce_reducers),
     // .o_raddress_reducers(o_raddress_reducers),
      .o_centre_wdata(merge_data_out),
      .o_centre_address(merge_addr_out),
      .o_centre_we(merge_valid_out),
      .o_done(merge_done_out),
//      .axis_data_in(s_axis_tdata),
//      .axis_ready_out(merge_ready_out),
      .i_fifo_data(fifo_data_out),
      .i_fifo_empty(fifo_empty),
      .o_fifo_rden(merge_fifo_rden),
      .i_init(init_mem),

      .o_ce_counters(/*o_ce_counter*/),
      .o_ce_sums(/*o_ce_sum*/),
      .o_sum_address(/*o_sum_address*/),
      .o_counter_address(/*o_counter_address*/)
      
      );
   
   
   /***NEW***/
   accumulator # (
		  .NUM_OF_REDUCERS(NUM_OF_REDUCERS),
		  //.K(K)
		  .NUM_PTS(NUM_PTS)
		  ) accum (
			   .clock(s_axis_aclk),
			   .reset_n(s_axis_aresetn),
			   .i_reduce_counters(o_reduce_counters),
			   .i_res(sum_accum_reset),
			   //.i_ready(m_axis_tready),
			   .o_done(sum_accum_done)
			   /***NEW***/
			   //.NUM_PTS(NUM_PTS)
			   );
   
   
   /*
   write_back  #(
		 .NUM_OF_REDUCERS(NUM_OF_REDUCERS),
		 .K(K),
		 .CENTRE_WIDTH(CENTRE_WIDTH),
		 .PRECISION(PRECISION),
		 .DIMENSION(DIMENSION),
		 .ADDR_BITS(addr_bits),
		 .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH)
      
		 ) w_b (
			.clock(s_axis_aclk),
			.reset_n(s_axis_aresetn),
			
			.i_start(o_write_back_start),
			.o_done(i_write_back_done),
			
			.i_centre_read_data(centre_read_data),
			.o_centre_ce(centre_ce),
			.o_centre_read_address(centre_read_address),
			
			.m_axis_tdata(m_axis_tdata),
			.m_axis_tvalid(m_axis_tvalid),
			.m_axis_tstrb(m_axis_tkeep),
			.m_axis_tlast(m_axis_tlast),
			.m_axis_tready(m_axis_tready)
			
			);
    */
   collect #(

	     .NUMBER_OF_REDUCERS(NUM_OF_REDUCERS),
             .CENTRE_WIDTH(CENTRE_WIDTH),
             .SUM_WIDTH(SUM_WIDTH),
             .DIMENSION(DIMENSION),
             .K(K),
             .ADDR_BITS(addr_bits),// log2(K-1)
             .BRAM_BITS(bram_bits),
             .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH)
	     ) collect_inst (
	       .clock(s_axis_aclk),
	       .reset_n(s_axis_aresetn),
	       .i_start(o_write_back_start),
	       .o_done(i_write_back_done),
	       .i_sum_pts(o_sum_pts),
	       .i_count_pts(o_count_pts),

	       .o_ce_counters(o_ce_counter),
	       .o_ce_sums(o_ce_sum),
	       .o_sum_address(o_sum_address),
	       .o_counter_address(o_counter_address),
	      
	       
	       .m_axis_tdata(m_axis_tdata),
	       .m_axis_tvalid(m_axis_tvalid),
	       .m_axis_tstrb(m_axis_tkeep),
	       .m_axis_tlast(m_axis_tlast),
	       .m_axis_tready(m_axis_tready)
	       
	       );
   
   
   // THE MASTER RAM WHERE GETS UPDATED AFTER EACH K-MEANS ITERATION
   bram_mapper # (
		  .C_WIDTH(DIMENSION*CENTRE_WIDTH),
		  .C_LOG_DEPTH(addr_bits)
		  ) master_ram (
				.i_clk(s_axis_aclk),
				.i_waddr(merge_addr_out),
				.i_wdata(merge_data_out),
				.i_wen(merge_valid_out),
				.i_raddr(centre_read_address),
				.o_rdata(centre_read_data),
				.i_ce(centre_ce)
				);
   
   // User logic ends
endmodule
