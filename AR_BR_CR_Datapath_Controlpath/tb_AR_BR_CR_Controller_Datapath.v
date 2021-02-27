module tb_AR_BR_CR_Controller_Datapath;
  
  reg clk,reset_b,start;
  reg [15:0] AR_data,BR_data;
  wire busy;
  
  reg [15:0] AR_mag, BR_mag, CR_mag;		//For 2's complement representation
  
  AR_BR_CR_Controller_Datapath dut(clk,reset_b,start,AR_data,BR_data,busy);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  //2s complement notation deferencing
  always @(controller.datapath.AR_data_out) begin
    if(controller.datapath.AR_data_out[15] == 1)
      AR_mag = ~controller.datapath.AR_data_out + 16'b0000_0000_0000_0001;
    else
      AR_mag = controller.datapath.AR_data_out;
  end
  always @(controller.datapath.BR_data_out) begin
    if(controller.datapath.BR_data_out[15] == 1)
      BR_mag = ~controller.datapath.BR_data_out + 16'b0000_0000_0000_0001;
    else
      BR_mag = controller.datapath.BR_data_out;
  end
  always @(controller.datapath.CR_data_out) begin
    if(controller.datapath.CR_data_out[15] == 1)
      CR_mag = ~controller.datapath.CR_data_out + 16'b0000_0000_0000_0001;
    else
      CR_mag = controller.datapath.CR_data_out;
  end
  
  
  //Reset and stimulus
  initial begin
    reset_b = 0;
    start = 0;
    repeat(5) begin
      #12; reset_b = $random;
      #10; start = 1;
    end
    
    AR_data = 16'd50;
    BR_data = 16'd20;			//Result should be 40
    #50;
    AR_data = 16'd20;
    BR_data = 16'd50;			//Result should be 100
    #50;
    AR_data = 16'd50;
    BR_data = 16'd50;			//Result should be 100
    #50;
    AR_data = 16'd0;			//Result should be CR <- 0
    #50;
    AR_data = -16'd20;			//Result should be 10
    BR_data = 16'd50;
    #50;
    AR_data = -16'd80;			//Result should be 40
    BR_data = 16'd50;
    #300;
    $finish;
  end
  
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,tb_AR_BR_CR_Controller_Datapath);
  end
  
endmodule