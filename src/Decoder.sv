`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Krithikh Gopalakrishnan
// 
// Create Date: 22.02.2025 20:37:13
// Design Name: RISCV-MMC
// Module Name: Decoder 
// Project Name: CS2100DE Project
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description: Instruction decoder and Control Unit for the RISC-V CPU we are building
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder(    
    input [31:0] instr,
    output logic [1:0] PCS,
    output logic mem_to_reg,
    output logic mem_write,
    output logic [3:0] alu_control,
    output logic [1:0] alu_src_a,
    output logic [1:0] alu_src_b,
    output logic [2:0] imm_src,
    output logic reg_write
    );
    
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0]; 
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    always @(instr) begin
        case (opcode)
            8'h33: begin // R type
                PCS = 2'b00;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a[0] = 0;
                alu_src_b[0] = 0;
                alu_control = {funct7[5], funct3};
            end
            8'h13: begin // I type
                PCS = 2'b00;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a[0] = 0;
                alu_src_b = 2'b11;
                imm_src = 3'b000;
                alu_control = {(funct3 == 3'b101) ? funct7[5] : 1'b0, funct3};
            end
            8'h03: begin // I type
                PCS = 2'b00;
                mem_to_reg = 1;
                reg_write = 1;
                mem_write = 0;
                alu_src_a[0] = 0;
                alu_src_b = 2'b11;
                imm_src = 3'b000;
                alu_control = 4'b0000;
            end
            8'h23: begin // S type
                PCS = 2'b00;
                reg_write = 0;
                mem_write = 1;
                alu_src_a[0] = 0;
                alu_src_b = 2'b11;
                imm_src = 3'b001;
                alu_control = 4'b0000;
            end
            8'h63: begin // B type
                PCS = 2'b01;
                reg_write = 0;
                mem_write = 0;
                alu_src_a[0] = 0;
                alu_src_b[0] = 0;
                imm_src = 3'b010;
                alu_control = 4'b0001;
            end
            8'h6F: begin // jal, J-type
                PCS = 2'b10;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a = 2'b11;
                alu_src_b = 2'b01; 
                imm_src = 3'b100;
                alu_control = 4'b0000; 
            end
            8'h67: begin // jalr, I-type
                PCS = 2'b11;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a = 2'b11;
                alu_src_b = 2'b01; 
                imm_src = 3'b000;
                alu_control = 4'b0000; 
            end
            8'h17: begin //auipc
                PCS = 2'b00;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a = 2'b11;
                alu_src_b = 2'b11;
                imm_src = 3'b011;
                alu_control = 4'b0000;
            end
            8'h37: begin // lui
                PCS = 2'b00;
                mem_to_reg = 0;
                reg_write = 1;
                mem_write = 0;
                alu_src_a = 2'b01;
                alu_src_b = 2'b11;
                imm_src = 3'b011;
                alu_control = 4'b0000;
            end    
        endcase
    end
    
endmodule
