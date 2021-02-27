module AR_BR_CR_controller(load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR, busy, AR_neg, AR_pos, AR_zero, clk, reset_b, start);
  
  parameter S0 = 1'b0;
  parameter S1 = 1'b1;
  
  input AR_neg, AR_pos, AR_zero, clk, reset_b, start;
  output reg busy, load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR;
  
  reg state, next_state;
  always @(next_state) begin
    state = next_state;
  end
  
  always @(posedge clk) begin
    
    if(reset_b == 0) begin
      state = S0;
      next_state = S0;
      load_AR_BR = 0;
      busy = 0;
      div_AR_T_CR = 0;
      mul_BR_T_CR = 0;
      clr_CR = 0;
    end
    
    else begin
      case (state)
        S0: begin
          if(start == 1) begin
            load_AR_BR = 1;
            next_state = S1;
          end
          else next_state = S0;
        end
        S1: begin
          if (AR_neg == 1) begin
            div_AR_T_CR = 1;
            next_state = S0;
          end
          else if (AR_pos == 1) begin
            mul_BR_T_CR = 1;
            next_state = S0;
          end
          else begin
            clr_CR = 1;
            next_state = S0;
          end
        end
      endcase
    end
  end
endmodule