/*
    This module recieves a pair of floating point numbers and indicates the larger one.
*/

`include "system_constants.svh" //want to import constants from .svh by default

module fp_comparator (
    input logic [DATA_WIDTH - 1 : 0] a,
    input logic [DATA_WIDTH - 1 : 0] b,
    output logic a_gt_b,
    output logic b_gt_a,
    output logic a_eq_b
);

    logic eq_sign, eq_sign_a_gt_b, eq_sign_b_gt_a, eq_sign_a_eq_b;
    assign eq_sign = ~(a[DATA_WIDTH - 1] ^ b[DATA_WIDTH - 1]);

    eq_sign_comparator eq_sign_comp
    (
        .a(a), 
        .b(b), 
        .a_gt_b(eq_sign_a_gt_b), 
        .b_gt_a(eq_sign_b_gt_a),
        .a_eq_b(eq_sign_a_eq_b)
    );

    mux2 a_vs_b(
        .out(a_gt_b),
        .in({eq_sign_a_gt_b, ~a[DATA_WIDTH - 1]}),
        .sel(eq_sign)
    );

    mux2 b_vs_a(
        .out(b_gt_a),
        .in({eq_sign_b_gt_a, ~b[DATA_WIDTH - 1]}),
        .sel(eq_sign)
    );

    mux2 is_eq(
        .out(a_eq_b),
        .in({eq_sign_a_eq_b, 1'b0}),
        .sel(eq_sign)
    );

endmodule



module eq_sign_comparator 
(
    input logic [DATA_WIDTH - 1 : 0] a,
    input logic [DATA_WIDTH - 1 : 0] b,
    output logic a_gt_b,
    output logic b_gt_a,
    output logic a_eq_b
);

    logic [DATA_WIDTH - 2 : 0] a_unsigned, b_unsigned, a_unsigned_inv, b_unsigned_inv, sim_bits;
    logic [DATA_WIDTH - 1 : 0] diff_mask;
    logic sign, abs_a_gt_b, abs_b_gt_a;

    assign sign = a[DATA_WIDTH - 1]; //arbitrarily extract sign from a
    assign a_unsigned = a[DATA_WIDTH - 2 : 0];
    assign b_unsigned = b[DATA_WIDTH - 2 : 0];
    assign a_unsigned_inv = ~a_unsigned;
    assign b_unsigned_inv = ~b_unsigned;
    assign sim_bits = ~(a_unsigned ^ b_unsigned);

    generate
        genvar i;
        assign diff_mask[DATA_WIDTH - 1] = 1'b1;
        for (i = 0; i <= DATA_WIDTH - 2; i = i + 1)
        begin: diff_mask_gen
            assign diff_mask[DATA_WIDTH - i - 2] = diff_mask[DATA_WIDTH - i - 1] & sim_bits[DATA_WIDTH - i - 2];
        end       
    endgenerate

    //bit by bit comparison for positive case (expressions are used in reverse for negative case)
    assign abs_a_gt_b = | (diff_mask[DATA_WIDTH - 1 : 1] & a_unsigned & b_unsigned_inv);
    assign abs_b_gt_a = | (diff_mask[DATA_WIDTH - 1 : 1] & a_unsigned_inv & b_unsigned);
    
    //assign outputs
    
    mux2 a_vs_b (
        .out(a_gt_b), 
        .in({abs_b_gt_a, abs_a_gt_b}), 
        .sel(sign)
    ); 

    mux2 b_vs_a (
        .out(b_gt_a), 
        .in({abs_a_gt_b, abs_b_gt_a}), 
        .sel(sign)
    );

    assign a_eq_b = diff_mask[0];
endmodule