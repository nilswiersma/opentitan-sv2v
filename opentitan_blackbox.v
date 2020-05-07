(* blackbox *)
module prim_flash (
	clk_i,
	rst_ni,
	req_i,
	host_req_i,
	host_addr_i,
	rd_i,
	prog_i,
	pg_erase_i,
	bk_erase_i,
	addr_i,
	prog_data_i,
	host_req_rdy_o,
	host_req_done_o,
	rd_done_o,
	prog_done_o,
	erase_done_o,
	rd_data_o,
	init_busy_o
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	parameter signed [31:0] PagesPerBank = 256;
	parameter signed [31:0] WordsPerPage = 256;
	parameter signed [31:0] DataWidth = 32;
	parameter signed [31:0] PageW = $clog2(PagesPerBank);
	parameter signed [31:0] WordW = $clog2(WordsPerPage);
	parameter signed [31:0] AddrW = PageW + WordW;
	input clk_i;
	input rst_ni;
	input req_i;
	input host_req_i;
	input [AddrW - 1:0] host_addr_i;
	input rd_i;
	input prog_i;
	input pg_erase_i;
	input bk_erase_i;
	input [AddrW - 1:0] addr_i;
	input [DataWidth - 1:0] prog_data_i;
	output wire host_req_rdy_o;
	output wire host_req_done_o;
	output wire rd_done_o;
	output wire prog_done_o;
	output wire erase_done_o;
	output wire [DataWidth - 1:0] rd_data_o;
	output wire init_busy_o;
	localparam ImplGeneric = 0;
	localparam ImplXilinx = 1;
	generate
		if ((Impl == ImplGeneric) || (Impl == ImplXilinx)) begin : gen_flash
			prim_generic_flash #(
				.PagesPerBank(PagesPerBank),
				.WordsPerPage(WordsPerPage),
				.DataWidth(DataWidth)
			) u_impl_generic(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(req_i),
				.host_req_i(host_req_i),
				.host_addr_i(host_addr_i),
				.rd_i(rd_i),
				.prog_i(prog_i),
				.pg_erase_i(pg_erase_i),
				.bk_erase_i(bk_erase_i),
				.addr_i(addr_i),
				.prog_data_i(prog_data_i),
				.host_req_rdy_o(host_req_rdy_o),
				.host_req_done_o(host_req_done_o),
				.rd_done_o(rd_done_o),
				.prog_done_o(prog_done_o),
				.erase_done_o(erase_done_o),
				.rd_data_o(rd_data_o),
				.init_busy_o(init_busy_o)
			);
		end
	endgenerate
endmodule

