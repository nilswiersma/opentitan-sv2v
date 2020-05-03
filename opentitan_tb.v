module opentitan_tb();

reg clk;
reg rst;

top_earlgrey opentitan (
	.clk_i(clk),
	.rst_ni(rst)
);

initial begin
    forever #1 clk = !clk;
end

initial begin
    clk = 1'b0;
    rst = 1'b1;
    #5;
    rst = 1'b0;
    #5;
    rst = 1'b1;
    #100
    $finish;
end

initial begin
    // Set variables to be dumped to vcd file here
    $dumpfile("opentitan.vcd");
    $dumpvars;
end

endmodule
