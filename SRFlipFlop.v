`timescale 1ns / 1ps

module SRFlipFlop(
    input Clk,
    input R,
    input S,
    output Q,
    output Qnot
    );
    
    wire Rstar, Sstar;
    
    assign Sstar = ~(S & Clk);
    assign Rstar = ~(R & Clk);
    
    assign Q = ~(Sstar & Qnot);
    assign Qnot = ~(Rstar & Q);
endmodule