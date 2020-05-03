# File adapted from ot_srcs.mk to split dependencies up by module

OT_XBAR_SRCS := soc/opentitan/hw/top_earlgrey/ip/xbar_main/rtl/autogen/tl_main_pkg.sv
OT_XBAR_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv
OT_XBAR_SRCS += soc/opentitan/hw/top_earlgrey/ip/xbar_main/rtl/autogen/xbar_main.sv
OT_XBAR_SRCS += soc/opentitan/hw/top_earlgrey/ip/xbar_peri/rtl/autogen/tl_peri_pkg.sv
OT_XBAR_SRCS += soc/opentitan/hw/top_earlgrey/ip/xbar_peri/rtl/autogen/xbar_peri.sv

OT_RV_PLIC_SRCS += soc/opentitan/hw/top_earlgrey/ip/rv_plic/rtl/autogen/rv_plic_reg_pkg.sv
OT_RV_PLIC_SRCS += soc/opentitan/hw/top_earlgrey/ip/rv_plic/rtl/autogen/rv_plic_reg_top.sv
OT_RV_PLIC_SRCS += soc/opentitan/hw/top_earlgrey/ip/rv_plic/rtl/autogen/rv_plic.sv
OT_RV_PLIC_SRCS += soc/opentitan/hw/ip/rv_plic/rtl/rv_plic_gateway.sv
OT_RV_PLIC_SRCS += soc/opentitan/hw/ip/rv_plic/rtl/rv_plic_target.sv

OT_PINMUX_SRCS += soc/opentitan/hw/top_earlgrey/ip/pinmux/rtl/autogen/pinmux_reg_pkg.sv
OT_PINMUX_SRCS += soc/opentitan/hw/top_earlgrey/ip/pinmux/rtl/autogen/pinmux_reg_top.sv
OT_PINMUX_SRCS += soc/opentitan/hw/top_earlgrey/../ip/pinmux/rtl/pinmux.sv

OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/ip/alert_handler/rtl/autogen/alert_handler_reg_pkg.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/ip/alert_handler/rtl/autogen/alert_handler_reg_top.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_pkg.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler_reg_wrap.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler_class.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler_ping_timer.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler_esc_timer.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler_accu.sv
OT_ALERT_HANDLER_SRCS += soc/opentitan/hw/top_earlgrey/../ip/alert_handler/rtl/alert_handler.sv

OT_TOP_SRCS += soc/opentitan/hw/top_earlgrey/rtl/top_pkg.sv
OT_TOP_SRCS += soc/opentitan/hw/top_earlgrey/rtl/padctl.sv
OT_TOP_SRCS += soc/opentitan/hw/top_earlgrey/rtl/autogen/top_earlgrey.sv

OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart_reg_pkg.sv
OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart_reg_top.sv
OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart_rx.sv
OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart_tx.sv
OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart_core.sv
OT_UART_SRCS += soc/opentitan/hw/ip/uart/rtl/uart.sv

OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_clock_inverter.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_alert_receiver.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_alert_sender.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_arbiter.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_esc_receiver.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_esc_sender.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_sram_arbiter.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_fifo_async.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_fifo_sync.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_flop_2sync.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_lfsr.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_packer.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_pulse_sync.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_filter.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_filter_ctr.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_subreg.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_subreg_ext.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_intr_hw.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_secded_39_32_enc.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_secded_39_32_dec.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_ram_2p_adv.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_ram_2p_async_adv.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_ram_2p.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_ram_2p.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_xilinx/rtl/prim_xilinx_ram_2p.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_pkg.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/rtl/prim_diff_decode.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_pad_wrapper.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_pad_wrapper.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_xilinx/rtl/prim_xilinx_pad_wrapper.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_clock_mux2.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_clock_mux2.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_xilinx/rtl/prim_xilinx_clock_mux2.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_clock_gating.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_clock_gating.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_xilinx/rtl/prim_xilinx_clock_gating.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_ram_1p.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_ram_1p.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_rom.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_rom.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_xilinx/rtl/prim_xilinx_rom.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim/abstract/prim_flash.sv
OT_PRIM_SRCS += soc/opentitan/hw/ip/prim_generic/rtl/prim_generic_flash.sv

OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_err_resp.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_socket_1n.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_pkg.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_fifo_sync.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_fifo_async.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_assert.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_err.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_assert_multiple.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_socket_m1.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_adapter_sram.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/tlul_adapter_reg.sv
OT_TLUL_SRCS += soc/opentitan/hw/ip/tlul/rtl/sram2tlul.sv

OT_GPIO_SRCS += soc/opentitan/hw/ip/gpio/rtl/gpio_reg_pkg.sv
OT_GPIO_SRCS += soc/opentitan/hw/ip/gpio/rtl/gpio.sv
OT_GPIO_SRCS += soc/opentitan/hw/ip/gpio/rtl/gpio_reg_top.sv

