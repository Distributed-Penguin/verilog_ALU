/*
    This module recieves a pair of positive floating point numbers and returns the larger one.
    For this reason - comparator doesn't require sign bit.
*/

`include "system_constants.svh" //want to import constants from .svh by default

module positive_comparator (
    input logic [DATA_WIDTH - 2 : 0] a,
    input logic [DATA_WIDTH - 2 : 0] b,
    output logic a_gt_b,
    output logic b_gt_a,
    output logic a_eq_b
);
    logic [DATA_WIDTH - 2 : 0] a_inv, b_inv, sim_bits;
    logic [DATA_WIDTH - 1 : 0] diff_mask;
    assign a_inv = ~a;
    assign b_inv = ~b;
    assign sim_bits = ~(a ^ b);
    generate
        genvar i;
        assign diff_mask[DATA_WIDTH - 1] = 1'b1;
        for (i = 0; i <= DATA_WIDTH - 2; i = i + 1)
        begin: diff_mask_gen
            assign diff_mask[DATA_WIDTH - i - 2] = diff_mask[DATA_WIDTH - i - 1] & sim_bits[DATA_WIDTH - i - 2];
        end
        
    endgenerate
    assign a_gt_b = | (diff_mask[DATA_WIDTH - 1 : 1] & a & b_inv);
    assign b_gt_a = | (diff_mask[DATA_WIDTH - 1 : 1] & a_inv & b);
    assign a_eq_b = diff_mask[0];
endmodule