(* blackbox *)
module prim_generic_flash (
	clk_i,
	rst_ni,
	req_i,
	host_req_i,
	host_addr_i,
	rd_i,
	prog_i,
	pg_erase_i,
	bk_erase_i,
	addr_i,
	prog_data_i,
	host_req_rdy_o,
	host_req_done_o,
	rd_done_o,
	prog_done_o,
	erase_done_o,
	rd_data_o,
	init_busy_o
);
	localparam [2:0] StReset = 'h0;
	localparam [2:0] StInit = 'h1;
	localparam [2:0] StIdle = 'h2;
	localparam [2:0] StHostRead = 'h3;
	localparam [2:0] StRead = 'h4;
	localparam [2:0] StProg = 'h5;
	localparam [2:0] StErase = 'h6;
	parameter signed [31:0] PagesPerBank = 256;
	parameter signed [31:0] WordsPerPage = 256;
	parameter signed [31:0] DataWidth = 32;
	parameter SkipInit = 1;
	localparam signed [31:0] PageW = $clog2(PagesPerBank);
	localparam signed [31:0] WordW = $clog2(WordsPerPage);
	localparam signed [31:0] AddrW = PageW + WordW;
	input clk_i;
	input rst_ni;
	input req_i;
	input host_req_i;
	input [AddrW - 1:0] host_addr_i;
	input rd_i;
	input prog_i;
	input pg_erase_i;
	input bk_erase_i;
	input [AddrW - 1:0] addr_i;
	input [DataWidth - 1:0] prog_data_i;
	output reg host_req_rdy_o;
	output reg host_req_done_o;
	output reg rd_done_o;
	output reg prog_done_o;
	output reg erase_done_o;
	output wire [DataWidth - 1:0] rd_data_o;
	output reg init_busy_o;
	localparam signed [31:0] ReadCycles = 1;
	localparam signed [31:0] ProgCycles = 50;
	localparam signed [31:0] PgEraseCycles = 200;
	localparam signed [31:0] BkEraseCycles = 2000;
	localparam signed [31:0] WordsPerBank = PagesPerBank * WordsPerPage;
	reg [2:0] st_next;
	reg [2:0] st;
	reg [31:0] time_cnt;
	reg [31:0] index_cnt;
	reg time_cnt_inc;
	reg time_cnt_clr;
	reg time_cnt_set1;
	reg index_cnt_inc;
	reg index_cnt_clr;
	reg [31:0] index_limit;
	reg [31:0] index_limit_next;
	reg [31:0] time_limit;
	reg [31:0] time_limit_next;
	reg prog_pend;
	reg prog_pend_next;
	reg mem_req;
	reg mem_wr;
	reg [AddrW - 1:0] mem_addr;
	reg [DataWidth - 1:0] held_data;
	reg [DataWidth - 1:0] mem_wdata;
	reg hold_rd_cmd;
	reg [AddrW - 1:0] held_rd_addr;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			st <= StReset;
		else
			st <= st_next;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			held_rd_addr <= 1'sb0;
		else if (hold_rd_cmd)
			held_rd_addr <= host_addr_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			time_cnt <= 32'h0;
			index_cnt <= 32'h0;
			time_limit <= 32'h0;
			index_limit <= 32'h0;
			held_data <= 'h0;
			prog_pend <= 1'h0;
		end
		else begin
			time_limit <= time_limit_next;
			index_limit <= index_limit_next;
			prog_pend <= prog_pend_next;
			if (time_cnt_inc)
				time_cnt <= time_cnt + 1'b1;
			else if (time_cnt_set1)
				time_cnt <= 32'h1;
			else if (time_cnt_clr)
				time_cnt <= 32'h0;
			if (index_cnt_inc)
				index_cnt <= index_cnt + 1'b1;
			else if (index_cnt_clr)
				index_cnt <= 32'h0;
			if (prog_pend)
				held_data <= rd_data_o;
		end
	always @(*) begin
		st_next = st;
		index_limit_next = index_limit;
		time_limit_next = time_limit;
		prog_pend_next = prog_pend;
		mem_req = 'h0;
		mem_wr = 'h0;
		mem_addr = 'h0;
		mem_wdata = 'h0;
		time_cnt_inc = 1'h0;
		time_cnt_clr = 1'h0;
		time_cnt_set1 = 1'h0;
		index_cnt_inc = 1'h0;
		index_cnt_clr = 1'h0;
		rd_done_o = 1'h0;
		prog_done_o = 1'h0;
		erase_done_o = 1'h0;
		init_busy_o = 1'h0;
		host_req_rdy_o = 1'h1;
		host_req_done_o = 1'h0;
		hold_rd_cmd = 1'h0;
		case (st)
			StReset: begin
				host_req_rdy_o = 1'b0;
				init_busy_o = 1'h1;
				st_next = StInit;
			end
			StInit: begin
				host_req_rdy_o = 1'b0;
				init_busy_o = 1'h1;
				if ((index_cnt < WordsPerBank) && !SkipInit) begin
					st_next = StInit;
					index_cnt_inc = 1'b1;
					mem_req = 1'h0;
					mem_wr = 1'h0;
					mem_addr = index_cnt[AddrW - 1:0];
					mem_wdata = {DataWidth {1'b1}};
				end
				else begin
					st_next = StIdle;
					index_cnt_clr = 1'b1;
				end
			end
			StIdle:
				if (host_req_i) begin
					hold_rd_cmd = 1'b1;
					mem_addr = host_addr_i;
					mem_req = 1'b1;
					time_cnt_inc = 1'b1;
					st_next = StHostRead;
				end
				else if (req_i && rd_i)
					st_next = StRead;
				else if (req_i && prog_i) begin
					st_next = StRead;
					prog_pend_next = 1'b1;
				end
				else if (req_i && pg_erase_i) begin
					st_next = StErase;
					index_limit_next = WordsPerPage;
					time_limit_next = PgEraseCycles;
				end
				else if (req_i && bk_erase_i) begin
					st_next = StErase;
					index_limit_next = WordsPerBank;
					time_limit_next = BkEraseCycles;
				end
			StHostRead: begin
				mem_addr = held_rd_addr;
				if (time_cnt < ReadCycles) begin
					mem_req = 1'b1;
					time_cnt_inc = 1'b1;
					host_req_rdy_o = 1'b0;
				end
				else begin
					host_req_done_o = 1'b1;
					if (host_req_i) begin
						hold_rd_cmd = 1'b1;
						mem_addr = host_addr_i;
						mem_req = 1'b1;
						time_cnt_set1 = 1'b1;
						st_next = StHostRead;
					end
					else begin
						time_cnt_clr = 1'b1;
						st_next = StIdle;
					end
				end
			end
			StRead: begin
				host_req_rdy_o = 1'b0;
				mem_addr = addr_i;
				if (time_cnt < ReadCycles) begin
					mem_req = 1'b1;
					time_cnt_inc = 1'b1;
				end
				else begin
					prog_pend_next = 1'b0;
					rd_done_o = 1'b1;
					time_cnt_clr = 1'b1;
					st_next = (prog_pend ? StProg : StIdle);
				end
			end
			StProg: begin
				host_req_rdy_o = 1'b0;
				mem_addr = addr_i;
				mem_wdata = prog_data_i & held_data;
				if (time_cnt < ProgCycles) begin
					mem_req = 1'b1;
					mem_wr = 1'b1;
					time_cnt_inc = 1'b1;
				end
				else begin
					st_next = StIdle;
					prog_done_o = 1'b1;
					time_cnt_clr = 1'b1;
				end
			end
			StErase: begin
				host_req_rdy_o = 1'b0;
				if ((index_cnt < index_limit) || (time_cnt < time_limit)) begin
					mem_req = 1'b1;
					mem_wr = 1'b1;
					mem_wdata = {DataWidth {1'b1}};
					mem_addr = addr_i + index_cnt[AddrW - 1:0];
					time_cnt_inc = time_cnt < time_limit;
					index_cnt_inc = index_cnt < index_limit;
				end
				else begin
					st_next = StIdle;
					erase_done_o = 1'b1;
					time_cnt_clr = 1'b1;
					index_cnt_clr = 1'b1;
				end
			end
			default: begin
				host_req_rdy_o = 1'b0;
				st_next = StIdle;
			end
		endcase
	end
	prim_ram_1p #(
		.Width(DataWidth),
		.Depth(WordsPerBank),
		.DataBitsPerMask(DataWidth)
	) u_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(mem_req),
		.write_i(mem_wr),
		.addr_i(mem_addr),
		.wdata_i(mem_wdata),
		.wmask_i({DataWidth {1'b1}}),
		.rvalid_o(),
		.rdata_o(rd_data_o)
	);
endmodule

(* blackbox *)
module flash_mp (
	clk_i,
	rst_ni,
	region_cfgs_i,
	bank_cfgs_i,
	req_i,
	req_addr_i,
	addr_ovfl_i,
	req_bk_i,
	rd_i,
	prog_i,
	pg_erase_i,
	bk_erase_i,
	rd_done_o,
	prog_done_o,
	erase_done_o,
	error_o,
	err_addr_o,
	err_bank_o,
	req_o,
	rd_o,
	prog_o,
	pg_erase_o,
	bk_erase_o,
	rd_done_i,
	prog_done_i,
	erase_done_i
);
	localparam top_pkg_FLASH_BANKS = 2;
	localparam top_pkg_FLASH_PAGES_PER_BANK = 256;
	parameter signed [31:0] MpRegions = 8;
	parameter signed [31:0] NumBanks = 2;
	parameter signed [31:0] AllPagesW = 16;
	localparam signed [31:0] TotalRegions = MpRegions + 1;
	localparam signed [31:0] BankW = $clog2(NumBanks);
	input clk_i;
	input rst_ni;
	input wire [((TotalRegions - 1) >= 0 ? (TotalRegions * 22) + -1 : ((2 - TotalRegions) * 22) + (((TotalRegions - 1) * 22) - 1)):((TotalRegions - 1) >= 0 ? 0 : (TotalRegions - 1) * 22)] region_cfgs_i;
	input wire [((NumBanks - 1) >= 0 ? NumBanks + -1 : (2 - NumBanks) + ((NumBanks - 1) - 1)):((NumBanks - 1) >= 0 ? 0 : NumBanks - 1)] bank_cfgs_i;
	input req_i;
	input [AllPagesW - 1:0] req_addr_i;
	input addr_ovfl_i;
	input [BankW - 1:0] req_bk_i;
	input rd_i;
	input prog_i;
	input pg_erase_i;
	input bk_erase_i;
	output wire rd_done_o;
	output wire prog_done_o;
	output wire erase_done_o;
	output wire error_o;
	output reg [AllPagesW - 1:0] err_addr_o;
	output reg [BankW - 1:0] err_bank_o;
	output wire req_o;
	output wire rd_o;
	output wire prog_o;
	output wire pg_erase_o;
	output wire bk_erase_o;
	input rd_done_i;
	input prog_done_i;
	input erase_done_i;
	localparam signed [31:0] FlashTotalPages = top_pkg_FLASH_BANKS * top_pkg_FLASH_PAGES_PER_BANK;
	localparam [0:0] PageErase = 0;
	localparam [0:0] BankErase = 1;
	localparam [0:0] WriteDir = 1'b0;
	localparam [0:0] ReadDir = 1'b1;
	localparam [1:0] FlashRead = 2'h0;
	localparam [1:0] FlashProg = 2'h1;
	localparam [1:0] FlashErase = 2'h2;
	reg [AllPagesW - 1:0] region_end [0:TotalRegions - 1];
	reg [TotalRegions - 1:0] region_match;
	wire [TotalRegions - 1:0] region_sel;
	reg [TotalRegions - 1:0] rd_en;
	reg [TotalRegions - 1:0] prog_en;
	reg [TotalRegions - 1:0] pg_erase_en;
	reg [NumBanks - 1:0] bk_erase_en;
	wire final_rd_en;
	wire final_prog_en;
	wire final_pg_erase_en;
	wire final_bk_erase_en;
	assign region_sel[0] = region_match[0];
	generate
		genvar i;
		for (i = 1; i < TotalRegions; i = i + 1) begin : gen_region_priority
			assign region_sel[i] = region_match[i] & ~|region_match[i - 1:0];
		end
	endgenerate
	always @(*) begin : sv2v_autoblock_890
		reg [31:0] i;
		for (i = 0; i < TotalRegions; i = i + 1)
			begin : region_comps
				region_end[i] = region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 17-:9] + region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 8-:9];
				region_match[i] = ((req_addr_i >= region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 17-:9]) & (req_addr_i < region_end[i])) & req_i;
				rd_en[i] = (region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 21] & region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 20]) & region_sel[i];
				prog_en[i] = (region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 21] & region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 19]) & region_sel[i];
				pg_erase_en[i] = (region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 21] & region_cfgs_i[(((TotalRegions - 1) >= 0 ? i : 0 - (i - (TotalRegions - 1))) * 22) + 18]) & region_sel[i];
			end
	end
	always @(*) begin : sv2v_autoblock_891
		reg [31:0] i;
		for (i = 0; i < NumBanks; i = i + 1)
			begin : bank_comps
				bk_erase_en[i] = (req_bk_i == i) & bank_cfgs_i[((NumBanks - 1) >= 0 ? i : 0 - (i - (NumBanks - 1)))];
			end
	end
	assign final_rd_en = rd_i & |rd_en;
	assign final_prog_en = prog_i & |prog_en;
	assign final_pg_erase_en = pg_erase_i & |pg_erase_en;
	assign final_bk_erase_en = bk_erase_i & |bk_erase_en;
	assign rd_o = req_i & final_rd_en;
	assign prog_o = req_i & final_prog_en;
	assign pg_erase_o = req_i & final_pg_erase_en;
	assign bk_erase_o = req_i & final_bk_erase_en;
	assign req_o = ((rd_o | prog_o) | pg_erase_o) | bk_erase_o;
	reg txn_err;
	wire txn_ens;
	wire no_allowed_txn;
	assign txn_ens = ((final_rd_en | final_prog_en) | final_pg_erase_en) | final_bk_erase_en;
	assign no_allowed_txn = req_i & (addr_ovfl_i | ~txn_ens);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			txn_err <= 1'b0;
			err_addr_o <= 1'sb0;
			err_bank_o <= 1'sb0;
		end
		else if (txn_err)
			txn_err <= 1'b0;
		else if (no_allowed_txn) begin
			txn_err <= 1'b1;
			err_addr_o <= req_addr_i;
			err_bank_o <= req_bk_i;
		end
	assign rd_done_o = rd_done_i | txn_err;
	assign prog_done_o = prog_done_i | txn_err;
	assign erase_done_o = erase_done_i | txn_err;
	assign error_o = txn_err;
