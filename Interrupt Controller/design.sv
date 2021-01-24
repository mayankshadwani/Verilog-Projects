module interrupt_controller(
  //Processor
  pclk_i,prst_i,paddr_i,pwdata_i,prdata_o,pwrite_i,penable_i,pready_o,pslverr_o,
  intr_to_service_o,intr_valid_o,intr_serviced_i,
  //Peripheral Controllers
  intr_active_i
);
  
  //penable_i is given by processor
  //pready_o is given by Interrupt Controller
  
  parameter NUM_INTR 		= 16;
  parameter S_NO_INTR 		= 3'b000;
  parameter S_INTR_ACTIVE 	= 3'b001;
  parameter S_INTR_GIVEN_TO_PROC = 3'b010;
  parameter S_INTR_SERVICED = 3'b011;
  parameter S_INTR_ERROR 		= 3'b100;
  
  input pclk_i,prst_i,pwrite_i,penable_i;
  input [7:0] paddr_i;
  input [7:0] pwdata_i;
  output reg [7:0] prdata_o;
  output reg pready_o;
  output reg pslverr_o;
  output reg [3:0] intr_to_service_o;
  output reg intr_valid_o;
  input intr_serviced_i;
  input [NUM_INTR-1:0] intr_active_i;
  
  integer i;
  reg first_match_f;
  reg [3:0] highest_priority;
  reg [3:0] intr_with_highest_prio;
  
  //Array to registers to decide the prioroty of the interrupts by the processor
  reg [7:0] priority_regA[NUM_INTR-1:0]; //16 registers
  
  //For State Machine to be implemented
  reg [2:0] state, next_state;
  
  always @(next_state) begin
    state = next_state;
  end
  
  //Process 1 - Programming (writing the priority and reading) the registers
  always @(posedge pclk_i) begin
    
    if(prst_i == 1) begin
      //Reset all the reg variables
      prdata_o = 0;
      pready_o = 0;
      pslverr_o = 0;
      intr_to_service_o = 0;
      intr_valid_o = 0;
      first_match_f = 0;
      highest_priority = 0;
      intr_with_highest_prio = 0;
      for (i=0 ; i<NUM_INTR ; i=i+1) begin
        priority_regA[i] = 0;
      end
      state = S_NO_INTR;
      next_state = S_NO_INTR;
    end
    
    else begin
      if (penable_i == 1) begin
        pready_o = 1;
        if(pwrite_i == 1) begin
          priority_regA[paddr_i] = pwdata_i;
        end
        else begin
          prdata_o = priority_regA[paddr_i];
        end
      end
    end
  end
  
  //Process 2 - Interrupt Handling: Actual functionality of Interrupt Controller
  //Interrupt Handling is implemented by STATE MACHINES
  always @(posedge pclk_i) begin
    case(state)
      
      S_NO_INTR: begin
        if(intr_active_i != 0) begin
          next_state = S_INTR_ACTIVE;
          first_match_f = 1;
        end
      end
      
      S_INTR_ACTIVE: begin
        //Figure out the highest priority interrupt amongst all the active interrupts
        for (i=0 ; i<NUM_INTR ; i=i+1) begin
          if (intr_active_i != 0) begin
            if (first_match_f == 1) begin
              highest_priority = priority_regA[i];
              intr_with_highest_prio = i;
              first_match_f = 0; //One time only to get the reference value
            end
            else begin
              if (highest_priority < priority_regA[i]) begin
                highest_priority = priority_regA[i];
                intr_with_highest_prio = i;
              end
            end
          end
        end
        next_state = S_INTR_GIVEN_TO_PROC;
      end
      
      S_INTR_GIVEN_TO_PROC: begin
        intr_to_service_o = intr_with_highest_prio;
        intr_valid_o = 1;
        first_match_f = 1;
        next_state = S_INTR_SERVICED;
      end
      
      S_INTR_SERVICED: begin
        if (intr_serviced_i == 1) begin
          intr_to_service_o = 0;
          intr_valid_o = 0;
          if (intr_active_i != 0) begin
            next_state = S_INTR_ACTIVE;
          end
          else begin
            next_state = S_NO_INTR;
          end
        end
        else begin
          next_state = S_INTR_SERVICED;
        end
      end
      
      S_INTR_ERROR: begin
        //Will be implemented later
      end
      
    endcase
  end
  
  
endmodule