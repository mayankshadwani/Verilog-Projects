module async_fifo(wr_clk,rd_clk, rst, wr_en, wdata, full, rd_en, rdata, empty, error);
  
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter PTR_WIDTH = 4;
  integer i;
  
  input wr_clk,rd_clk,rst,wr_en,rd_en;
  input [WIDTH-1:0] wdata;
  output reg [WIDTH-1:0] rdata;
  output reg full, empty, error;
  
  reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
  reg [PTR_WIDTH-1:0] wr_ptr_rd_clk, rd_ptr_wr_clk;
  reg wr_toggle_f, rd_toggle_f;
  reg wr_toggle_f_rd_clk, rd_toggle_f_wr_clk;
  
  reg [WIDTH-1:0] mem [DEPTH-1:0];
  
  //READ PURPOSE
  
  always @(posedge rd_clk) begin
    if (rst == 0) begin
      error = 0;
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
  
  //WRITE PURPOSE
  
  always @(posedge wr_clk) begin
    if (rst == 1) begin
      //reset everything
      empty = 1;
      full = 0;
      error = 0;
      rd_ptr = 0;
      wr_ptr = 0;
      wr_ptr_rd_clk = 0;
      rd_ptr_wr_clk = 0;
      wr_toggle_f = 0;
      rd_toggle_f = 0;
      wr_toggle_f_rd_clk = 0;
      rd_toggle_f_wr_clk = 0;
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
    end
  end
  
  //Synchronization
  always @(posedge wr_clk) begin
    rd_ptr_wr_clk <= rd_ptr;
    rd_toggle_f_wr_clk <= rd_toggle_f;
  end
  
  always @(posedge rd_clk) begin
    wr_ptr_rd_clk <= wr_ptr;
    wr_toggle_f_rd_clk <= wr_toggle_f;
  end
  
  //Generating FULL condition -> Use the signals synchronized to wr_clk
  always @(wr_ptr or rd_ptr_wr_clk) begin
    if (wr_ptr == rd_ptr_wr_clk && wr_toggle_f != rd_toggle_f_wr_clk) begin
      full = 1;
    end
    else begin
      full = 0;
    end
  end
  
  //Generating EMPTY condition -> Use the signals synchronized to rd_clk
  always @(rd_ptr or wr_ptr_rd_clk) begin
    if (rd_ptr == wr_ptr_rd_clk && wr_toggle_f_rd_clk == rd_toggle_f) begin
      empty = 1;
    end
    else begin
      empty = 0;
    end
  end
  
endmodule