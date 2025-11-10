`default_nettype none

module caravel_adc_wb_wrapper #(
  parameter ADC_SIZE = 12
)(
`ifdef USE_POWER_PINS
  inout vccd,
  inout vssd,
  inout vdda,
  inout vssa,
`endif
  input wb_clk_i,
  input wb_rst_i,
  input wbs_stb_i,
  input wbs_cyc_i,
  input wbs_we_i,
  input [3:0] wbs_sel_i,
  input [31:0] wbs_dat_i,
  input [31:0] wbs_adr_i,
  output wbs_ack_o,
  output [31:0] wbs_dat_o,

  // ADC analog inputs
  `ifdef cocotb
    input real adc_in,
    input real adc_vrefH,
    input real adc_vrefL,
    input real adc_vCM,
    input real adc_trim,
  `else
    input adc_in,     // GPIO 14 analog io 7
    input adc_vrefH,  // GPIO 16 analog io 9
    input adc_vrefL,  // GPIO 17 analog io 10
    input adc_vCM,    // GPIO 15 analog io 8
    input adc_trim,   // GPIO 13 analog io 6
  `endif

  output gpio_13_out,
  output gpio_13_oeb,
  output gpio_14_out,
  output gpio_14_oeb,
  output gpio_15_out,
  output gpio_15_oeb,
  output gpio_16_out,
  output gpio_16_oeb,
  output gpio_17_out,
  output gpio_17_oeb
);

  wire valid;
  wire write_enable;
  wire read_enable;
  reg wbs_ack_o_reg;
  reg [31:0] wbs_dat_o_reg;

  assign valid = wbs_cyc_i && wbs_stb_i;
  assign write_enable = wbs_we_i && valid;
  assign read_enable = ~wbs_we_i && valid;

  reg adc_en;
  reg adc_reset;
  reg adc_hold;
  reg adc_soc;
  reg [3:0] swidth;

  wire [ADC_SIZE-1:0] adc_data;
  wire adc_eoc;
  wire sample_n;
  wire dac_rst;
  wire adc_comp_out;
  wire [ADC_SIZE-1:0] dac_val;

  always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i) begin
      adc_en <= 1'b0;
      adc_reset <= 1'b0;
      adc_hold <= 1'b0;
      adc_soc <= 1'b0;
      swidth <= 4'd4;
    end else if (write_enable) begin
      case (wbs_adr_i[3:2])
        2'b00: begin
          if (wbs_sel_i[0]) begin
            adc_en <= wbs_dat_i[0];
            adc_reset <= wbs_dat_i[1];
            adc_hold <= wbs_dat_i[2];
            adc_soc <= wbs_dat_i[3];
          end
        end
        2'b01: begin
          if (wbs_sel_i[0]) begin
            swidth <= wbs_dat_i[3:0];
          end
        end
        default: begin
        end
      endcase
    end
  end

  always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i) begin
      wbs_dat_o_reg <= 32'h0;
    end else if (read_enable) begin
      case (wbs_adr_i[3:2])
        2'b00: wbs_dat_o_reg <= {28'h0, adc_soc, adc_hold, adc_reset, adc_en};
        2'b01: wbs_dat_o_reg <= {28'h0, swidth};
        2'b10: wbs_dat_o_reg <= {31'h0, adc_eoc};
        2'b11: wbs_dat_o_reg <= {{(32-ADC_SIZE){1'b0}}, adc_data};
        default: wbs_dat_o_reg <= 32'hDEADBEEF;
      endcase
    end
  end

  always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i)
      wbs_ack_o_reg <= 1'b0;
    else if (wbs_cyc_i && wbs_stb_i && ~wbs_ack_o_reg)
      wbs_ack_o_reg <= 1'b1;
    else
      wbs_ack_o_reg <= 1'b0;
  end

  assign wbs_ack_o = wbs_ack_o_reg;
  assign wbs_dat_o = wbs_dat_o_reg;

  sar_ctrl #(
    .SIZE(ADC_SIZE)
  ) sar_controller (
    .clk(wb_clk_i),
    .rst_n(~(wb_rst_i | adc_reset)),
    .soc(adc_soc),
    .cmp(adc_comp_out),
    .en(adc_en),
    .swidth(swidth),
    .sample_n(sample_n),
    .data(dac_val),
    .eoc(adc_eoc),
    .dac_rst(dac_rst)
  );

  assign adc_data = dac_val;

  sky130_ef_ip__adc3v_12bit adc_core (
`ifdef USE_POWER_PINS
    .vccd(vccd),
    .vssd(vssd),
    .vdda(vdda),
    .vssa(vssa),
`endif
    .adc_trim(adc_trim),
    .adc_vCM(adc_vCM),
    .adc_vrefL(adc_vrefL),
    .adc_vrefH(adc_vrefH),
    .adc_in(adc_in),
    .adc_ena(adc_en),
    .adc_reset(adc_reset),
    .adc_hold(~sample_n),
    .adc_dac_val(dac_val),
    .adc_comp_out(adc_comp_out)
  );

  assign gpio_13_out = 1'b0;
  assign gpio_13_oeb = 1'b1;
  assign gpio_14_out = 1'b0;
  assign gpio_14_oeb = 1'b1;
  assign gpio_15_out = 1'b0;
  assign gpio_15_oeb = 1'b1;
  assign gpio_16_out = 1'b0;
  assign gpio_16_oeb = 1'b1;
  assign gpio_17_out = 1'b0;
  assign gpio_17_oeb = 1'b1;

endmodule

`default_nettype wire