endmodule

(* blackbox *)
module prim_ram_2p_adv (
	clk_i,
	rst_ni,
	a_req_i,
	a_write_i,
	a_addr_i,
	a_wdata_i,
	a_rvalid_o,
	a_rdata_o,
	a_rerror_o,
	b_req_i,
	b_write_i,
	b_addr_i,
	b_wdata_i,
	b_rvalid_o,
	b_rdata_o,
	b_rerror_o,
	cfg_i
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter signed [31:0] Depth = 512;
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] CfgW = 8;
	parameter EnableECC = 0;
	parameter EnableParity = 0;
	parameter EnableInputPipeline = 0;
	parameter EnableOutputPipeline = 0;
	parameter MemT = "REGISTER";
	parameter signed [31:0] SramAw = $clog2(Depth);
	input clk_i;
	input rst_ni;
	input a_req_i;
	input a_write_i;
	input [SramAw - 1:0] a_addr_i;
	input [Width - 1:0] a_wdata_i;
	output wire a_rvalid_o;
	output wire [Width - 1:0] a_rdata_o;
	output wire [1:0] a_rerror_o;
	input b_req_i;
	input b_write_i;
	input [SramAw - 1:0] b_addr_i;
	input [Width - 1:0] b_wdata_i;
	output wire b_rvalid_o;
	output wire [Width - 1:0] b_rdata_o;
	output wire [1:0] b_rerror_o;
	input [CfgW - 1:0] cfg_i;
	localparam signed [31:0] ParWidth = (EnableParity ? 1 : (!EnableECC ? 0 : (Width <= 4 ? 4 : (Width <= 11 ? 5 : (Width <= 26 ? 6 : (Width <= 57 ? 7 : (Width <= 120 ? 8 : 8)))))));
	localparam signed [31:0] TotalWidth = Width + ParWidth;
	reg a_req_q;
	wire a_req_d;
	reg a_write_q;
	wire a_write_d;
	reg [SramAw - 1:0] a_addr_q;
	wire [SramAw - 1:0] a_addr_d;
	reg [TotalWidth - 1:0] a_wdata_q;
	wire [TotalWidth - 1:0] a_wdata_d;
	reg a_rvalid_q;
	wire a_rvalid_d;
	reg a_rvalid_sram;
	reg [Width - 1:0] a_rdata_q;
	wire [Width - 1:0] a_rdata_d;
	wire [TotalWidth - 1:0] a_rdata_sram;
	reg [1:0] a_rerror_q;
	wire [1:0] a_rerror_d;
	reg b_req_q;
	wire b_req_d;
	reg b_write_q;
	wire b_write_d;
	reg [SramAw - 1:0] b_addr_q;
	wire [SramAw - 1:0] b_addr_d;
	reg [TotalWidth - 1:0] b_wdata_q;
	wire [TotalWidth - 1:0] b_wdata_d;
	reg b_rvalid_q;
	wire b_rvalid_d;
	reg b_rvalid_sram;
	reg [Width - 1:0] b_rdata_q;
	wire [Width - 1:0] b_rdata_d;
	wire [TotalWidth - 1:0] b_rdata_sram;
	reg [1:0] b_rerror_q;
	wire [1:0] b_rerror_d;
	generate
		if (MemT == "REGISTER") begin : gen_regmem
			prim_ram_2p #(
				.Width(TotalWidth),
				.Depth(Depth),
				.Impl(prim_pkg_ImplGeneric)
			) u_mem(
				.clk_a_i(clk_i),
				.clk_b_i(clk_i),
				.a_req_i(a_req_q),
				.a_write_i(a_write_q),
				.a_addr_i(a_addr_q),
				.a_wdata_i(a_wdata_q),
				.a_rdata_o(a_rdata_sram),
				.b_req_i(b_req_q),
				.b_write_i(b_write_q),
				.b_addr_i(b_addr_q),
				.b_wdata_i(b_wdata_q),
				.b_rdata_o(b_rdata_sram)
			);
		end
		else if (MemT == "SRAM") begin : gen_srammem
			prim_ram_2p #(
				.Width(TotalWidth),
				.Depth(Depth)
			) u_mem(
				.clk_a_i(clk_i),
				.clk_b_i(clk_i),
				.a_req_i(a_req_q),
				.a_write_i(a_write_q),
				.a_addr_i(a_addr_q),
				.a_wdata_i(a_wdata_q),
				.a_rdata_o(a_rdata_sram),
				.b_req_i(b_req_q),
				.b_write_i(b_write_q),
				.b_addr_i(b_addr_q),
				.b_wdata_i(b_wdata_q),
				.b_rdata_o(b_rdata_sram)
			);
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			a_rvalid_sram <= 1'sb0;
			b_rvalid_sram <= 1'sb0;
		end
		else begin
			a_rvalid_sram <= a_req_q & ~a_write_q;
			b_rvalid_sram <= b_req_q & ~b_write_q;
		end
	assign a_req_d = a_req_i;
	assign a_write_d = a_write_i;
	assign a_addr_d = a_addr_i;
	assign a_rvalid_o = a_rvalid_q;
	assign a_rdata_o = a_rdata_q;
	assign a_rerror_o = a_rerror_q;
	assign b_req_d = b_req_i;
	assign b_write_d = b_write_i;
	assign b_addr_d = b_addr_i;
	assign b_rvalid_o = b_rvalid_q;
	assign b_rdata_o = b_rdata_q;
	assign b_rerror_o = b_rerror_q;
	generate
		if ((EnableParity == 0) && EnableECC) begin : gen_secded
			if (Width == 32) begin : gen_secded_39_32
				prim_secded_39_32_enc u_enc_a(
					.in(a_wdata_i),
					.out(a_wdata_d)
				);
				prim_secded_39_32_dec u_dec_a(
					.in(a_rdata_sram),
					.d_o(a_rdata_d),
					.syndrome_o(),
					.err_o(a_rerror_d)
				);
				prim_secded_39_32_enc u_enc_b(
					.in(b_wdata_i),
					.out(b_wdata_d)
				);
				prim_secded_39_32_dec u_dec_b(
					.in(b_rdata_sram),
					.d_o(b_rdata_d),
					.syndrome_o(),
					.err_o(b_rerror_d)
				);
				assign a_rvalid_d = a_rvalid_sram;
				assign b_rvalid_d = b_rvalid_sram;
			end
		end
		else begin : gen_nosecded
			assign a_wdata_d[0+:Width] = a_wdata_i;
			assign b_wdata_d[0+:Width] = b_wdata_i;
			assign a_rdata_d = a_rdata_sram;
			assign b_rdata_d = b_rdata_sram;
			assign a_rvalid_d = a_rvalid_sram;
			assign b_rvalid_d = b_rvalid_sram;
			assign a_rerror_d = 2'b00;
			assign b_rerror_d = 2'b00;
		end
	endgenerate
	generate
		if (EnableInputPipeline) begin : gen_regslice_input
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					a_req_q <= 1'sb0;
					a_write_q <= 1'sb0;
					a_addr_q <= 1'sb0;
					a_wdata_q <= 1'sb0;
					b_req_q <= 1'sb0;
					b_write_q <= 1'sb0;
					b_addr_q <= 1'sb0;
					b_wdata_q <= 1'sb0;
				end
				else begin
					a_req_q <= a_req_d;
					a_write_q <= a_write_d;
					a_addr_q <= a_addr_d;
					a_wdata_q <= a_wdata_d;
					b_req_q <= b_req_d;
					b_write_q <= b_write_d;
					b_addr_q <= b_addr_d;
					b_wdata_q <= b_wdata_d;
				end
		end
		else begin : gen_dirconnect_input
			always @(*) a_req_q = a_req_d;
			always @(*) a_write_q = a_write_d;
			always @(*) a_addr_q = a_addr_d;
			always @(*) a_wdata_q = a_wdata_d;
			always @(*) b_req_q = b_req_d;
			always @(*) b_write_q = b_write_d;
			always @(*) b_addr_q = b_addr_d;
			always @(*) b_wdata_q = b_wdata_d;
		end
	endgenerate
	generate
		if (EnableOutputPipeline) begin : gen_regslice_output
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					a_rvalid_q <= 1'sb0;
					a_rdata_q <= 1'sb0;
					a_rerror_q <= 1'sb0;
					b_rvalid_q <= 1'sb0;
					b_rdata_q <= 1'sb0;
					b_rerror_q <= 1'sb0;
				end
				else begin
					a_rvalid_q <= a_rvalid_d;
					a_rdata_q <= a_rdata_d;
					a_rerror_q <= a_rerror_d;
					b_rvalid_q <= b_rvalid_d;
					b_rdata_q <= b_rdata_d;
					b_rerror_q <= b_rerror_d;
				end
		end
		else begin : gen_dirconnect_output
			always @(*) a_rvalid_q = a_rvalid_d;
			always @(*) a_rdata_q = a_rdata_d;
			always @(*) a_rerror_q = a_rerror_d;
			always @(*) b_rvalid_q = b_rvalid_d;
			always @(*) b_rdata_q = b_rdata_d;
			always @(*) b_rerror_q = b_rerror_d;
		end
	endgenerate
