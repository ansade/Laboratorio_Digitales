`timescale 1ns / 1ps
`ifndef DEFINTIONS_V
`define DEFINTIONS_V

//opcodes	
`default_nettype none	
`define NOP   4'd0
`define CALL  4'd1 
`define LED   4'd2
`define BLE   4'd3
`define STO   4'd4
`define ADD   4'd5
`define JMP   4'd6
`define SUB   4'd7
`define SMUL  4'd8
`define IMUL  4'd9
`define RET   4'd10
`define SHL   4'd11
`define VGA   4'd12
`define BBU  4'd13
`define LCD	  4'd14


//RAM Registers
`define R0 8'd0
`define R1 8'd1
`define R2 8'd2
`define R3 8'd3
`define R4 8'd4
`define R5 8'd5
`define R6 8'd6
`define R7 8'd7

//Colors
`define COLOR_BLACK   3'b000
`define COLOR_BLUE    3'b001
`define COLOR_GREEN   3'b010
`define COLOR_CYAN    3'b011
`define COLOR_RED     3'b100
`define COLOR_MAGENTA 3'b101
`define COLOR_YELLOW  3'b110
`define COLOR_WHITE   3'b111

//LCD opcodes
//Write Data to DD-RAM
`define SPACE 8'h20
`define H 8'h48
`define E 8'h45
`define L 8'h4C
`define O 8'h4F
`define W 8'h57
`define R 8'h52
`define D 8'h44
//Clear display
`define CLR 8'h01 //Needs a nop of at least 1.64 ms!!!!
//Set DD-RAM address
`define SDR1 8'h80 //first line first column 0x00
`define SDR2 8'hC0 //second line first column 0x40
//Shift Display
`define 8'h18 //left
`define 8'h1C //right

//LCD States
`define WRITE 	8'd02
`define LOAD	8'd03

`endif
