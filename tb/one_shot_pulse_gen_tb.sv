`timescale 1ns / 1ps

// File :            one_shot_pulse_gen_tb.sv
// Title :           one_shot_pulse_gen_tb
//
// Author(s) :       AUTHOR
//
// Description :     DESCRIPTION
//
//                   Hex stimulus data is pulled from the local text file
//                   "tb_stim.txt" which is read into memory "l_tb_stim"
//                   whose depth and width are defined by localparams: 
//
//                       - 'p_STIM_CNT'   (MEMORY DEPTH)
//                       - 'p_STIM_WIDTH' (MEMORY WIDTH)
//
//                   A memory with STIM_CNT=4 / p_STIM_WIDTH=32 can
//                   be visualized as follows:
//
//                         |---------- 32 ---------|
//
//                   ---   -------------------------
//                    |    | B3  | B2  | B1  | B0  | (l_tb_stim[0])
//                    |    -------------------------
//                    |    | B7  | B6  | B5  | B4  | (l_tb_stim[1])
//                    4    -------------------------
//                    |    | ..  | ..  | ..  | ..  | (l_tb_stim[2])
//                    |    -------------------------
//                    |    | B15 | ..  | ..  | ..  | (l_tb_stim[3])
//                   ---   -------------------------
//
//                   Lastly, RTL testbench files are broken into sections
//                   for better readability and "ctrl+f" navigation: 
//
//                       - '(A) DECLARATIONS'
//                       - '(B) INSTANTIATES'
//                       - '(C) STIMULUS GEN'
//                       - '(D) HELPER TASKS'
//
// Revisions
//
// Date        Name            REV#        Description
// ----------  --------------- ----------- --------------------
// (XX/XX/XX)  AUTHOR          1.0         Initial Revision

module one_shot_pulse_gen_tb ();

    // =========================
    // --  (A) DECLARATIONS   --
    // =========================

    // Configurable sim parameters
    localparam p_CLK_PERIOD    = 10;          // Value x Timescale, E.G. 10 x 1ns = 10ns period
    localparam p_STIM_CNT      = 10;          // Number of stimulus entries in the text file
    localparam p_STIM_WIDTH    = 32;          // Width of the stimulus data in the text file

    localparam p_MEM_WIDTH = p_STIM_WIDTH;
    localparam p_MEM_DEPTH = p_STIM_CNT;

    integer int_ERR_COUNT;

    logic l_clk;
    logic l_rst_n;

    logic [p_MEM_WIDTH-1:0] l_tb_stim [p_MEM_DEPTH-1:0];

    // Declare your DUT wires/registers
    // and initialize them in "init();"

    integer int_TST_INDEX;
    integer int_CLK_COUNT;

    logic l_go;
    logic l_stop;
    wire  w_pulse;

    // =========================
    // --  (B) INSTANTIATES   --
    // =========================

    // Instantiate your DUT
    one_shot_pulse_gen #
    (
         .p_PULSE_LENGTH (5)
    )
    inst_one_shot_pulse_gen
    (
         .i_clk     (l_clk),
         .i_rst_n   (l_rst_n),

         .i_go      (l_go),
         .i_stop    (l_stop),

         .o_pulse   (w_pulse)
    );

    // =========================
    // --  (C) STIMULUS GEN   --
    // =========================

    // Clock generator
    always begin
        #(p_CLK_PERIOD/2); l_clk <= ~l_clk;
    end

    // Stimulus generator
    initial begin

        // Initialization sequence
        init();
        strobe_rst_n();

        // Test case #1: Single strobe of "go", module responds uninterrupted
        // by "stop" control
        int_TST_INDEX = 1;

        l_go <= 1'b1;
        #p_CLK_PERIOD;
        l_go <= 1'b0;

        wait_500ns();

        // Test case #2: Single strobe of "go", module interrupted by "stop"
        // control after two clock cycles
        int_TST_INDEX = 2;

        l_go <= 1'b1;
        #p_CLK_PERIOD;
        l_go <= 1'b0;
        #(p_CLK_PERIOD*2);
        l_stop <= 1'b1;
        #p_CLK_PERIOD;
        l_stop <= 1'b0;
        
        wait_500ns();

    end

    // Assertion checker
    initial begin

        // Test case #1
        int_CLK_COUNT <= 0;
        wait (int_TST_INDEX == 1 && w_pulse == 1'b1);
        $display("Test #1: Pulse goes high", $time);
        while (w_pulse == 1'b1) begin
            @(posedge l_clk) begin
            int_CLK_COUNT++;
            end
        end
        $display("Test #1: Pulse goes low", $time);
        assert(int_CLK_COUNT > 4 && int_CLK_COUNT < 7) $display("Test 1: PASS");
            else $error("Test 1: FAIL");

        // Test case #2
        int_CLK_COUNT <= 0;
        wait (int_TST_INDEX == 2 && w_pulse == 1'b1);
        $display("Test #2: Pulse goes high", $time);
        while (w_pulse == 1'b1) begin
            @(posedge l_clk) begin
            int_CLK_COUNT++;
            end
        end
        $display("Test #2: Pulse goes low", $time);
        assert(int_CLK_COUNT > 0 && int_CLK_COUNT < 4) $display("Test 2: PASS");
            else $error("Test 2: FAIL");
            $display("CLK_COUNT: %d", int_CLK_COUNT);
    end

    // =========================
    // --  (D) HELPER TASKS   --
    // =========================

    // The first function called during the init sequence for setting 
    // up simulation values
    task init(); begin

        // Reads in the stimulus input from the local text file
        $readmemh("tb_stim.txt", l_tb_stim, 0, p_STIM_CNT-1);

        int_ERR_COUNT        <= 0;
        l_clk                <= 1'b1;
        l_rst_n              <= 1'b1;

        // Insert your testbench DUT register initial values
        l_go                 <= 1'b0;
        l_stop               <= 1'b0;
    end
    endtask

    // The second function called during the init sequence, setting
    // up stimulus data to be applied a 1/2-cycle before the clock's rising edge
    task strobe_rst_n(); begin
        l_rst_n <= 1'b0;
        #(p_CLK_PERIOD*500);
        l_rst_n <= 1'b1;
        #((p_CLK_PERIOD*500)-(p_CLK_PERIOD/2));
    end
    endtask

    // A (very) useful checker for creating a self-checking testbench
    // task assert_CONDITION(); begin
    //     if (CONDITION) begin
    //         $display ("ERROR");
    //         int_ERR_COUNT <= int_ERR_COUNT + 1;
    //     end else begin
    //         $display ("PASS");
    //     end
    // end
    // endtask

    task wait_500ns(); begin
        #(p_CLK_PERIOD*500);
    end
    endtask

endmodule
