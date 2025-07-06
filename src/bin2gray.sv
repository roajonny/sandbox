`timescale 1ns / 1ps

// File :            bin2gray.sv
// Title :           bin2gray
//
// Author(s) :       Jonathan Roa
//
// Description :     Binary to gray converter
//
//                   RTL source files are broken into sections for
//                   better readability and "ctrl+f" navigation: 
//
//                       - '(A) DECLARATIONS'
//                       - '(B) INSTANTIATES'
//                       - '(C) DESIGN LOGIC'
//
// Revisions
//
// Date        Name            REV#        Description
// ----------  --------------- ----------- --------------------
// (07/04/25)  Jonathan Roa    1.0         Initial Revision

module bin2gray #
    (
        parameter p_DATA_WIDTH = 32
    )
    (
        input  wire [p_DATA_WIDTH-1:0] i_bin,
        output wire [p_DATA_WIDTH-1:0] o_gray
    );

    // =========================
    // --  (A) DECLARATIONS   --
    // =========================
    integer i;
    logic [p_DATA_WIDTH-1:0] l_gray;

    // =========================
    // --  (B) INSTANTIATES   --
    // =========================

    // =========================
    // --  (C) DESIGN LOGIC   --
    // =========================

    assign o_gray = l_gray;

    // MSB is always the same between binary and gray
    assign l_gray[p_DATA_WIDTH-1] = i_bin[p_DATA_WIDTH-1];

    always_comb begin
        for (i = 0; i < p_DATA_WIDTH-1; i++) begin
            l_gray[i] <= i_bin[i] ^ i_bin[i+1];
        end
    end

endmodule