endmodule

(* blackbox *)
module prim_ram_2p_async_adv (
	clk_a_i,
	clk_b_i,
	rst_a_ni,
	rst_b_ni,
	a_req_i,
	a_write_i,
	a_addr_i,
	a_wdata_i,
	a_rvalid_o,
	a_rdata_o,
	a_rerror_o,
	b_req_i,
	b_write_i,
	b_addr_i,
	b_wdata_i,
	b_rvalid_o,
	b_rdata_o,
	b_rerror_o,
	cfg_i
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter signed [31:0] Depth = 512;
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] CfgW = 8;
	parameter EnableECC = 0;
	parameter EnableParity = 0;
	parameter EnableInputPipeline = 0;
	parameter EnableOutputPipeline = 0;
	parameter MemT = "REGISTER";
	parameter signed [31:0] SramAw = $clog2(Depth);
	input clk_a_i;
	input clk_b_i;
	input rst_a_ni;
	input rst_b_ni;
	input a_req_i;
	input a_write_i;
	input [SramAw - 1:0] a_addr_i;
	input [Width - 1:0] a_wdata_i;
	output wire a_rvalid_o;
	output wire [Width - 1:0] a_rdata_o;
	output wire [1:0] a_rerror_o;
	input b_req_i;
	input b_write_i;
	input [SramAw - 1:0] b_addr_i;
	input [Width - 1:0] b_wdata_i;
	output wire b_rvalid_o;
	output wire [Width - 1:0] b_rdata_o;
	output wire [1:0] b_rerror_o;
	input [CfgW - 1:0] cfg_i;
	localparam signed [31:0] ParWidth = (EnableParity ? 1 : (!EnableECC ? 0 : (Width <= 4 ? 4 : (Width <= 11 ? 5 : (Width <= 26 ? 6 : (Width <= 57 ? 7 : (Width <= 120 ? 8 : 8)))))));
	localparam signed [31:0] TotalWidth = Width + ParWidth;
	reg a_req_q;
	wire a_req_d;
	reg a_write_q;
	wire a_write_d;
	reg [SramAw - 1:0] a_addr_q;
	wire [SramAw - 1:0] a_addr_d;
	reg [TotalWidth - 1:0] a_wdata_q;
	wire [TotalWidth - 1:0] a_wdata_d;
	reg a_rvalid_q;
	wire a_rvalid_d;
	reg a_rvalid_sram;
	wire [TotalWidth - 1:0] a_rdata_d;
	wire [TotalWidth - 1:0] a_rdata_sram;
	reg [Width - 1:0] a_rdata_q;
	reg [1:0] a_rerror_q;
	wire [1:0] a_rerror_d;
	reg b_req_q;
	wire b_req_d;
	reg b_write_q;
	wire b_write_d;
	reg [SramAw - 1:0] b_addr_q;
	wire [SramAw - 1:0] b_addr_d;
	reg [TotalWidth - 1:0] b_wdata_q;
	wire [TotalWidth - 1:0] b_wdata_d;
	reg b_rvalid_q;
	wire b_rvalid_d;
	reg b_rvalid_sram;
	wire [TotalWidth - 1:0] b_rdata_d;
	wire [TotalWidth - 1:0] b_rdata_sram;
	reg [Width - 1:0] b_rdata_q;
	reg [1:0] b_rerror_q;
	wire [1:0] b_rerror_d;
	generate
		if (MemT == "REGISTER") begin : gen_regmem
			prim_ram_2p #(
				.Width(TotalWidth),
				.Depth(Depth),
				.Impl(prim_pkg_ImplGeneric)
			) u_mem(
				.clk_a_i(clk_a_i),
				.clk_b_i(clk_b_i),
				.a_req_i(a_req_q),
				.a_write_i(a_write_q),
				.a_addr_i(a_addr_q),
				.a_wdata_i(a_wdata_q),
				.a_rdata_o(a_rdata_sram),
				.b_req_i(b_req_q),
				.b_write_i(b_write_q),
				.b_addr_i(b_addr_q),
				.b_wdata_i(b_wdata_q),
				.b_rdata_o(b_rdata_sram)
			);
		end
		else if (MemT == "SRAM") begin : gen_srammem
			prim_ram_2p #(
				.Width(TotalWidth),
				.Depth(Depth)
			) u_mem(
				.clk_a_i(clk_a_i),
				.clk_b_i(clk_b_i),
				.a_req_i(a_req_q),
				.a_write_i(a_write_q),
				.a_addr_i(a_addr_q),
				.a_wdata_i(a_wdata_q),
				.a_rdata_o(a_rdata_sram),
				.b_req_i(b_req_q),
				.b_write_i(b_write_q),
				.b_addr_i(b_addr_q),
				.b_wdata_i(b_wdata_q),
				.b_rdata_o(b_rdata_sram)
			);
		end
	endgenerate
	always @(posedge clk_a_i or negedge rst_a_ni)
		if (!rst_a_ni)
			a_rvalid_sram <= 1'b0;
		else
			a_rvalid_sram <= a_req_q & ~a_write_q;
	always @(posedge clk_b_i or negedge rst_b_ni)
		if (!rst_b_ni)
			b_rvalid_sram <= 1'b0;
		else
			b_rvalid_sram <= b_req_q & ~b_write_q;
	assign a_req_d = a_req_i;
	assign a_write_d = a_write_i;
	assign a_addr_d = a_addr_i;
	assign a_rvalid_o = a_rvalid_q;
	assign a_rdata_o = a_rdata_q;
	assign a_rerror_o = a_rerror_q;
	assign b_req_d = b_req_i;
	assign b_write_d = b_write_i;
	assign b_addr_d = b_addr_i;
	assign b_rvalid_o = b_rvalid_q;
	assign b_rdata_o = b_rdata_q;
	assign b_rerror_o = b_rerror_q;
	generate
		if ((EnableParity == 0) && EnableECC) begin : gen_secded
			if (Width == 32) begin : gen_secded_39_32
				prim_secded_39_32_enc u_enc_a(
					.in(a_wdata_i),
					.out(a_wdata_d)
				);
				prim_secded_39_32_dec u_dec_a(
					.in(a_rdata_sram),
					.d_o(a_rdata_d[0+:Width]),
					.syndrome_o(a_rdata_d[Width+:ParWidth]),
					.err_o(a_rerror_d)
				);
				prim_secded_39_32_enc u_enc_b(
					.in(b_wdata_i),
					.out(b_wdata_d)
				);
				prim_secded_39_32_dec u_dec_b(
					.in(b_rdata_sram),
					.d_o(b_rdata_d[0+:Width]),
					.syndrome_o(b_rdata_d[Width+:ParWidth]),
					.err_o(b_rerror_d)
				);
				assign a_rvalid_d = a_rvalid_sram;
				assign b_rvalid_d = b_rvalid_sram;
			end
		end
		else begin : gen_nosecded
			assign a_wdata_d[0+:Width] = a_wdata_i;
			assign b_wdata_d[0+:Width] = b_wdata_i;
			assign a_rdata_d[0+:Width] = a_rdata_sram;
			assign b_rdata_d[0+:Width] = b_rdata_sram;
			assign a_rvalid_d = a_rvalid_sram;
			assign b_rvalid_d = b_rvalid_sram;
			assign a_rerror_d = 2'b00;
			assign b_rerror_d = 2'b00;
		end
	endgenerate
	generate
		if (EnableInputPipeline) begin : gen_regslice_input
			always @(posedge clk_a_i or negedge rst_a_ni)
				if (!rst_a_ni) begin
					a_req_q <= 1'sb0;
					a_write_q <= 1'sb0;
					a_addr_q <= 1'sb0;
					a_wdata_q <= 1'sb0;
				end
				else begin
					a_req_q <= a_req_d;
					a_write_q <= a_write_d;
					a_addr_q <= a_addr_d;
					a_wdata_q <= a_wdata_d;
				end
			always @(posedge clk_b_i or negedge rst_b_ni)
				if (!rst_b_ni) begin
					b_req_q <= 1'sb0;
					b_write_q <= 1'sb0;
					b_addr_q <= 1'sb0;
					b_wdata_q <= 1'sb0;
				end
				else begin
					b_req_q <= b_req_d;
					b_write_q <= b_write_d;
					b_addr_q <= b_addr_d;
					b_wdata_q <= b_wdata_d;
				end
		end
		else begin : gen_dirconnect_input
			always @(*) a_req_q = a_req_d;
			always @(*) a_write_q = a_write_d;
			always @(*) a_addr_q = a_addr_d;
			always @(*) a_wdata_q = a_wdata_d;
			always @(*) b_req_q = b_req_d;
			always @(*) b_write_q = b_write_d;
			always @(*) b_addr_q = b_addr_d;
			always @(*) b_wdata_q = b_wdata_d;
		end
	endgenerate
	generate
		if (EnableOutputPipeline) begin : gen_regslice_output
			always @(posedge clk_a_i or negedge rst_a_ni)
				if (!rst_a_ni) begin
					a_rvalid_q <= 1'sb0;
					a_rdata_q <= 1'sb0;
					a_rerror_q <= 1'sb0;
				end
				else begin
					a_rvalid_q <= a_rvalid_d;
					a_rdata_q <= a_rdata_d[0+:Width];
					a_rerror_q <= a_rerror_d;
				end
			always @(posedge clk_b_i or negedge rst_b_ni)
				if (!rst_b_ni) begin
					b_rvalid_q <= 1'sb0;
					b_rdata_q <= 1'sb0;
					b_rerror_q <= 1'sb0;
				end
				else begin
					b_rvalid_q <= b_rvalid_d;
					b_rdata_q <= b_rdata_d[0+:Width];
					b_rerror_q <= b_rerror_d;
				end
		end
		else begin : gen_dirconnect_output
			always @(*) a_rvalid_q = a_rvalid_d;
			always @(*) a_rdata_q = a_rdata_d[0+:Width];
			always @(*) a_rerror_q = a_rerror_d;
			always @(*) b_rvalid_q = b_rvalid_d;
			always @(*) b_rdata_q = b_rdata_d[0+:Width];
			always @(*) b_rerror_q = b_rerror_d;
		end
	endgenerate
