module AR_BR_CR_datapath(AR_neg, AR_pos, AR_zero, AR_data, BR_data, load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR, clk, reset_b);
  
  input load_AR_BR, div_AR_T_CR, mul_BR_T_CR, clr_CR, clk, reset_b;
  input [15:0] AR_data, BR_data;
  output AR_neg, AR_pos, AR_zero;
  
  reg [15:0] AR_data_out, BR_data_out, CR_data_out;
  
  assign AR_pos = (!AR_data_out[15]) && (|AR_data_out[14:0]);
  assign AR_neg = AR_data_out[15];
  assign AR_zero = (AR_data_out == 16'b0);
  
  always @(posedge clk) begin
    if (reset_b == 0) begin
      AR_data_out = 16'b0;
      BR_data_out = 16'b0;
    end
    else begin
      //PIPO P1(AR_data_out, BR_data_out, AR_data, BR_data, load_AR_BR, clk);
      if(load_AR_BR) begin
        AR_data_out <= AR_data;
        BR_data_out <= BR_data;
      end
      else if (div_AR_T_CR) begin
        CR_data_out <= {AR_data_out[15],AR_data_out[15:1]};
      end
      else if (mul_BR_T_CR) begin
        CR_data_out <= (BR_data_out<<1);
      end
      else if (clr_CR) begin
        CR_data_out <= 16'b0;
      end
    end
  end
endmodule

/*
module PIPO (d_out_A, d_out_B, d_in_A, d_in_B, load, clk);
  
  input [15:0] d_in_A, d_in_B;
  input load, clk;
  output reg [15:0] d_out_A, d_out_B;
  
  always @(posedge clk) begin
    if(load) begin
      d_out_A <= d_in_A;
      d_out_B <= d_in_B;
    end
    else begin
      d_out_A <= 1'bx;
      d_out_B <= 1'bx;
    end
  end
  
endmodule
*/