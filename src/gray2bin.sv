`timescale 1ns / 1ps

// File :            gray2bin.sv
// Title :           gray2bin
//
// Author(s) :       Jonathan Roa
//
// Description :     Gray to binary converter
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

module gray2bin #
    (
        parameter p_DATA_WIDTH = 32
    )
    (
        input  wire [p_DATA_WIDTH-1:0] i_gray,
        output wire [p_DATA_WIDTH-1:0] o_bin
    );

    // =========================
    // --  (A) DECLARATIONS   --
    // =========================
    integer i;
    logic [p_DATA_WIDTH-1:0] l_bin;

    // =========================
    // --  (B) INSTANTIATES   --
    // =========================

    // =========================
    // --  (C) DESIGN LOGIC   --
    // =========================

    assign o_bin = l_bin;

    // MSB is always the same between binary and gray
    assign l_bin[p_DATA_WIDTH-1] = i_gray[p_DATA_WIDTH-1];

    always_comb begin
        for (i = 0; i < p_DATA_WIDTH-1; i++) begin
            l_bin[i] <= l_bin[i+1] ^ i_gray[i]; 
        end
    end

endmodule
