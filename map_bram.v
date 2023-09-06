`timescale 1 ns / 100 ps
////////////////////////////////////////////////////////////////////////////////
// bram.v
// 
// 
// Ehsan Ghasemi
// ----------
// 
// Synch Simple Dual Ported Block RAM. Output is available on the next posedge of clk
// 
// TODO:
// CHANGELOG:
// March 23rd, 2015 - Creation
// NOTE:
//  -since C_LOG_DEPTH is used to assign the depth of the block ram
//  - in the ram.init file there always has to be enough entry to fill out the ram
////////////////////////////////////////////////////////////////////////////////
module bram_mapper
  (
   i_clk,

   i_waddr,
   i_wen,
   i_wdata,

   i_raddr,
   i_ce,
   o_rdata
   );

   ////////////////////////////////////////////////////////////////////////////////
  // Parameters
   ////////////////////////////////////////////////////////////////////////////////

   parameter	C_WIDTH				=	32;
   parameter	C_LOG_DEPTH		=	2;

   ////////////////////////////////////////////////////////////////////////////////
   // Local Parameters
   ////////////////////////////////////////////////////////////////////////////////

   localparam	C_DEPTH	=	(1 << C_LOG_DEPTH);

   ////////////////////////////////////////////////////////////////////////////////
   // Inputs and Outputs
   ////////////////////////////////////////////////////////////////////////////////

   input				       	i_clk;
   input [C_LOG_DEPTH-1: 0] 			i_waddr;
   input					i_wen;
   input [C_WIDTH-1: 0] 			i_wdata;
   input [C_LOG_DEPTH-1: 0] 			i_raddr;
   input					i_ce;				
   output	reg [C_WIDTH-1: 0] 		o_rdata;
   

   ////////////////////////////////////////////////////////////////////////////////
   // RAMs
   ////////////////////////////////////////////////////////////////////////////////

   reg [C_WIDTH-1: 0] 				r_ram	[C_DEPTH-1: 0];

   ////////////////////////////////////////////////////////////////////////////////
   // Variables
   ////////////////////////////////////////////////////////////////////////////////

   //integer i;

   ////////////////////////////////////////////////////////////////////////////////
   // RAM Logic
   ////////////////////////////////////////////////////////////////////////////////

   // Clear the RAM
   //initial
   //begin
   //	for (i = 0; i < C_DEPTH; i = i + 1)
   //		r_ram[i]	<= 0;
   //end


   // INIT MEMORY
   initial begin
      $readmemh("/home/eghasemi89/Documents/Zynq_Mini_ITX/linux/Hardware/mycores/srcs/ram.init",r_ram, 0, C_DEPTH-1);
   end
/*
   
    initial
    begin

    r_ram[3] = 32'h10001000;
    r_ram[2] = 32'h01000100;
    r_ram[1] = 32'h00100010;
    r_ram[0] = 32'h00010001;


    end
  */  
   /*
    integer i;
    initial 
    begin
    for (i=0; i<C_DEPTH; i=i+1) r_ram[i] = 0;
end
    */


   //WRITE PORT
   always @(posedge i_clk)
     begin
	if (i_wen)
	  r_ram[i_waddr] <= i_wdata;
     end


   //READ PORT      
   always @(posedge i_clk)
     begin
	if (i_ce)
	  o_rdata <= r_ram[i_raddr];
	
	
     end
   // Read Port
   //assign o_rdata	=	r_ram[i_raddr];

endmodule
