`timescale 1ns / 1ps

// File :            one_shot_pulse_gen.sv
// Title :           one_shot_pulse_gen
//
// Author(s) :       Jonathan Roa
//
// Description :     Generates one-shot pulse of parameterizable length
//                   via "go" strobe
//
//                   Pulse generation can be interrupted by "stop" strobe
//
//                   Case study on synthesis of sequential circuits
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
// (07/06/25)  Jonathan Roa    1.0         Initial Revision

module one_shot_pulse_gen #
    (
        parameter p_PULSE_LENGTH = 5
    )
    (
        input  wire i_clk,
        input  wire i_rst_n,

        input  wire i_go,
        input  wire i_stop,

        output wire o_pulse
    );

    // =========================
    // --  (A) DECLARATIONS   --
    // =========================

    localparam s_IDLE      = 2'b00;
    localparam s_GEN_PULSE = 2'b01;
    localparam s_DONE      = 2'b10;

    reg   [1:0] r_STATE;
    logic [1:0] l_STATE_next;

    localparam p_PULSE_CTR_WIDTH = $clog2(p_PULSE_LENGTH);

    logic                         l_pulse;
    logic                         l_pulse_ctr_en;
    wire                          w_pulse_ctr_done;
    reg   [p_PULSE_CTR_WIDTH-1:0] r_pulse_ctr;

    // =========================
    // --  (B) INSTANTIATES   --
    // =========================

    // =========================
    // --  (C) DESIGN LOGIC   --
    // =========================

    // Counter indicates to FSM that pulse length generated
    assign w_pulse_ctr_done = (r_pulse_ctr == p_PULSE_LENGTH-1) ? 1'b1 : 1'b0;
    always_ff @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_pulse_ctr <= 0;
        end else if (l_pulse_ctr_en) begin
            r_pulse_ctr <= r_pulse_ctr + 1;
        end else begin
            r_pulse_ctr <= 0;
        end
    end

    // 2-block FSM generates only output and state-transition logic
    always_ff @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_STATE <= s_IDLE;
        end else begin
            r_STATE <= l_STATE_next;
        end
    end

    assign o_pulse = l_pulse;
    always_comb begin
        case (r_STATE)
            s_IDLE: begin
                l_pulse        <= 1'b0;
                l_pulse_ctr_en <= 1'b0;

                if (i_go) begin
                    l_STATE_next <= s_GEN_PULSE;
                end else begin
                    l_STATE_next <= s_IDLE;
                end
            end
            s_GEN_PULSE: begin
                l_pulse        <= 1'b1;
                l_pulse_ctr_en <= 1'b1;

                if (w_pulse_ctr_done | i_stop) begin
                    l_STATE_next <= s_DONE;
                end else begin
                    l_STATE_next <= s_GEN_PULSE;
                end
            end
            s_DONE: begin
                l_pulse        <= 1'b0;
                l_pulse_ctr_en <= 1'b0;

                l_STATE_next <= s_IDLE;
            end
            default: begin
                l_pulse        <= 1'b0;
                l_pulse_ctr_en <= 1'b0;

                l_STATE_next <= s_IDLE;
            end
        endcase
    end
endmodule
