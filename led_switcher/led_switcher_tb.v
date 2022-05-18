module led_switcher_tb;

parameter N = 3;

reg clk = 0;
wire [3:0] DATA;

reg [N-1:0] counter = 0;

led_switcher #(.N(N)) LS1 (
    .clk_in(clk),
    .data(DATA)
);

always #1 clk = ~clk;

always @(negedge clk) begin
    counter = counter + 1;
end

initial begin
    $dumpfile("led_switcher_tb.vcd");
    $dumpvars(0, led_switcher_tb);

    # 99 $display("END of simulation");
    # 100 $finish;
end

endmodule
