//`define C_WIDTH 3    // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
//`define BUF_SIZE ( 1<<`BUF_WIDTH )
// CHANGE LOG:
// MARCH 24 2015 --> change the behaviour of the read so that when the read_en signal is deasserted,
//                    the data output shows a value of zero

module fifo_dc #( // fifo for data controller that outputs zero when !read_en
    parameter integer C_WIDTH = 8,
    parameter integer C_LOG_FIFO_DEPTH = 3
  )

( clk, 
  rst, 
  buf_in, 
  buf_out, 
  wr_en, 
  rd_en, 
  buf_empty, 
  buf_full, 
  fifo_counter 
  );

  localparam integer C_DEPTH = 1 << C_LOG_FIFO_DEPTH;

input                 rst, clk, wr_en, rd_en;   
// reset, system clock, write enable and read enable.
input [C_WIDTH-1:0]           buf_in;                   
// data input to be pushed to buffer
output[C_WIDTH-1:0]           buf_out;                  
// port to output the data using pop.
output                buf_empty, buf_full;      
// buffer empty and full indication 
output[C_LOG_FIFO_DEPTH :0] fifo_counter;             
// number of data pushed in to buffer   

reg[C_WIDTH-1:0]              buf_out;
reg                   buf_empty, buf_full;
reg[C_LOG_FIFO_DEPTH :0]    fifo_counter;
reg[C_LOG_FIFO_DEPTH -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses  
reg[C_WIDTH-1:0]              buf_mem[C_DEPTH -1 : 0]; //  

always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== C_DEPTH);

end

always @(posedge clk)
begin
   if( rst )
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1;
   else
      fifo_counter <= fifo_counter;
end

always @( posedge clk)
begin
   if( rst )
      buf_out <= 0;
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];

      else
         buf_out <= 0;//buf_out;

   end
end

always @(posedge clk)
begin

   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge clk)
begin
   if( rst )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 1;
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1;
      else rd_ptr <= rd_ptr;
   end

end
endmodule