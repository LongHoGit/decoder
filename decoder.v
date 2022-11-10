`timescale 1ns / 1ps
module decoder		(	        clk,
					instruction, 
					rs1, 
					rs2, 
					imm, 
					rd, 
					alu_ctrl
					);

input clk;
input [31:0] instruction;

output [4:0]  rs1;
output [4:0]  rs2;
output [31:0] imm;
output [4:0]  rd;
output [3:0]  alu_ctrl;

////////////////////////////////////////////
parameter R_OP 		 =5'b01100;
parameter IMM_OP	 =5'b00100;
parameter LOAD_OP	 =5'b00000;
parameter STORE_OP	 =5'b01000;
parameter BRANCH_OP	 =5'b11000;
parameter JAL_OP     =5'b11011;
parameter JALR_OP	 =5'b11001;
parameter LUI_OP	 =5'b01101;
parameter AUIPC_OP	 =5'b00101;
parameter ENVIR_OP	 =5'b11100;

////////////////////////////////////////////
reg [4:0]  reg_rs1;
reg [4:0]  reg_rs2;
reg [31:0] reg_imm;
reg [4:0]  reg_rd;
reg [3:0]  reg_alu_ctrl;

reg  [4:0] reg_opcode;
reg  [2:0] funct3;
reg  [6:0] funct7_or_reg_imm;
///////////////////////////////////////////

always @(posedge clk or instruction) 
begin
//////////////////////////////////////////////////////////////////
	reg_opcode = instruction[6:2];
	funct3 = instruction[14:12];
	funct7_or_reg_imm = instruction[31:25];

	reg_rs1 = instruction[19:15];
	reg_rs2 = instruction[24:20];
	
	if (instruction[31] == 0)
		reg_imm = {20'b00000000000000000000,instruction[31:20]};
	else 
		reg_imm = {20'b11111111111111111111,instruction[31:20]};

	reg_rd = instruction[11:7];
//////////////////////////////////////////////////////////////////
	case(reg_opcode)
		
		R_OP, IMM_OP:
		begin
			if (reg_opcode == R_OP && {funct3, funct7_or_reg_imm} == 10'b000_0100000)
				reg_alu_ctrl = 1; //sub
		
			case({funct3,funct7_or_reg_imm})
				10'b000_0000000:reg_alu_ctrl = 0; //add
				10'b100_0000000:reg_alu_ctrl = 2; //xor
				10'b110_0000000:reg_alu_ctrl = 3; //or
				10'b111_0000000:reg_alu_ctrl = 4; //and
				10'b001_0000000:reg_alu_ctrl = 5; //sll
				10'b101_0000000:reg_alu_ctrl = 6; //srl
				10'b101_0100000:reg_alu_ctrl = 7; //sra
				10'b010_0000000:reg_alu_ctrl = 8; //slt
				10'b011_0000000:reg_alu_ctrl = 9; //sltu		
			endcase
		end
		
		LOAD_OP: 
		begin
			case(funct3)
				3'b000:reg_alu_ctrl = 0; //lb
				3'b001:reg_alu_ctrl = 0; //lh
				3'b010:reg_alu_ctrl = 0; //lw
				3'b100:reg_alu_ctrl = 0; //lbu
				3'b101:reg_alu_ctrl = 0; //lhu
			endcase
		end
		
		STORE_OP:
		begin
			case(funct3)
				3'b000:reg_alu_ctrl = 0; //sb
				3'b001:reg_alu_ctrl = 0; //sh
				3'b010:reg_alu_ctrl = 0; //sw
			endcase
		end
		
	endcase
	
end //always

assign rs1 = reg_rs1;
assign rs2 = reg_rs2;
assign imm = reg_imm;
assign rd = reg_rd;
assign alu_ctrl = reg_alu_ctrl;

endmodule

