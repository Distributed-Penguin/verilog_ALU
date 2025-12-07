//2 to 1 mux
module mux2 
(
    input logic [1:0] in,
    input logic sel,
    output logic out
);
    assign out = (sel & in[1]) | (~sel & in[0]);
endmodule