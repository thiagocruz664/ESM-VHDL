
module dmasoc_system (
	clk_clk,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	pll_0_locked_export,
	dma_out_data,
	dma_out_valid,
	dma_out_ready,
	dma_out_startofpacket,
	dma_out_endofpacket,
	dma_out_empty,
	h2f_mpu_events_eventi,
	h2f_mpu_events_evento,
	h2f_mpu_events_standbywfe,
	h2f_mpu_events_standbywfi,
	msgdma_clk_out_clk,
	msgdma_reset_n_out_reset);	

	input		clk_clk;
	output	[12:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[7:0]	memory_mem_dq;
	inout		memory_mem_dqs;
	inout		memory_mem_dqs_n;
	output		memory_mem_odt;
	output		memory_mem_dm;
	input		memory_oct_rzqin;
	output		pll_0_locked_export;
	output	[15:0]	dma_out_data;
	output		dma_out_valid;
	input		dma_out_ready;
	output		dma_out_startofpacket;
	output		dma_out_endofpacket;
	output		dma_out_empty;
	input		h2f_mpu_events_eventi;
	output		h2f_mpu_events_evento;
	output	[1:0]	h2f_mpu_events_standbywfe;
	output	[1:0]	h2f_mpu_events_standbywfi;
	output		msgdma_clk_out_clk;
	output		msgdma_reset_n_out_reset;
endmodule
