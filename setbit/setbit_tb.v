module setbit_tb;

wire A;

setbit SB1 (
    .A (A)
);

initial begin
    $dumpfile("setbit_tb.vcd");
    $dumpvars(0, setbit_tb);

    #10 if (A != 1)
        $display("--> ERROR! Pin A is not 1");
    else
        $display("Ok");

    #10 $finish;
end

endmodule