endmodule

(* blackbox *)
module prim_secded_39_32_enc (
	in,
	out
);
	input [31:0] in;
	output wire [38:0] out;
	assign out[0] = in[0];
	assign out[1] = in[1];
	assign out[2] = in[2];
	assign out[3] = in[3];
	assign out[4] = in[4];
	assign out[5] = in[5];
	assign out[6] = in[6];
	assign out[7] = in[7];
	assign out[8] = in[8];
	assign out[9] = in[9];
	assign out[10] = in[10];
	assign out[11] = in[11];
	assign out[12] = in[12];
	assign out[13] = in[13];
	assign out[14] = in[14];
	assign out[15] = in[15];
	assign out[16] = in[16];
	assign out[17] = in[17];
	assign out[18] = in[18];
	assign out[19] = in[19];
	assign out[20] = in[20];
	assign out[21] = in[21];
	assign out[22] = in[22];
	assign out[23] = in[23];
	assign out[24] = in[24];
	assign out[25] = in[25];
	assign out[26] = in[26];
	assign out[27] = in[27];
	assign out[28] = in[28];
	assign out[29] = in[29];
	assign out[30] = in[30];
	assign out[31] = in[31];
	assign out[32] = (((((((((((in[2] ^ in[3]) ^ in[7]) ^ in[8]) ^ in[14]) ^ in[15]) ^ in[16]) ^ in[18]) ^ in[19]) ^ in[23]) ^ in[24]) ^ in[28]) ^ in[29];
	assign out[33] = ((((((((((((in[3] ^ in[6]) ^ in[8]) ^ in[12]) ^ in[13]) ^ in[15]) ^ in[17]) ^ in[19]) ^ in[21]) ^ in[25]) ^ in[27]) ^ in[29]) ^ in[30]) ^ in[31];
	assign out[34] = ((((((((((((in[0] ^ in[5]) ^ in[7]) ^ in[9]) ^ in[10]) ^ in[12]) ^ in[13]) ^ in[15]) ^ in[16]) ^ in[22]) ^ in[23]) ^ in[26]) ^ in[27]) ^ in[31];
	assign out[35] = ((((((((((((in[0] ^ in[1]) ^ in[4]) ^ in[6]) ^ in[9]) ^ in[11]) ^ in[12]) ^ in[14]) ^ in[22]) ^ in[23]) ^ in[25]) ^ in[28]) ^ in[29]) ^ in[30];
	assign out[36] = ((((((((((in[0] ^ in[2]) ^ in[3]) ^ in[4]) ^ in[5]) ^ in[11]) ^ in[17]) ^ in[20]) ^ in[24]) ^ in[26]) ^ in[27]) ^ in[30];
	assign out[37] = ((((((((((((in[1] ^ in[2]) ^ in[4]) ^ in[6]) ^ in[10]) ^ in[13]) ^ in[14]) ^ in[16]) ^ in[18]) ^ in[19]) ^ in[20]) ^ in[21]) ^ in[22]) ^ in[26];
	assign out[38] = (((((((((((((in[1] ^ in[5]) ^ in[7]) ^ in[8]) ^ in[9]) ^ in[10]) ^ in[11]) ^ in[17]) ^ in[18]) ^ in[20]) ^ in[21]) ^ in[24]) ^ in[25]) ^ in[28]) ^ in[31];
