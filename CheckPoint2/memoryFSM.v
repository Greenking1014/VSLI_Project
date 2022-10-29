module moduleName #(
    parameter WIDTH = 16, REGBITS = 4
) (
    input [REGBITS-1:0] reg1, reg2,
    input [7:0] switches;
    input reset, clk,
	output [6:0] seg0, seg1, seg2, seg3,    
);
    
    // BRAM component
    EXRAM bram();

    // datapath component
    
    always @(posedge clk ) begin

    end
    always @(addr, read_mem_data) begin
	  mem_select = addr & io;
	  case(mem_select)
			io: begin
				 read_data <= switches;
			end
			EXMEM_00: begin
				 read_data <= read_mem_data;
			end
			EXMEM_01: begin
				 read_data <= read_mem_data;
			end
			EXMEM_10: begin
				 read_data <= read_mem_data;
			end
			default: begin
				 read_data <= read_mem_data;
			end
	  endcase
	end
endmodule