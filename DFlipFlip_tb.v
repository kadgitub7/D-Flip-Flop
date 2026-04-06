`timescale 1ns / 1ps

module DFlipFlip_tb();
    reg Clk,D;
    wire Q,Qnot;
    
    DFlipFlop uut(Clk,D,Q,Qnot);
    
    initial begin
        Clk = 0; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk,D,Q,Qnot);
        Clk = 0; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk,D,Q,Qnot);
        Clk = 1; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk,D,Q,Qnot);
        Clk = 0; D = 0; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk,D,Q,Qnot);    
    end
endmodule
