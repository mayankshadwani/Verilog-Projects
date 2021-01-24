Design and Verification of Synchronous FIFO using Verilog

FIFO is a design component used for interfacing data transfer between two components either working on the same frequency or different frequencies.
The design was implemented in such a way that there are no race and glitch conditions arise due to the design working in two different clock domains. 
I have implemented both Synchronous FIFO and Asynchronous FIFO using Verilog and RTL code and also verified the same using Verilog HDL.
The only point to notice here in Synchronous FIFO is that it has just a single clock to have a synchronization between the operations.
The same clock is being used to perform the write and read operations.
