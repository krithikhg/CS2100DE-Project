`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Neil Banerjee
// 
// Create Date: 01.01.2025 21:55:29
// Design Name: Adder
// Module Name: Adder
// Project Name: CS2100DE Labs
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description:  
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Adder(
    input  [31:0] in_a,
    input  [31:0] in_b,
    output [31:0] result,
    output        carry_out
);

    assign {carry_out, result} = in_a + in_b;

endmodule