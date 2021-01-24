module watchdog_timer(
  //Processor
  pclk_i,prst_i,paddr_i,pwdata_i,prdata_o,pwrite_i,penable_i,pready_o,pslverr_o,
  //System Interface
  activity_i,sys_reset_o
);
  
  parameter S_RESET 			= 2'b00;
  parameter S_NO_ACTIVITY 		= 2'b01;
  parameter S_ACTIVITY 			= 2'b10;
  parameter S_THRESHOLD_TIMEOUT = 2'b11;
  
  input pclk_i,prst_i,pwrite_i,penable_i;
  input [7:0] paddr_i;
  input [7:0] pwdata_i;
  output reg [7:0] prdata_o;
  output reg pready_o;
  output reg pslverr_o;
  input activity_i;
  output reg sys_reset_o;
 
  integer no_activity_count;
  
  //Register to store the threshold value of the timer
  reg [7:0] threshold_timer_reg; //1 register
  
  //For State Machine to be implemented
  reg [2:0] state, next_state;
  
  always @(next_state) begin
    state = next_state;
  end
  
  //Process 1 - Programming the registers
  always @(posedge pclk_i) begin
    
    if(prst_i == 1) begin
      //Reset all the reg variables
      prdata_o = 0;
      pready_o = 0;
      pslverr_o = 0;
      state = S_RESET;
      next_state = S_RESET;
      sys_reset_o = 0;
      no_activity_count = 0;
    end
    
    else begin
      if (penable_i == 1) begin
        pready_o = 1;
        if(pwrite_i == 1) begin
          threshold_timer_reg = pwdata_i;
        end
        else begin
          prdata_o = threshold_timer_reg;
        end
      end
    end
  end
  
  //Process 2 - Implementing Watchdog Timer Functionality
  always @(posedge pclk_i) begin
    case(state)
  
      S_RESET: begin
        sys_reset_o = 0;
        if (activity_i == 1) begin
          next_state = S_ACTIVITY;
        end
        else begin
          next_state = S_NO_ACTIVITY;
          no_activity_count = no_activity_count + 1;
        end
      end
      
      S_NO_ACTIVITY: begin
        sys_reset_o = 0;
        if (activity_i == 0) begin
          no_activity_count = no_activity_count + 1;
          if(no_activity_count == threshold_timer_reg) begin
            next_state = S_THRESHOLD_TIMEOUT;
          end
        end
        else begin
          next_state = S_ACTIVITY;
        end
      end
      
      S_ACTIVITY: begin
        sys_reset_o = 0;
        no_activity_count = 0;
        if (activity_i == 1) begin
          next_state = S_ACTIVITY;
        end
        else begin
          next_state = S_NO_ACTIVITY;
        end
      end
      
      S_THRESHOLD_TIMEOUT: begin
        sys_reset_o = 1;
        next_state = S_NO_ACTIVITY;
        no_activity_count = 0;
      end
      
    endcase
  end
  
  
endmodule