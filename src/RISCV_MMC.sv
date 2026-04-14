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
    input [31:0] instr_F,   //changed to instr_F
    input [31:0] read_data_M,       // v2: Renamed to support lb/lbu/lh/lhu
    output mem_read,
    output reg mem_write_M,  // Delete reg for release. v2: Changed to column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC_F,   //changed to PC_F
    output reg [31:0] ALUResult_M,
    output reg [31:0] write_data_M  // Delete reg for release. v2: Renamed to support sb/sw
    );

	assign mem_read = mem_to_reg_M; // This is needed for the proper functionality of some devices such as UART CONSOLE

	
	//----------------------------------------------//
	//----F-STAGE-----------------------------------//
	
	logic [31:0] adder_pc_a_F, adder_pc_b_F;
	logic [1:0] PC_src_E;
	logic [31:0] ext_imm_E, RD1_E;
	logic [31:0] PC_E, PC_IN;
	
	assign adder_pc_a_F = PC_src_E[0] ? ext_imm_E : 32'd4;
    assign adder_pc_b_F = PC_src_E[1] ? RD1_E : (PC_src_E[0] ? PC_E : PC_F); //multiplexer added here for jal/jalr
	
	// Instantiate Adder for Program Counter
	Adder adder_uut(
        .in_a(adder_pc_a_F),
        .in_b(adder_pc_b_F),
        .result(PC_IN),
        .carry_out()
    );
	
	// Instantiate the Program Counter
    ProgramCounter program_counter_uut(
        .clk(clk),
        .rst(rst),
        .pc_in(PC_IN),
        .pc(PC_F)
    );
    
	
	//----------------------------------------------//
	//----D-STAGE-----------------------------------//
	
	logic [31:0] instr_D, PC_D;
	
	logic reg_write_W;
	logic [31:0] RD1_D, RD2_D;
	
	logic [2:0] imm_src;
    logic [31:0] ext_imm_D;
    
    logic [1:0] PCS_D;
	logic mem_to_reg_D, mem_write_D, reg_write_D;
	logic [3:0] ALUControl_D;
	logic [1:0] ALUSrcA_D, ALUSrcB_D;
	logic [2:0] funct3_D;
	
	logic [4:0] rd_D, rd_W;
	logic [31:0] result_W;
	
	//D Register
	always @(posedge clk) begin
	   if(rst) begin
	       instr_D <= 32'b0;
	       PC_D <= 32'b0;
	   end else begin
           instr_D <= instr_F;
           PC_D <= PC_F;
	   end
	end
	
	// Instantiate the Register File
	RegFile regfile_uut(
	   .clk(clk),
	   .we(reg_write_W),
	   .rs1(instr_D[19:15]),
	   .rs2(instr_D[24:20]),
	   .rd(rd_W),
	   .WD(result_W),
	   .RD1(RD1_D),
	   .RD2(RD2_D) 
	);
	
	assign rd_D = instr_D[11:7];
	
	// Instantiate extender module
	Extend extender_uut(
	   .instr_imm(instr_D[31:7]),
	   .imm_src(imm_src),
	   .ext_imm(ext_imm_D)
	);

	// Instantiate instruction decoder 
	Decoder decoder_uut(
	   .instr(instr_D),
	   .PCS(PCS_D),
	   .mem_to_reg(mem_to_reg_D),
	   .mem_write(mem_write_D),
	   .alu_control(ALUControl_D),
	   .alu_src_a(ALUSrcA_D),
	   .alu_src_b(ALUSrcB_D),
	   .imm_src(imm_src),
	   .funct3(funct3_D),
	   .reg_write(reg_write_D)
	);
	
	
	//----------------------------------------------//
	//----E-STAGE-----------------------------------//
	
	logic [1:0] PCS_E;
	logic reg_write_E, mem_to_reg_E, mem_write_E;
	logic [3:0] ALUControl_E;
	logic [1:0] ALUSrcA_E, ALUSrcB_E;
	logic [31:0] RD2_E;	
	logic [4:0] rd_E;
	logic [2:0] funct3_E;
	logic [2:0] ALUFlags;
	logic [31:0] ALUResult_E;
	
	
	//E Register
	always @(posedge clk) begin
	   if(rst) begin
	       funct3_E <= 3'b0;
	       PCS_E <= 2'b0;
           reg_write_E <= 0;
           mem_to_reg_E <= 0;
           mem_write_E <= 0;
           ALUControl_E <= 4'b0;
           ALUSrcA_E <= 2'b0;
           ALUSrcB_E <= 2'b0;
           RD1_E <= 32'b0;
           RD2_E <= 32'b0;
           ext_imm_E <= 32'b0;
           PC_E <= 32'b0;
           rd_E <= 5'b0;
	   end else begin
	       funct3_E <= funct3_D;
           PCS_E <= PCS_D;
           reg_write_E <= reg_write_D;
           mem_to_reg_E <= mem_to_reg_D;
           mem_write_E <= mem_write_D;
           ALUControl_E <= ALUControl_D;
           ALUSrcA_E <= ALUSrcA_D;
           ALUSrcB_E <= ALUSrcB_D;
           RD1_E <= RD1_D;
           RD2_E <= RD2_D;
           ext_imm_E <= ext_imm_D;
           PC_E <= PC_D;
           rd_E <= rd_D;
	   end
	end
	
	// Instantiate the PC Logic
	PC_Logic pc_logic_uut(
	   .PCS(PCS_E),
	   .funct3(funct3_E),
	   .alu_flags(ALUFlags),
	   .PC_src(PC_src_E)
	);
	
	logic [31:0] srca, srcb;
	assign srca = ALUSrcA_E[0] ? (ALUSrcA_E[1] ? PC_E : 32'b0) : RD1_E; //2 multiplexers added here to support lui & auipc
    assign srcb = ALUSrcB_E[0] ? (ALUSrcB_E[1] ? ext_imm_E : 32'd4) : RD2_E; //1 multiplexer added here to support jal/jalr

	// Instantiate your ALU here
    ALU alu_uut(
        .src_a(srca),
        .src_b(srcb),
        .control(ALUControl_E),
        .result(ALUResult_E),
        .flags(ALUFlags)
    );
    
    logic [31:0] write_data_E;
    assign write_data_E = RD2_E;
    
    
    
    //----------------------------------------------//
	//----M-STAGE-----------------------------------//
    
    logic reg_write_M, mem_to_reg_M;
    logic [4:0] rd_M;
    
    //M Register
	always @(posedge clk) begin
	   if(rst) begin
	       reg_write_M <= 0;
           mem_to_reg_M <= 0;
           mem_write_M <= 0;
           ALUResult_M <= 32'b0;
           write_data_M <= 32'b0;
           rd_M <= 5'b0;
	   end else begin
           reg_write_M <= reg_write_E;
           mem_to_reg_M <= mem_to_reg_E;
           mem_write_M <= mem_write_E;
           ALUResult_M <= ALUResult_E;
           write_data_M <= write_data_E;
           rd_M <= rd_E;
	   end
	end
    
    
    //----------------------------------------------//
	//----W-STAGE-----------------------------------//
    
    logic mem_to_reg_W;
    logic [31:0] read_data_W, ALUResult_W;
    
    
	//W Register
	always @(posedge clk) begin
	   if(rst) begin
	       reg_write_W <= 0;
           mem_to_reg_W <= 0;
           read_data_W <= 32'b0;
           ALUResult_W <= 32'b0;
           rd_W <= 5'b0;
	   end else begin
           reg_write_W <= reg_write_M;
           mem_to_reg_W <= mem_to_reg_M;
           read_data_W <= read_data_M;
           ALUResult_W <= ALUResult_M;
           rd_W <= rd_M;
	   end
	end
	
    assign result_W = (mem_to_reg_W) ? read_data_W : ALUResult_W;
	
endmodule