OT_IBEX_SRCS += soc/opentitan/hw/ip/rv_core_ibex/rtl/rv_core_ibex.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_pkg.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_alu.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_compressed_decoder.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_controller.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_cs_registers.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_decoder.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_ex_block.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_fetch_fifo.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_id_stage.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_if_stage.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_load_store_unit.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_fast.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_multdiv_slow.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_prefetch_buffer.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_pmp.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_register_file_ff.sv
OT_IBEX_SRCS += soc/opentitan/hw/vendor/lowrisc_ibex/rtl/ibex_core.sv

OT_RV_DM_SRCS += soc/opentitan/hw/ip/rv_dm/rtl/rv_dm.sv
OT_RV_DM_SRCS += soc/opentitan/hw/ip/rv_dm/rtl/tlul_adapter_host.sv

OT_RV_TIMER_SRCS += soc/opentitan/hw/ip/rv_timer/rtl/rv_timer_reg_pkg.sv
OT_RV_TIMER_SRCS += soc/opentitan/hw/ip/rv_timer/rtl/rv_timer_reg_top.sv
OT_RV_TIMER_SRCS += soc/opentitan/hw/ip/rv_timer/rtl/timer_core.sv
OT_RV_TIMER_SRCS += soc/opentitan/hw/ip/rv_timer/rtl/rv_timer.sv

OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_device_reg_pkg.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_device_reg_top.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_device_pkg.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_fwm_rxf_ctrl.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_fwm_txf_ctrl.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_fwmode.sv
OT_SPI_DEVICE_SRCS += soc/opentitan/hw/ip/spi_device/rtl/spi_device.sv

OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_pkg.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_reg_pkg.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_reg_top.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_core.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_sub_bytes.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_sbox.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_sbox_lut.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_sbox_canright.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_shift_rows.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_mix_columns.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_mix_single_column.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_key_expand.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes_control.sv
OT_AES_SRCS += soc/opentitan/hw/ip/aes/rtl/aes.sv

OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/hmac_pkg.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/sha2.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/sha2_pad.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/hmac_reg_pkg.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/hmac_reg_top.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/hmac_core.sv
OT_HMAC_SRCS += soc/opentitan/hw/ip/hmac/rtl/hmac.sv

OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_pkg.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_reg_pkg.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl_reg_top.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_ctrl.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_erase_ctrl.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_prog_ctrl.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_rd_ctrl.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_mp.sv
OT_FLASH_CTRL_SRCS += soc/opentitan/hw/ip/flash_ctrl/rtl/flash_phy.sv

OT_NMI_GEN_SRCS += soc/opentitan/hw/ip/nmi_gen/rtl/nmi_gen_reg_pkg.sv
OT_NMI_GEN_SRCS += soc/opentitan/hw/ip/nmi_gen/rtl/nmi_gen_reg_top.sv
OT_NMI_GEN_SRCS += soc/opentitan/hw/ip/nmi_gen/rtl/nmi_gen.sv

# TODO: missing PULP platform debug stuff

OT_V_SRCS := ot_xbar.v
OT_V_SRCS += ot_rv_plic.v
OT_V_SRCS += ot_pinmux.v
OT_V_SRCS += ot_alert_handler.v
OT_V_SRCS += ot_top.v
OT_V_SRCS += ot_uart.v
OT_V_SRCS += ot_prim.v
OT_V_SRCS += ot_tlul.v
OT_V_SRCS += ot_gpio.v
OT_V_SRCS += ot_ibex.v
OT_V_SRCS += ot_rv_dm.v
OT_V_SRCS += ot_rv_timer.v
OT_V_SRCS += ot_spi_device.v
OT_V_SRCS += ot_aes.v
OT_V_SRCS += ot_hmac.v
OT_V_SRCS += ot_flash_ctrl.v
OT_V_SRCS += ot_nmi_gen.v

ot_xbar.v: $(OT_XBAR_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_rv_plic.v: $(OT_RV_PLIC_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_pinmux.v: $(OT_PINMUX_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_alert_handler.v: $(OT_ALERT_HANDLER_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_top.v: $(OT_TOP_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_uart.v: $(OT_UART_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_prim.v: $(OT_PRIM_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_tlul.v: $(OT_TLUL_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_gpio.v: $(OT_GPIO_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_ibex.v: $(OT_IBEX_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_rv_dm.v: $(OT_RV_DM_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_rv_timer.v: $(OT_RV_TIMER_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_spi_device.v: $(OT_SPI_DEVICE_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_aes.v: $(OT_AES_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_hmac.v: $(OT_HMAC_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_flash_ctrl.v: $(OT_FLASH_CTRL_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

ot_nmi_gen.v: $(OT_NMI_GEN_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE soc/opentitan/hw/vendor/lowrisc_ibex/shared/rtl/prim_assert.sv $^ > $@

vsources: $(OT_V_SRCS)