endmodule

(* blackbox *)
module prim_secded_39_32_dec (
	in,
	d_o,
	syndrome_o,
	err_o
);
	input [38:0] in;
	output wire [31:0] d_o;
	output wire [6:0] syndrome_o;
	output wire [1:0] err_o;
	wire single_error;
	assign syndrome_o[0] = ((((((((((((in[32] ^ in[2]) ^ in[3]) ^ in[7]) ^ in[8]) ^ in[14]) ^ in[15]) ^ in[16]) ^ in[18]) ^ in[19]) ^ in[23]) ^ in[24]) ^ in[28]) ^ in[29];
	assign syndrome_o[1] = (((((((((((((in[33] ^ in[3]) ^ in[6]) ^ in[8]) ^ in[12]) ^ in[13]) ^ in[15]) ^ in[17]) ^ in[19]) ^ in[21]) ^ in[25]) ^ in[27]) ^ in[29]) ^ in[30]) ^ in[31];
	assign syndrome_o[2] = (((((((((((((in[34] ^ in[0]) ^ in[5]) ^ in[7]) ^ in[9]) ^ in[10]) ^ in[12]) ^ in[13]) ^ in[15]) ^ in[16]) ^ in[22]) ^ in[23]) ^ in[26]) ^ in[27]) ^ in[31];
	assign syndrome_o[3] = (((((((((((((in[35] ^ in[0]) ^ in[1]) ^ in[4]) ^ in[6]) ^ in[9]) ^ in[11]) ^ in[12]) ^ in[14]) ^ in[22]) ^ in[23]) ^ in[25]) ^ in[28]) ^ in[29]) ^ in[30];
	assign syndrome_o[4] = (((((((((((in[36] ^ in[0]) ^ in[2]) ^ in[3]) ^ in[4]) ^ in[5]) ^ in[11]) ^ in[17]) ^ in[20]) ^ in[24]) ^ in[26]) ^ in[27]) ^ in[30];
	assign syndrome_o[5] = (((((((((((((in[37] ^ in[1]) ^ in[2]) ^ in[4]) ^ in[6]) ^ in[10]) ^ in[13]) ^ in[14]) ^ in[16]) ^ in[18]) ^ in[19]) ^ in[20]) ^ in[21]) ^ in[22]) ^ in[26];
	assign syndrome_o[6] = ((((((((((((((in[38] ^ in[1]) ^ in[5]) ^ in[7]) ^ in[8]) ^ in[9]) ^ in[10]) ^ in[11]) ^ in[17]) ^ in[18]) ^ in[20]) ^ in[21]) ^ in[24]) ^ in[25]) ^ in[28]) ^ in[31];
	assign d_o[0] = (syndrome_o == 7'h1c) ^ in[0];
	assign d_o[1] = (syndrome_o == 7'h68) ^ in[1];
	assign d_o[2] = (syndrome_o == 7'h31) ^ in[2];
	assign d_o[3] = (syndrome_o == 7'h13) ^ in[3];
	assign d_o[4] = (syndrome_o == 7'h38) ^ in[4];
	assign d_o[5] = (syndrome_o == 7'h54) ^ in[5];
	assign d_o[6] = (syndrome_o == 7'h2a) ^ in[6];
	assign d_o[7] = (syndrome_o == 7'h45) ^ in[7];
	assign d_o[8] = (syndrome_o == 7'h43) ^ in[8];
	assign d_o[9] = (syndrome_o == 7'h4c) ^ in[9];
	assign d_o[10] = (syndrome_o == 7'h64) ^ in[10];
	assign d_o[11] = (syndrome_o == 7'h58) ^ in[11];
	assign d_o[12] = (syndrome_o == 7'he) ^ in[12];
	assign d_o[13] = (syndrome_o == 7'h26) ^ in[13];
	assign d_o[14] = (syndrome_o == 7'h29) ^ in[14];
	assign d_o[15] = (syndrome_o == 7'h7) ^ in[15];
	assign d_o[16] = (syndrome_o == 7'h25) ^ in[16];
	assign d_o[17] = (syndrome_o == 7'h52) ^ in[17];
	assign d_o[18] = (syndrome_o == 7'h61) ^ in[18];
	assign d_o[19] = (syndrome_o == 7'h23) ^ in[19];
	assign d_o[20] = (syndrome_o == 7'h70) ^ in[20];
	assign d_o[21] = (syndrome_o == 7'h62) ^ in[21];
	assign d_o[22] = (syndrome_o == 7'h2c) ^ in[22];
	assign d_o[23] = (syndrome_o == 7'hd) ^ in[23];
	assign d_o[24] = (syndrome_o == 7'h51) ^ in[24];
	assign d_o[25] = (syndrome_o == 7'h4a) ^ in[25];
	assign d_o[26] = (syndrome_o == 7'h34) ^ in[26];
	assign d_o[27] = (syndrome_o == 7'h16) ^ in[27];
	assign d_o[28] = (syndrome_o == 7'h49) ^ in[28];
	assign d_o[29] = (syndrome_o == 7'hb) ^ in[29];
	assign d_o[30] = (syndrome_o == 7'h1a) ^ in[30];
	assign d_o[31] = (syndrome_o == 7'h46) ^ in[31];
	assign single_error = ^syndrome_o;
	assign err_o[0] = single_error;
	assign err_o[1] = ~single_error & |syndrome_o;
endmodule

(* blackbox *)
module prim_ram_2p (
	clk_a_i,
	clk_b_i,
	a_req_i,
	a_write_i,
	a_addr_i,
	a_wdata_i,
	a_rdata_o,
	b_req_i,
	b_write_i,
	b_addr_i,
	b_wdata_i,
	b_rdata_o
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	localparam signed [31:0] Aw = $clog2(Depth);
	input clk_a_i;
	input clk_b_i;
	input a_req_i;
	input a_write_i;
	input [Aw - 1:0] a_addr_i;
	input [Width - 1:0] a_wdata_i;
	output wire [Width - 1:0] a_rdata_o;
	input b_req_i;
	input b_write_i;
	input [Aw - 1:0] b_addr_i;
	input [Width - 1:0] b_wdata_i;
	output wire [Width - 1:0] b_rdata_o;
	localparam ImplGeneric = 0;
	localparam ImplXilinx = 1;
	generate
		if (Impl == ImplGeneric) begin : gen_mem_generic
			prim_generic_ram_2p #(
				.Width(Width),
				.Depth(Depth)
			) u_impl_generic(
				.clk_a_i(clk_a_i),
				.clk_b_i(clk_b_i),
				.a_req_i(a_req_i),
				.a_write_i(a_write_i),
				.a_addr_i(a_addr_i),
				.a_wdata_i(a_wdata_i),
				.a_rdata_o(a_rdata_o),
				.b_req_i(b_req_i),
				.b_write_i(b_write_i),
				.b_addr_i(b_addr_i),
				.b_wdata_i(b_wdata_i),
				.b_rdata_o(b_rdata_o)
			);
		end
		// else if (Impl == ImplXilinx) begin : gen_mem_xilinx
		// 	prim_xilinx_ram_2p #(
		// 		.Width(Width),
		// 		.Depth(Depth)
		// 	) u_impl_xilinx(
		// 		.clk_a_i(clk_a_i),
		// 		.clk_b_i(clk_b_i),
		// 		.a_req_i(a_req_i),
		// 		.a_write_i(a_write_i),
		// 		.a_addr_i(a_addr_i),
		// 		.a_wdata_i(a_wdata_i),
		// 		.a_rdata_o(a_rdata_o),
		// 		.b_req_i(b_req_i),
		// 		.b_write_i(b_write_i),
		// 		.b_addr_i(b_addr_i),
		// 		.b_wdata_i(b_wdata_i),
		// 		.b_rdata_o(b_rdata_o)
		// 	);
		// end
	endgenerate
endmodule

(* blackbox *)
module prim_generic_ram_2p (
	clk_a_i,
	clk_b_i,
	a_req_i,
	a_write_i,
	a_addr_i,
	a_wdata_i,
	a_rdata_o,
	b_req_i,
	b_write_i,
	b_addr_i,
	b_wdata_i,
	b_rdata_o
);
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	localparam signed [31:0] Aw = $clog2(Depth);
	input clk_a_i;
	input clk_b_i;
	input a_req_i;
	input a_write_i;
	input [Aw - 1:0] a_addr_i;
	input [Width - 1:0] a_wdata_i;
	output reg [Width - 1:0] a_rdata_o;
	input b_req_i;
	input b_write_i;
	input [Aw - 1:0] b_addr_i;
	input [Width - 1:0] b_wdata_i;
	output reg [Width - 1:0] b_rdata_o;
	reg [Width - 1:0] mem [0:Depth - 1];
	always @(posedge clk_a_i)
		if (a_req_i) begin
			if (a_write_i)
				mem[a_addr_i] <= a_wdata_i;
			a_rdata_o <= mem[a_addr_i];
		end
	always @(posedge clk_b_i)
		if (b_req_i) begin
			if (b_write_i)
				mem[b_addr_i] <= b_wdata_i;
			b_rdata_o <= mem[b_addr_i];
		end
endmodule

(* blackbox *)
module prim_ram_1p (
	clk_i,
	rst_ni,
	req_i,
	write_i,
	addr_i,
	wdata_i,
	wmask_i,
	rvalid_o,
	rdata_o
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	parameter signed [31:0] DataBitsPerMask = 1;
	localparam signed [31:0] Aw = $clog2(Depth);
	input clk_i;
	input rst_ni;
	input req_i;
	input write_i;
	input [Aw - 1:0] addr_i;
	input [Width - 1:0] wdata_i;
	input [Width - 1:0] wmask_i;
	output wire rvalid_o;
	output wire [Width - 1:0] rdata_o;
	localparam ImplGeneric = 0;
	localparam ImplXilinx = 1;
	generate
		if ((Impl == ImplGeneric) || (Impl == ImplXilinx)) begin : gen_mem_generic
			prim_generic_ram_1p #(
				.Width(Width),
				.Depth(Depth),
				.DataBitsPerMask(DataBitsPerMask)
			) u_impl_generic(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(req_i),
				.write_i(write_i),
				.addr_i(addr_i),
				.wdata_i(wdata_i),
				.wmask_i(wmask_i),
				.rvalid_o(rvalid_o),
				.rdata_o(rdata_o)
			);
		end
	endgenerate
endmodule

(* blackbox *)
module prim_generic_ram_1p (
	clk_i,
	rst_ni,
	req_i,
	write_i,
	addr_i,
	wdata_i,
	wmask_i,
	rvalid_o,
	rdata_o
);
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	parameter signed [31:0] DataBitsPerMask = 1;
	localparam signed [31:0] Aw = $clog2(Depth);
	input clk_i;
	input rst_ni;
	input req_i;
	input write_i;
	input [Aw - 1:0] addr_i;
	input [Width - 1:0] wdata_i;
	input [Width - 1:0] wmask_i;
	output reg rvalid_o;
	output reg [Width - 1:0] rdata_o;
	localparam signed [31:0] MaskWidth = Width / DataBitsPerMask;
	reg [Width - 1:0] mem [0:Depth - 1];
	reg [MaskWidth - 1:0] wmask;
	always @(*) begin : sv2v_autoblock_833
		reg signed [31:0] i;
		for (i = 0; i < MaskWidth; i = i + 1)
			begin : create_wmask
				wmask[i] = &wmask_i[i * DataBitsPerMask+:DataBitsPerMask];
			end
	end
	always @(posedge clk_i)
		if (req_i)
			if (write_i) begin : sv2v_autoblock_834
				reg signed [31:0] i;
				for (i = 0; i < MaskWidth; i = i + 1)
					if (wmask[i])
						mem[addr_i][i * DataBitsPerMask+:DataBitsPerMask] <= wdata_i[i * DataBitsPerMask+:DataBitsPerMask];
			end
			else
				rdata_o <= mem[addr_i];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rvalid_o <= 1'sb0;
		else
			rvalid_o <= req_i & ~write_i;
endmodule

(* blackbox *)
module prim_rom (
	clk_i,
	rst_ni,
	addr_i,
	cs_i,
	dout_o,
	dvalid_o
);
	localparam prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 2048;
	parameter signed [31:0] Aw = $clog2(Depth);
	input clk_i;
	input rst_ni;
	input [Aw - 1:0] addr_i;
	input cs_i;
	output wire [Width - 1:0] dout_o;
	output wire dvalid_o;
	localparam ImplGeneric = 0;
	localparam ImplXilinx = 1;
	generate
		if (Impl == ImplGeneric) begin : gen_mem_generic
			prim_generic_rom #(
				.Width(Width),
				.Depth(Depth)
			) u_impl_generic(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.addr_i(addr_i),
				.cs_i(cs_i),
				.dout_o(dout_o),
				.dvalid_o(dvalid_o)
			);
		end
		// else if (Impl == ImplXilinx) begin : gen_rom_xilinx
		// 	prim_xilinx_rom #(
		// 		.Width(Width),
		// 		.Depth(Depth)
		// 	) u_impl_generic(
		// 		.clk_i(clk_i),
		// 		.addr_i(addr_i),
		// 		.cs_i(cs_i),
		// 		.dout_o(dout_o),
		// 		.dvalid_o(dvalid_o)
		// 	);
		// end
	endgenerate
endmodule

(* blackbox *)
module prim_generic_rom (
	clk_i,
	rst_ni,
	addr_i,
	cs_i,
	dout_o,
	dvalid_o
);
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 2048;
	parameter signed [31:0] Aw = $clog2(Depth);
	input clk_i;
	input rst_ni;
	input [Aw - 1:0] addr_i;
	input cs_i;
	output reg [Width - 1:0] dout_o;
	output reg dvalid_o;
	reg [Width - 1:0] mem [0:Depth - 1];
	always @(posedge clk_i)
		if (cs_i)
			dout_o <= mem[addr_i];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dvalid_o <= 1'b0;
		else
			dvalid_o <= cs_i;
	localparam MEM_FILE = "bootrom.mem";
	initial begin
		$display("Initializing ROM from %s", MEM_FILE);
		$readmemh(MEM_FILE, mem);
	end
endmodule