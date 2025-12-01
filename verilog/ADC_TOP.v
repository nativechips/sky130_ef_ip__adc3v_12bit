module ADC_TOP (
`ifdef USE_POWER_PINS
    inout AVPWR,
    inout AVGND,
    inout DVPWR,
    inout DVGND,
    input VSUB, // Should be connected to digital ground
`endif
    input adc_in,

    input ena_follower_amp,
    input ena_res_div,
    input ena_adc,
    input adc_reset,
    input adc_hold,
    input [11:0] adc_dac_val,
    output adc_cmp
);

res_div res_div_inst (
`ifdef USE_POWER_PINS
    .vdda  (AVPWR),
    .vssa  (AVGND),
    .vsub  (VSUB),
    .vref  (adc_vref)
`endif
);

follower_amp follower_amp_inst (
`ifdef USE_POWER_PINS
    .vdd  (AVPWR),
    .vss  (AVGND),
    .vsub (VSUB),
`endif
    .in   (adc_vref),
    .out  (adc_vref_buf),
    .ena  (ena_follower_amp)
);

sky130_ef_ip__adc3v_12bit adc_inst (
`ifdef USE_POWER_PINS
    .vccd0  (DVPWR),
    .vssd0  (DVGND),
    .vdda0  (AVPWR),
    .vssa0  (AVGND),
`endif

    .adc_trim   (AVGND),
    .adc_vCM    (adc_vref_buf),
    .adc_vrefL  (AVGND),
    .adc_vrefH  (AVPWR),
    .adc_in     (adc_in),

    .adc_ena        (ena_adc),
    .adc_reset      (adc_reset),
    .adc_hold       (adc_hold),
    .adc_dac_val    (adc_dac_val),
    .adc_comp_out   (adc_cmp)
);

endmodule