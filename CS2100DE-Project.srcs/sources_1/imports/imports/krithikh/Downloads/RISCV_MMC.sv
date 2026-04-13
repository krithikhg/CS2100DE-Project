`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Neil Banerjee
// 
// Create Date: 22.02.2025 21:29:09
// Design Name: RISCV-MMC
// Module Name: RISCV_MMC
// Project Name: CS2100DE Labs
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description: The main RISC-V CPU 
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RISCV_MMC(
    input clk,
    input rst,
    //input Interrupt,      // for optional future use.
    input [31:0] instr,
    input [31:0] mem_read_data,       // v2: Renamed to support lb/lbu/lh/lhu
    output mem_read,
    output reg mem_write,  // Delete reg for release. v2: Changed to column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC,
    output [31:0] alu_result,
    output reg [31:0] mem_write_data  // Delete reg for release. v2: Renamed to support sb/sw
    );

	assign mem_read = mem_to_reg; // This is needed for the proper functionality of some devices such as UART CONSOLE

	// Create all the wires/logic signals you need here
	logic [31:0] PC_IN;
	logic [4:0] rd;
	logic reg_write;
	
	logic [31:0] rd1;
	logic [31:0] rd2;
	
	logic [31:0] ext_imm;
	logic [2:0] imm_src;
	
	logic [1:0] PCS;
	logic [1:0] PC_src;
	
	logic [31:0] srca;
	logic [31:0] srcb;
	logic [2:0] ALUFlags;
	logic [3:0] ALUControl;
	logic [31:0] ALUResult;
	
    logic [1:0] ALUSrcA;
    logic [1:0] ALUSrcB;
    logic [31:0] write_data;
    logic [31:0] readData;
    logic mem_to_reg;
    logic [31:0] result;
    
    logic[31:0] adder_pc_a, adder_pc_b;
    	
	assign readData = mem_read_data;
	always_comb mem_write_data = rd2;
	assign alu_result = ALUResult;

	

	// Instantiate your extender module here
	
	Extend extender_uut(
	   .instr_imm(instr[31:7]),
	   .imm_src(imm_src),
	   .ext_imm(ext_imm)
	);

	// Instantiate your instruction decoder here
	
	Decoder decoder_uut(
	   .instr(instr),
	   .PCS(PCS),
	   .mem_to_reg(mem_to_reg),
	   .mem_write(mem_write),
	   .alu_control(ALUControl),
	   .alu_src_a(ALUSrcA),
	   .alu_src_b(ALUSrcB),
	   .imm_src(imm_src),
	   .reg_write(reg_write)
	);

	// Instantiate your ALU here

    ALU alu_uut(
        .src_a(srca),
        .src_b(srcb),
        .control(ALUControl),
        .result(ALUResult),
        .flags(ALUFlags)
    );
    
	// Instantiate the Register File
	
	RegFile regfile_uut(
	   .clk(clk),
	   .we(reg_write),
	   .rs1(instr[19:15]),
	   .rs2(instr[24:20]),
	   .rd(instr[11:7]),
	   .WD(result),
	   .RD1(rd1),
	   .RD2(rd2) 
	);

	// Instantiate the PC Logic
	
	PC_Logic pc_logic_uut(
	   .PCS(PCS),
	   .funct3(instr[14:12]),
	   .alu_flags(ALUFlags),
	   .PC_src(PC_src)
	);

	// Instantiate the Program Counter
 
    ProgramCounter program_counter_uut(
        .clk(clk),
        .rst(rst),
        .pc_in(PC_IN),
        .pc(PC)
    );
    
    // Instantiate Adder for Program Counter
    
    assign adder_pc_a = PC_src[0] ? ext_imm : 32'd4;
    assign adder_pc_b = PC_src[1] ? rd1 : PC; //multiplexer added here for jal/jalr
    
    Adder adder_uut(
        .in_a(adder_pc_a),
        .in_b(adder_pc_b),
        .result(PC_IN),
        .carry_out()
    );
    
    // Other multiplexers
    
    assign srca = ALUSrcA[0] ? (ALUSrcA[1] ? PC : 32'b0) : rd1; //2 multiplexers added here to support lui & auipc
    assign srcb = ALUSrcB[0] ? (ALUSrcB[1] ? ext_imm : 32'd4) : rd2; //1 multiplexer added here to support jal/jalr
    assign result = (mem_to_reg) ? readData : ALUResult;
 
endmodule
