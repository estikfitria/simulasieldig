`timescale 1ns/1ps
module tb_adaptive_beam_steering_unit;

    logic clk, rst_n;
    logic A_xray, B_dose, C_pos, D_temp, E_vib, F_power;
    logic Y1_table, Y2_gantry, Y3_filter, Y4_fan, Y5_shutter, Y6_relay_iso;
    logic [2:0] state_dbg;

    adaptive_beam_steering_unit dut(
        .clk(clk), .rst_n(rst_n),
        .A_xray(A_xray), .B_dose(B_dose), .C_pos(C_pos),
        .D_temp(D_temp), .E_vib(E_vib), .F_power(F_power),
        .Y1_table(Y1_table), .Y2_gantry(Y2_gantry), .Y3_filter(Y3_filter),
        .Y4_fan(Y4_fan), .Y5_shutter(Y5_shutter), .Y6_relay_iso(Y6_relay_iso),
        .state_dbg(state_dbg)
    );

    // ============================================
    // CLOCK
    // ============================================
    always #5 clk = ~clk;

    // ============================================
    // WAVEFORM DUMP — AGAR EPWAVE MUNCUL
    // ============================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_adaptive_beam_steering_unit);
    end

    // ============================================
    // TEST SEQUENCE
    // ============================================
    initial begin
        $display("==== TB START ====");

        clk = 0;
        rst_n = 0;
        A_xray = 0; B_dose = 0; C_pos = 0;
        D_temp = 0; E_vib = 0; F_power = 0;

        #20 rst_n = 1;

        #20 show();

        D_temp = 1; #20 show();
        D_temp = 0; #20 show();

        A_xray = 1; #20 show();
        A_xray = 0; #20 show();

        B_dose = 1; #20 show();
        B_dose = 0; #20 show();

        rst_n = 0; #20 rst_n = 1;

        #20 show();

        $display("==== TB END ====");
        $finish;
    end

    // DISPLAY TASK
    task show();
        $display("t=%0t | A B C D E F = %0d %0d %0d %0d %0d %0d | state=%b | Y=%0d%0d%0d%0d%0d%0d",
            $time,
            A_xray, B_dose, C_pos, D_temp, E_vib, F_power,
            state_dbg,
            Y1_table, Y2_gantry, Y3_filter, Y4_fan, Y5_shutter, Y6_relay_iso
        );
    endtask

endmodule