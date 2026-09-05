	component dmasoc_system is
		port (
			clk_clk                   : in    std_logic                     := 'X';             -- clk
			memory_mem_a              : out   std_logic_vector(12 downto 0);                    -- mem_a
			memory_mem_ba             : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck             : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n           : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke            : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n           : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n          : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n          : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n           : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n        : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq             : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dq
			memory_mem_dqs            : inout std_logic                     := 'X';             -- mem_dqs
			memory_mem_dqs_n          : inout std_logic                     := 'X';             -- mem_dqs_n
			memory_mem_odt            : out   std_logic;                                        -- mem_odt
			memory_mem_dm             : out   std_logic;                                        -- mem_dm
			memory_oct_rzqin          : in    std_logic                     := 'X';             -- oct_rzqin
			pll_0_locked_export       : out   std_logic;                                        -- export
			dma_out_data              : out   std_logic_vector(15 downto 0);                    -- data
			dma_out_valid             : out   std_logic;                                        -- valid
			dma_out_ready             : in    std_logic                     := 'X';             -- ready
			dma_out_startofpacket     : out   std_logic;                                        -- startofpacket
			dma_out_endofpacket       : out   std_logic;                                        -- endofpacket
			dma_out_empty             : out   std_logic;                                        -- empty
			h2f_mpu_events_eventi     : in    std_logic                     := 'X';             -- eventi
			h2f_mpu_events_evento     : out   std_logic;                                        -- evento
			h2f_mpu_events_standbywfe : out   std_logic_vector(1 downto 0);                     -- standbywfe
			h2f_mpu_events_standbywfi : out   std_logic_vector(1 downto 0);                     -- standbywfi
			msgdma_clk_out_clk        : out   std_logic;                                        -- clk
			msgdma_reset_n_out_reset  : out   std_logic                                         -- reset
		);
	end component dmasoc_system;

	u0 : component dmasoc_system
		port map (
			clk_clk                   => CONNECTED_TO_clk_clk,                   --                clk.clk
			memory_mem_a              => CONNECTED_TO_memory_mem_a,              --             memory.mem_a
			memory_mem_ba             => CONNECTED_TO_memory_mem_ba,             --                   .mem_ba
			memory_mem_ck             => CONNECTED_TO_memory_mem_ck,             --                   .mem_ck
			memory_mem_ck_n           => CONNECTED_TO_memory_mem_ck_n,           --                   .mem_ck_n
			memory_mem_cke            => CONNECTED_TO_memory_mem_cke,            --                   .mem_cke
			memory_mem_cs_n           => CONNECTED_TO_memory_mem_cs_n,           --                   .mem_cs_n
			memory_mem_ras_n          => CONNECTED_TO_memory_mem_ras_n,          --                   .mem_ras_n
			memory_mem_cas_n          => CONNECTED_TO_memory_mem_cas_n,          --                   .mem_cas_n
			memory_mem_we_n           => CONNECTED_TO_memory_mem_we_n,           --                   .mem_we_n
			memory_mem_reset_n        => CONNECTED_TO_memory_mem_reset_n,        --                   .mem_reset_n
			memory_mem_dq             => CONNECTED_TO_memory_mem_dq,             --                   .mem_dq
			memory_mem_dqs            => CONNECTED_TO_memory_mem_dqs,            --                   .mem_dqs
			memory_mem_dqs_n          => CONNECTED_TO_memory_mem_dqs_n,          --                   .mem_dqs_n
			memory_mem_odt            => CONNECTED_TO_memory_mem_odt,            --                   .mem_odt
			memory_mem_dm             => CONNECTED_TO_memory_mem_dm,             --                   .mem_dm
			memory_oct_rzqin          => CONNECTED_TO_memory_oct_rzqin,          --                   .oct_rzqin
			pll_0_locked_export       => CONNECTED_TO_pll_0_locked_export,       --       pll_0_locked.export
			dma_out_data              => CONNECTED_TO_dma_out_data,              --            dma_out.data
			dma_out_valid             => CONNECTED_TO_dma_out_valid,             --                   .valid
			dma_out_ready             => CONNECTED_TO_dma_out_ready,             --                   .ready
			dma_out_startofpacket     => CONNECTED_TO_dma_out_startofpacket,     --                   .startofpacket
			dma_out_endofpacket       => CONNECTED_TO_dma_out_endofpacket,       --                   .endofpacket
			dma_out_empty             => CONNECTED_TO_dma_out_empty,             --                   .empty
			h2f_mpu_events_eventi     => CONNECTED_TO_h2f_mpu_events_eventi,     --     h2f_mpu_events.eventi
			h2f_mpu_events_evento     => CONNECTED_TO_h2f_mpu_events_evento,     --                   .evento
			h2f_mpu_events_standbywfe => CONNECTED_TO_h2f_mpu_events_standbywfe, --                   .standbywfe
			h2f_mpu_events_standbywfi => CONNECTED_TO_h2f_mpu_events_standbywfi, --                   .standbywfi
			msgdma_clk_out_clk        => CONNECTED_TO_msgdma_clk_out_clk,        --     msgdma_clk_out.clk
			msgdma_reset_n_out_reset  => CONNECTED_TO_msgdma_reset_n_out_reset   -- msgdma_reset_n_out.reset
		);

