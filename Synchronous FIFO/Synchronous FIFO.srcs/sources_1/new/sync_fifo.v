module sync_fifo(clk, rst, wr_en, wdata, full, rd_en, rdata, empty, error);
  
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter PTR_WIDTH = 4;
  integer i;
  
  input clk,rst,wr_en,rd_en;
  input [WIDTH-1:0] wdata;
  output reg [WIDTH-1:0] rdata;
  output reg full, empty, error;
  
  reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
  reg wr_toggle_f, rd_toggle_f;
  
  reg [WIDTH-1:0] mem [DEPTH-1:0];
  
  always @(posedge clk) begin
    if (rst == 1) begin
      //reset everything
      empty = 1;
      full = 0;
      error = 0;
      rd_ptr = 0;
      wr_ptr = 0;
      wr_toggle_f = 0;
      rd_toggle_f = 0;
      rdata = 0;
      for (i=0 ; i<DEPTH ; i=i+1) begin
        mem[i] = 0;
      end
    end
    
    else begin
      
      if (wr_en == 1) begin
        if (full == 0) begin
          $display("ERROR: Writing to a FULL FIFO");
          error = 1;
        end
        else begin
          mem[wr_ptr] = wdata;
          if (wr_ptr == DEPTH-1) begin
            wr_toggle_f = ~wr_toggle_f;
            wr_ptr = 0;
          end
          else begin
            wr_ptr = wr_ptr + 1;
          end
        end
      end
      
      if (rd_en == 1) begin
        if (empty == 0) begin
          $display("ERROR: Reading from an EMPTY FIFO");
          error = 1;
        end
        else begin
          rdata = mem[rd_ptr];
          if (rd_ptr == DEPTH-1) begin
            rd_toggle_f = ~rd_toggle_f;
            rd_ptr = 0;
          end
          else begin
            rd_ptr = rd_ptr + 1;
          end
        end
      end
    end
  end
  
  //Generating FULL and EMPTY Conditions - Purely Combinational Logic
  
  always @(wr_ptr or rd_ptr) begin
    
    full = 0;
    empty = 0;
    
    if (wr_ptr == rd_ptr && wr_toggle_f == rd_toggle_f) begin
      empty = 1;
      full = 0;
    end
    
    if (wr_ptr == rd_ptr && wr_toggle_f != rd_toggle_f) begin
      empty = 0;
      full = 1;
    end
  
  end
endmodule