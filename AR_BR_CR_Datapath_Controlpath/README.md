A digital circuit with three 16-bit registers AR, BR and CR that can perform the following operations:

1.	Transfer two 16-bit signed numbers (in 2’s complement representation) to AR & BR.
2.	If the number in AR is negative, divide the number in AR by 2 and transfer the result to register CR.
3.	If the number in AR is positive but non-zero, multiply the number in BR by 2 and transfer the result to register CR.
4.	If the number in AR is zero, clear register CR to 0.

The system is implemented using Verilog HDL with the concept of datapath and controllers.
