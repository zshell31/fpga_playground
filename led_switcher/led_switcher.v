module led_switcher(input clk_in, output [3:0] data);

wire [3:0] data;
wire clk_in;

parameter N = 23;

reg [N-1:0] count = 0;
reg [3:0] data_reg = 0;

assign data = data_reg;

always @(posedge(clk_in)) begin
    count <= count + 1;
end

always @(count) begin
    case(count[N-1:N-2])
        2'b00       : data_reg = 4'b1000;
        2'b01       : data_reg = 4'b0100;
        2'b10       : data_reg = 4'b0010;
        2'b11       : data_reg = 4'b0001;
        default     : data_reg = 0;
    endcase
end

endmodule
