module tb_watchdog_timer;
  
  reg pclk_i,prst_i,pwrite_i,penable_i;
  reg [7:0] paddr_i;
  reg [7:0] pwdata_i;
  reg activity_i;
  wire [7:0] prdata_o;
  wire pready_o;
  wire pslverr_o;
  wire sys_reset_o;
  
  watchdog_timer dut(
  //Processor
  pclk_i,prst_i,paddr_i,pwdata_i,prdata_o,pwrite_i,penable_i,pready_o,pslverr_o,
  //System Interface
  activity_i,sys_reset_o
);
  
  initial begin
    pclk_i = 0;
    forever #5 pclk_i = ~pclk_i;
  end
  
  initial begin
    prst_i = 1;
    activity_i = 0;
    paddr_i = 0;
    pwrite_i = 0;
    pwdata_i = 0;
    penable_i = 0;
    repeat(2) @(posedge pclk_i);
    prst_i = 0;
    
    //Program Register
    reg_write(0,200);
    #2000;
    activity_i = 1;
    #10;
    activity_i = 0;
    #1000;
    activity_i = 1;
    #3000;
    $finish;
  end
  
  task reg_write(input [7:0] addr, input [7:0] data);
    begin
      @(posedge pclk_i);
      paddr_i = addr;
      pwdata_i = data; //(i: giving Lowest Priority and 15-i: giving Highest Priority) (Can't use $random -> same priority might be assigned)
      pwrite_i = 1;
      penable_i = 1;
      wait (pready_o == 1);
      @(posedge pclk_i);
      pwrite_i = 0;
      penable_i = 0;
      paddr_i = 0;
      pwdata_i = 0;
    end
  endtask
  
  initial begin
    $dumpfile("intc.vcd");
    $dumpvars(0,tb_watchdog_timer);
  end
endmodule