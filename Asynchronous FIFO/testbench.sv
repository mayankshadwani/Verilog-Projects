module tb_FIFO;
  
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter PTR_WIDTH = 4;
  integer i;
  integer wr_delay, rd_delay;
  
  reg wr_clk,rd_clk,rst,wr_en,rd_en;
  reg [WIDTH-1:0] wdata;
  wire [WIDTH-1:0] rdata;
  wire full, empty, error;
  
  reg [40*8:1] testname; // can hold 40 ASCI characters
  
  
  //Parameter Overriding
  
  async_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH)) dut(wr_clk,rd_clk, rst, wr_en, wdata, full, rd_en, rdata, empty, error);
  
  //Generate different frequencies clock
  
  initial begin
    wr_clk = 0;
    forever #8 wr_clk = ~ wr_clk;
  end
  
  initial begin
    rd_clk = 0;
    forever #7 rd_clk = ~ rd_clk;
  end
  
  
  initial begin
    $value$plusagrs("testname=%s", testname);		//vsim -novopt tb_FIFO +testname=test_fifo_full_error
    rst = 1;
    repeat(2) @(posedge wr_clk);
    rst = 0;
    
    case(testname)
      
      "test_fifo_concurrent_rd_wr": begin
        fork
          begin
            for (i=0 ; i<DEPTH ; i=i+1) begin
              @(posedge wr_clk);
              wr_en = 1;
              wdata = $random;
              wr_delay = $urandom_range(1,10);
              @(posedge wr_clk);
              wr_en = 0;
              wdata = 0;
              repeat(wr_delay-1)@(posedge wr_clk);
            end
          end

          begin
            //Reading from FIFO
            for (i=0 ; i<DEPTH ; i=i+1) begin
              @(posedge rd_clk);
              rd_en = 1;
              rd_delay = $urandom_range(1,10);
              @(posedge rd_clk);
              rd_en = 0;
              repeat(rd_delay-1)@(posedge rd_clk);
            end
          end
        join
      end
      
      "test_fifo_empty_error": begin
        for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge wr_clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge wr_clk);
        wr_en = 0;
        wdata = 0;

        //Reading from FIFO
        for (i=0 ; i<DEPTH+1 ; i=i+1) begin
          @(posedge rd_clk);
          rd_en = 1;
        end

        //Stop the read operation
        @(posedge rd_clk);
        rd_en = 0;
      end
      
      "test_fifo_full_error": begin
        for (i=0 ; i<DEPTH+1 ; i=i+1) begin
          @(posedge wr_clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge wr_clk);
        wr_en = 0;
        wdata = 0;
      end
      
      "test_fifo_wr_rd" : begin
        //Apply the stimulus and make the FIFO full
        for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge wr_clk);
          wr_en = 1;
          wdata = $random;
        end

        //Stop the write operation
        @(posedge wr_clk);
        wr_en = 0;
        wdata = 0;

        //Reading from FIFO
        for (i=0 ; i<DEPTH ; i=i+1) begin
          @(posedge rd_clk);
          rd_en = 1;
        end

        //Stop the read operation
        @(posedge rd_clk);
        rd_en = 0;
      end
    endcase
    
    #100;
    $finish;
  end
  
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,tb_FIFO);
  end
endmodule