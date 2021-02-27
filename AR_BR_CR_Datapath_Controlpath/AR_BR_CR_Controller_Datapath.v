module AR_BR_CR_Controller_Datapath(clk,reset_b,start,AR_data,BR_data,busy);
  
  input clk,reset_b,start;
  input [15:0] AR_data,BR_data;
  output busy;
  
  AR_BR_CR_controller controller(load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR, busy, AR_neg, AR_pos, AR_zero, clk, reset_b, start);
  AR_BR_CR_datapath datapath(AR_neg, AR_pos, AR_zero, AR_data, BR_data, load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR, clk, reset_b);
  
endmodule