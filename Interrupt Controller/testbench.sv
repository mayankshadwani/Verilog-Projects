module tb_INTC;
  
  parameter NUM_INTR = 16;
  
  reg pclk_i,prst_i,pwrite_i,penable_i;
  reg [7:0] paddr_i;
  reg [7:0] pwdata_i;
  wire [7:0] prdata_o;
  wire pready_o;
  wire pslverr_o;
  wire [3:0] intr_to_service_o;
  wire intr_valid_o;
  reg intr_serviced_i;
  reg [NUM_INTR-1:0] intr_active_i;
  
  integer i;
  
  interrupt_controller dut (
    //Processor
    pclk_i,prst_i,paddr_i,pwdata_i,prdata_o,pwrite_i,penable_i,pready_o,pslverr_o,
    intr_to_service_o,intr_valid_o,intr_serviced_i,
    //Peripheral Controllers
    intr_active_i
	);
  
  initial begin
    pclk_i = 0;
    forever #5 pclk_i = ~pclk_i;
  end
  
  initial begin
    prst_i = 1;
    intr_active_i = 0;
    paddr_i = 0;
    pwrite_i = 0;
    pwdata_i = 0;
    penable_i = 0;
    repeat(2) @(posedge pclk_i);
    prst_i = 0;
    
    //Apply stimulus
    //Step1: Program the priority registers
    /*for(i=0 ; i<NUM_INTR ; i=i+1) begin
      //reg_write(i,i); //LOWEST Priority
      reg_write(i,NUM_INTR-1-i); //HIGHEST Priority
    end*/
    //For random priority generation
    reg_write(0,10);
    reg_write(1,15);
    reg_write(2,7);
    reg_write(3,5);
    reg_write(4,6);
    reg_write(5,3);
    reg_write(6,8);
    reg_write(7,4);
    reg_write(8,0);
    reg_write(9,1);
    reg_write(10,11);
    reg_write(11,2);
    reg_write(12,13);
    reg_write(13,9);
    reg_write(14,14);
    reg_write(15,12);
    
    //To generate interrupts
    intr_active_i = $random;
    #100;
    intr_active_i = intr_active_i | $random;
    #1000;
    intr_active_i = intr_active_i | $random;
    #2000;
    $finish;
    
  end
  
  //Service the interrupt
  initial begin
    forever begin
      @(posedge pclk_i);
      if(intr_valid_o == 1) begin
        //Take some time to service the interrupt
        #20;
        //Drop the interrupt once it is being serviced
        intr_active_i[intr_to_service_o] = 0; //Dropping the interrupt
        intr_serviced_i = 1;
        #10;
        intr_serviced_i = 0;
      end
    end
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
    $dumpvars(0,tb_INTC);
  end
endmodule