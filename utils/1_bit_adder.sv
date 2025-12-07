module 1_bit_adder (
    input logic a,
    input logic b,
    input logic carry_in,
    output logic sum,
    output logic carry_out
    );
    logic simple_sum;
    assign simple_sum = a ^ b;
    assign sum = simple_sum ^ carry_in;
    assign carry_out = (a & b) | (carry_in & simple_sum);
endmodule