`timescale 1ns/1ps
module adaptive_beam_steering_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic A_xray,
    input  logic B_dose,
    input  logic C_pos,
    input  logic D_temp,
    input  logic E_vib,
    input  logic F_power,
    output logic Y1_table,
    output logic Y2_gantry,
    output logic Y3_filter,
    output logic Y4_fan,
    output logic Y5_shutter,
    output logic Y6_relay_iso,
    output logic [2:0] state_dbg
);

    typedef enum logic [2:0] {
        S0_INIT  = 3'b000,
        S1_NORMAL= 3'b001,
        S2_WARN  = 3'b010,
        S3_FAULT = 3'b011,
        S4_EMG   = 3'b100
    } state_t;

    state_t state, next_state;

    logic emg, fault, warn, all_ok;

    always_comb begin
        emg    = B_dose | F_power;
        fault  = A_xray | C_pos;
        warn   = D_temp | E_vib;
        all_ok = ~(emg | fault | warn);
    end

    always_comb begin
        next_state = state;
        unique case (state)
            S0_INIT: begin
                if (!rst_n) next_state = S0_INIT;
                else if (emg) next_state = S4_EMG;
                else if (fault) next_state = S3_FAULT;
                else if (warn) next_state = S2_WARN;
                else next_state = S1_NORMAL;
            end
            S1_NORMAL: begin
                if (emg) next_state = S4_EMG;
                else if (fault) next_state = S3_FAULT;
                else if (warn) next_state = S2_WARN;
                else next_state = S1_NORMAL;
            end
            S2_WARN: begin
                if (emg) next_state = S4_EMG;
                else if (fault) next_state = S3_FAULT;
                else if (all_ok) next_state = S1_NORMAL;
                else next_state = S2_WARN;
            end
            S3_FAULT: begin
                if (emg) next_state = S4_EMG;
                else if (all_ok) next_state = S1_NORMAL;
                else next_state = S3_FAULT;
            end
            S4_EMG: begin
                if (!rst_n) next_state = S0_INIT;
                else next_state = S4_EMG;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S0_INIT;
        else        state <= next_state;
    end

    always_comb begin
        Y1_table = 0;
        Y2_gantry = 0;
        Y3_filter = 0;
        Y4_fan = 0;
        Y5_shutter = 0;
        Y6_relay_iso = 0;

        unique case (state)
            S0_INIT: begin
                Y5_shutter = 1;
                Y6_relay_iso = 1;
            end
            S1_NORMAL: begin
                Y1_table = 1;
                Y2_gantry = 1;
                Y3_filter = 1;
            end
            S2_WARN: begin
                Y1_table = 1;
                Y2_gantry = ~E_vib;
                Y3_filter = 1;
                Y4_fan = 1;
            end
            S3_FAULT: begin
                Y4_fan = 1;
                Y5_shutter = 1;
                Y6_relay_iso = 1;
            end
            S4_EMG: begin
                Y4_fan = 1;
                Y5_shutter = 1;
                Y6_relay_iso = 1;
            end
        endcase
    end

    assign state_dbg = state;

endmodule