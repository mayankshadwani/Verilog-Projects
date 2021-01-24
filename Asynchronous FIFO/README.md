Design and Verification of Asynchronous FIFO using Verilog

FIFO is a design component used for interfacing data transfer between two components either working on the same frequency or different frequencies. 
The design was implemented in such a way that there are no race and glitch conditions arise due to the design working in two different clock domains. 
I have implemented both Synchronous FIFO and Asynchronous FIFO using Verilog and RTL code and also verified the same using Verilog HDL.
The only point to notice here in Asynchronous FIFO is that it has two different clocks to have a synchronization between the operations, named as wr_clk and rd_clk.
Different clocks are being used to perform the write and read operations.