`timescale 1 ns / 1 ps

module rs_async_fifo_afe #(
	parameter	DATASIZE  = 32,
	parameter	SYNC_STAGES    = 2,
    parameter FIFO_DEPTH = 4
	) 
	(
	
    input   wire                  wclk, 
    input   wire                  wr_reset_n, 
    input   wire                  wr,
    input   wire [DATASIZE-1:0]   wr_data,
    output                        full,
    input   wire                  rclk,
    input   wire                  rd_reset_n,
    input   wire                  rd,
    output       [DATASIZE-1:0]   rd_data,
    output  reg                   empty

    );

	localparam  ADDRSIZE =  $clog2(FIFO_DEPTH);

    reg     [ADDRSIZE:0]          rd_addr;
    reg     [ADDRSIZE:0]          wr_addr;
    wire    [ADDRSIZE:0]          rd_wgray;
    wire    [ADDRSIZE:0]          wr_rgray;
    wire    [ADDRSIZE:0]          next_rd_addr;
    wire    [ADDRSIZE:0]          next_wr_addr;
    reg     [ADDRSIZE:0]          rgray, wgray;
    wire                          ren;
    wire                          read_empty;


   

    /* increment write pointer when wr signal goes high and fifo is not full */
    assign	next_wr_addr = wr_addr + 1;
    always @(posedge wclk or negedge wr_reset_n)
    if (!wr_reset_n)
    begin
        wr_addr <= 0;
        wgray   <= 0;
    end else if (wr && !full)
    begin
        wr_addr <= next_wr_addr;
        /* Binary to Gray code conversion */
        wgray   <= next_wr_addr ^ (next_wr_addr >> 1);
    end
    
    /* increment read pointer when rd signal goes high and fifo is not empty */
    assign	next_rd_addr = rd_addr + 1;
    always @(posedge rclk or negedge rd_reset_n)
    if (!rd_reset_n)
    begin
        rd_addr <= 0;
        rgray   <= 0;
    end else if (ren && !read_empty)
    begin
        rd_addr <= next_rd_addr;
        /* Binary to Gray code conversion */
        rgray   <= next_rd_addr ^ (next_rd_addr >> 1);
    end


	/* full signal goes high if fifo is full */
    assign 	full = (wr_rgray == {~wgray[ADDRSIZE:ADDRSIZE-1], wgray[ADDRSIZE-2:0] });

	/* this signal goes high if fifo is empty */
	assign  read_empty = (rd_wgray == rgray);
	

	assign  ren = (!empty && rd);     

    always @(posedge rclk or negedge rd_reset_n)
        if (!rd_reset_n)
            empty <= 1'b1;
         else
            empty <= read_empty;
        

	
    synchronizer # (.SYNC_STAGES(SYNC_STAGES),
                    .ADDRSIZE   (ADDRSIZE))
    synchronizer(
                .wptr_reg    (wr_rgray),
                .rptr_reg    (rd_wgray),
                .wr_clk      (wclk),
                .rd_clk      (rclk),
                .wr_rst      (wr_reset_n),
                .rd_rst      (rd_reset_n),
                .wptr        (wgray),
                .rptr        (rgray)
                );
	
   dual_port_ram # (.DATASIZE(DATASIZE),
                    .ADDRSIZE (ADDRSIZE),
                    .MEMDEPTH(FIFO_DEPTH))
   dual_port_ram(
                 .rdata  (rd_data),
                 .wr_clk (wclk),
                 .rd_clk (rclk),
                 .wen    (wr && !full),
                 .ren    (ren),
                 .wdata  (wr_data),
                 .waddr  (wr_addr),
                 .raddr  (rd_addr)
                 );
endmodule


module synchronizer #(

     /* Total number of synchronization stages, to handle metastaibility. This value can be greater but minimum value is 2 */
    parameter SYNC_STAGES   = 2,
    parameter ADDRSIZE      = 4
)
(
    output  [ADDRSIZE:0]    wptr_reg,
    output  [ADDRSIZE:0]    rptr_reg,
    input                   wr_clk,
    input                   rd_clk,
    input                   wr_rst,
    input                   rd_rst,
    input   [ADDRSIZE:0]    wptr,
    input   [ADDRSIZE:0]    rptr

);
    
    reg [ADDRSIZE:0] wr_sync_register[0:SYNC_STAGES-1];
    reg [ADDRSIZE:0] rd_sync_register[0:SYNC_STAGES-1];


    assign wptr_reg = wr_sync_register[SYNC_STAGES-1];
    assign rptr_reg = rd_sync_register[SYNC_STAGES-1];

    always @(posedge wr_clk or negedge wr_rst) begin
        if (!wr_rst) begin
            wr_sync_register[0] <= 0;
        end
        else begin
            wr_sync_register[0] <= rptr;
        end   
    end

    always @(posedge rd_clk or negedge rd_rst) begin
        if (!rd_rst) begin
            rd_sync_register[0] <= 0;
        end
        else begin
            rd_sync_register[0] <= wptr;
        end
        
    end
    
    genvar i;

    generate
        for(i=0; i<(SYNC_STAGES-1); i = i+1)begin
            always@(posedge wr_clk or negedge wr_rst) begin
                if(!wr_rst) begin
                    wr_sync_register[i+1] <= 0;
                end
                else begin
                    wr_sync_register[i+1] <= wr_sync_register[i];
                end
            end     
            always @(posedge rd_clk or negedge rd_rst) begin
                if (!rd_rst) begin
                    rd_sync_register[i+1] <= 0;
                end
                else begin
                    rd_sync_register[i+1] <= rd_sync_register[i];
                end    
            end
        end
    endgenerate


endmodule

module dual_port_ram #(
    /* Define width of memory */
    parameter DATASIZE = 32,
    /* Define depth of memory */
    parameter ADDRSIZE = 4,

    parameter MEMDEPTH = 4
    )
(
    output reg [DATASIZE-1:0]   rdata,
    input                       wr_clk,
    input                       rd_clk,
    input                       wen,
    input                       ren,
    input      [DATASIZE-1:0]   wdata,
    input      [ADDRSIZE:0]     waddr,
    input      [ADDRSIZE:0]     raddr
);
   
   
    reg [DATASIZE-1:0] mem	[MEMDEPTH-1:0];

    // always @(posedge rd_clk) begin
    //     if (ren) begin
    //         rdata   <= mem[raddr[ADDRSIZE-1:0]];
    //     end
    // end
    always @(posedge wr_clk) begin
        if (wen) 
        mem[waddr[ADDRSIZE:0]]  <=  wdata;
    end
    
    
    assign rdata = mem[raddr[ADDRSIZE-1:0]];
    
endmodule