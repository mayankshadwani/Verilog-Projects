module tb_FIFO;
  
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter PTR_WIDTH = 4;
  integer i;
  integer wr_delay, rd_delay;
  
  reg clk,rst,wr_en,rd_en;
  reg [WIDTH-1:0] wdata;
  wire [WIDTH-1:0] rdata;
  wire full, empty, error;
  
  reg [40*8:1] testname = test_fifo_concurrent_rd_wr; // can hold 40 ASCI characters
  
  //Parameter Overriding
  
  sync_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH)) dut(clk, rst, wr_en, wdata, full, rd_en, rdata, empty, error);
  
  initial begin
    clk = 0;
    forever #5 clk = ~ clk;
  end
  
  initial begin
    $value$plusagrs("testname=%s", testname);		//vsim -novopt tb_FIFO +testname=test_fifo_full_error
    rst = 1;
    repeat(2) @(posedge clk);
    rst = 0;
    
    case(testname)
      
      "test_fifo_concurrent_rd_wr": begin
        fork
          begin
            for (i=0 ; i<DEPTH ; i=i+1) begin
              @(posedge clk);
              wr_en = 1;
              wdata = $random;
              wr_delay = $urandom_range(1,10);
              @(posedge clk);
              wr_en = 0;
              wdata = 0;
              repeat(wr_delay-1)@(posedge clk);
            end
          end

          begin
            //Reading from FIFO
            for (i=0 ; i<DEPTH ; i=i+1) begin
              @(posedge clk);
              rd_en = 1;
              rd_delay = $urandom_range(1,10);
              @(posedge clk);
              rd_en = 0;
              repeat(rd_delay-1)@(posedge clk);
            end
          end
        join
      end
      
      "test_fifo_empty_error": begin
        /*for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge clk);
        wr_en = 0;
        wdata = 0;*/

        //Reading from FIFO
        for (i=0 ; i<DEPTH+1 ; i=i+1) begin
          @(posedge clk);
          rd_en = 1;
        end

        //Stop the read operation
        @(posedge clk);
        rd_en = 0;
      end
      
      "test_fifo_full_error": begin
        for (i=0 ; i<DEPTH+1 ; i=i+1) begin
          @(posedge clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge clk);
        wr_en = 0;
        wdata = 0;
      end
      
      "test_fifo_wr_rd" : begin
        //Apply the stimulus and make the FIFO full
        for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge clk);
        wr_en = 0;
        wdata = 0;

        //Reading from FIFO
        for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge clk);
          rd_en = 1;
        end

        //Stop the read operation
        @(posedge clk);
        rd_en = 0;
      end
    endcase
    
    #100;
    $finish;
  end
endmodule