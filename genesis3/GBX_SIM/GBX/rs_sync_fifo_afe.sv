/********************************
 * Module: 	rs_sync_fifo_afe
 * Date:	02/24/2023	
 * Company:	RapidSilicon
 * Created by Zafar Ali
 * Description: synchronous fifo 
********************************/

module rs_sync_fifo_afe #(
	parameter FIFO_DATA_WIDTH = 11,
	parameter FIFO_DEPTH = 4, 
	parameter ALMOST_FULL_THRESHOLD = 0,
	parameter ALMOST_EMPTY_THRESHOLD = 0
	)(
	input  logic 							clk, 
	input  logic 							rst_n, 
	input  logic 							write_en, 
	input  logic 							read_en,
	input  logic 	[FIFO_DATA_WIDTH-1:0]	data_in,
	output logic							full,
	output logic 							almost_full,
	output logic 							empty,
	output logic 							almost_empty,	
	output logic 	[FIFO_DATA_WIDTH-1:0]	data_out
	);

	// FIFO parameters
	parameter FIFO_POINTER_WIDTH = $clog2(FIFO_DEPTH) + 1;
	parameter FIFO_COUNTER_WIDTH = $clog2(FIFO_DEPTH) + 1;

	// FIFO pointers
	reg	[FIFO_POINTER_WIDTH-1:0]	wr_ptr;
	reg	[FIFO_POINTER_WIDTH-1:0]	rd_ptr;

	reg	[FIFO_COUNTER_WIDTH-1:0]	count;
	
	wire [FIFO_POINTER_WIDTH-1:0] 	w_ptr_plus_1 = wr_ptr + 1'b1;
	// wire 							mem_write_en;

	raminfr #(FIFO_POINTER_WIDTH-1,FIFO_DATA_WIDTH,FIFO_DEPTH)  
	ram (.clk(clk), 
				.write_en(write_en), 
				.write_addr(wr_ptr[FIFO_POINTER_WIDTH-2:0]), 
				.read_addr(rd_ptr[FIFO_POINTER_WIDTH-2:0]), 
				.data_in(data_in), 
				.data_out(data_out)
			); 

	// assign mem_write_en = (write_en && count<FIFO_DEPTH) ? write_en : 0;

	always @(posedge clk or negedge rst_n)begin  // synchronous FIFO
		if (!rst_n) begin
			wr_ptr		<= #1 0;
			rd_ptr		<= #1 0;
			count		<= #1 0;
		end
		else begin
			case ({write_en, read_en})
				2'b10:
					begin
						wr_ptr     <= #1 w_ptr_plus_1;
						if(count < FIFO_DEPTH-1)
							count     <= #1 count + 1'b1;
					end
				2'b01: if(count>0)
					begin
						rd_ptr   <= #1 rd_ptr + 1'b1;
						count	<= #1 count - 1'b1;
					end
				2'b11: begin
						rd_ptr   <= #1 rd_ptr + 1'b1;
						wr_ptr   <= #1 w_ptr_plus_1;
						end					
				default: ;
			endcase
		end
	end 

	always  @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			almost_full  <= 'b0;
			almost_empty <= 'b0;
		end
		else begin
			if (ALMOST_FULL_THRESHOLD == 0)
				almost_full  <= 'b0;
			else if(count >= ALMOST_FULL_THRESHOLD)
				almost_full  <= 'b1;
			else 
				almost_full  <= 'b0;

			if(ALMOST_EMPTY_THRESHOLD == 0)
				almost_empty <= 'b0;
			else if(count <= ALMOST_EMPTY_THRESHOLD )
				almost_empty <= 'b1;
			else 
				almost_empty <= 'b0;		
		end
	end 

	always @(posedge clk or negedge rst_n) begin // synchronous FIFO
		if (!rst_n) begin
			full    <= #1 1'b0;
			empty   <= #1 1'b0;
		end 
		else begin
			if((count>=FIFO_DEPTH-1))
				full   <= #1 1'b1;
			else 
				full    <= #1 1'b0;
			if((count==0))
				empty   <= #1 1'b1;	
			else	
				empty   <= #1 1'b0;

		end 
	end  

endmodule

module raminfr #(	
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 8,
	parameter MEM_DEPTH = 16 
	)(
    input	logic clk, 
    input 	logic write_en, 
    input 	logic [ADDR_WIDTH-1:0] write_addr, 
    input 	logic [ADDR_WIDTH-1:0] read_addr, 
    input 	logic [DATA_WIDTH-1:0] data_in, 
    output  logic [DATA_WIDTH-1:0] data_out
    ); 

	reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0]; 
	
	// write data 
	always @(posedge clk) begin   
		if (write_en)   
		mem [write_addr] <= data_in;   
	end 

	// read data
	assign data_out = mem[read_addr];

endmodule 