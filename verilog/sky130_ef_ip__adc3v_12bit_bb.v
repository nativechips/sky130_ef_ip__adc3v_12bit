// SPDX-FileCopyrightText: 2025 Efabless Corporation
// SPDX-License-Identifier: Apache-2.0

// Blackbox definition for sky130_ef_ip__adc3v_12bit
// This is used for synthesis only - the actual implementation is a hard macro

`default_nettype none

(* blackbox *)
module sky130_ef_ip__adc3v_12bit #(parameter FUNCTIONAL = 1)(
`ifdef USE_POWER_PINS
   inout       vccd,
   inout       vssd,
   inout       vdda,
   inout       vssa,
`endif
   input        adc_trim,
   input        adc_vCM,
   input        adc_vrefL,
   input        adc_vrefH,
   input        adc_in,
   input        adc_ena,
   input        adc_reset,
   input        adc_hold,
   input [11:0] adc_dac_val,
   output       adc_comp_out
);

endmodule

`default_nettype wire
