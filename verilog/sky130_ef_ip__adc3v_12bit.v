// SPDX-FileCopyrightText: 2025 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

/*--------------------------------------------------------------*/
/* Verilog behavioral model of 12-bit ADC                       */
/*                                                              */
/*                                                              */
/*                                                              */
/*--------------------------------------------------------------*/

`default_nettype none

// TODO layout is missing pins?
// TODO add bounds check to adc_vCM

module sky130_ef_ip__adc3v_12bit #(parameter FUNCTIONAL = 1)(
`ifdef USE_POWER_PINS
   inout       vccd,
   inout       vssd,
   inout       vdda,
   inout       vssa,
`endif
   input  real  adc_trim,
   input  real  adc_vCM,
   input  real  adc_vrefL,
   input  real  adc_vrefH,
   input  real  adc_in,
   input        adc_ena,
   input        adc_reset,
   input        adc_hold,
   input [11:0] adc_dac_val,
   output       adc_comp_out
);

generate
   if(FUNCTIONAL == 1) begin
      reg real dac_value;
      reg real held_value;

      assign out = dacvalue;

      initial begin
         dac_value <= 0;
      end
      
      initial begin
        held_value <= 0;
      end
      always @(posedge adc_hold)
        held_value = adc_in;

      always @* begin
         if (ena == 1'b1) begin
            dac_value <= adc_vrefL + adc_dac_val * (adc_vrefH - adc_vrefL) / 4069.0;
         end else begin
            dac_value <= 0;
         end
      end
      
      assign adc_comp_out = (held_value > dac_out) ? 1'b1 : 1'b0;
   end
endgenerate

endmodule
`default_nettype wire

