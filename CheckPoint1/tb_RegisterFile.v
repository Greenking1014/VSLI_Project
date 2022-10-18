
module tb_RegisterFile;
reg clk;
reg rst_n;

reg  		  regwrite;
integer i;
reg  [3:0] ra1, ra2;
reg  [15:0]   wd;
wire [15:0]   rd1, rd2;
			  
RegisterFile regfil(.clk(clk), .regwrite(regwrite), .ra1(ra1), .ra2(ra2), .wd(wd), .rd1(rd1), .rd2(rd2));


localparam CLK_PERIOD = 10;


initial begin
    //initialize variables
	 clk = 0;
	 clk = 1;
	 regwrite = 0;
    ra1 = 0; ra2 =0;
    wd = 0;
	 i = 0;
    regwrite = 1;
end

always #(CLK_PERIOD/2) 
begin 
	//changes clk value every 5ps
	clk=~clk;
	
	//TODO: ADD COMMENT
	if(regwrite && clk && i < 15)
	begin
		//for(i = 0; i < 15; i=i+1)
		//begin
			ra1=i; ra2 = i+1; wd = 2;
		//end
		//regwrite = 0;
		i = i +1;
	end
end 

endmodule 