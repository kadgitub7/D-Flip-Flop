`timescale 1ns / 1ps

module DFlipFlop(
    input Clk,
    input D,
    output Q,
    output Qnot
    );
    
    wire Dnot;
    assign Dnot = ~D;
    
    SRFlipFlop flip1(Clk,D,Dnot,Q,Qnot);
    
endmodule
