module IbexCoreBlackbox
	#(
		//parameters, currently just int (not bit)
		parameter PMP_GRANULARITY = 0,
		parameter PMP_NUM_REGIONS = 0,
		parameter MHPM_COUNTER_NUM = 0,
		parameter MHPM_COUNTER_WIDTH = 0,
		parameter RV32M = ibex_pkg::RV32MFast, //default 2
    	parameter RV32B = ibex_pkg::RV32BNone, //default 0
    	parameter REGFILE = ibex_pkg::RegFileFF, //default 0
		parameter DBG_HW_BREAK_NUM = 0,
		parameter [31:0] DM_HALT_ADDR = 0,
		parameter [31:0] DM_EXCEPTION_ADDR = 0
	) //TODO !!!!!!!!!!!
( 
	//inputs/outputs
	// Clock and Reset
    input clk_i,
    input rst_ni,

    input test_en_i,     // enable all clock gates for testing
    //input  prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i,

    //split up struct TODO: connect these somewhere?
    input ram_cfg_i_ram_cfg_en,
    input [3:0] ram_cfg_i_ram_cfg,
    input ram_cfg_i_rf_cfg_en,
    input [3:0] ram_cfg_i_rf_cfg,

    input [31:0] hart_id_i,
    input [31:0] boot_addr_i,

    // Instruction memory interface
    output instr_req_o,
    input  instr_gnt_i,
    input  instr_rvalid_i,
    output [31:0] instr_addr_o,
    input  [31:0] instr_rdata_i,
    input  instr_err_i,

    // Data memory interface
    output data_req_o,
    input  data_gnt_i,
    input  data_rvalid_i,
    output data_we_o,
    output [3:0] data_be_o,
    output [31:0] data_addr_o,
    output [31:0] data_wdata_o,
    input  [31:0] data_rdata_i,
    input  data_err_i,

    // Interrupt inputs
    input irq_software_i, //msip, software interrupt
    input irq_timer_i, //mtip
    input irq_external_i, //meip? external interrupt
    input [14:0] irq_fast_i, //fast local interrupts??
    input irq_nm_i,       //nmi non-maskeable interrupt

    // Debug Interface
    input debug_req_i, //debug
    //output ibex_pkg::crash_dump_t        crash_dump_o,

    //debugging output for ibex_lockstep.sv
    output [31:0] crash_dump_o_current_pc,
    output [31:0] crash_dump_o_next_pc,
    output [31:0] crash_dump_o_last_data_addr,
    output [31:0] crash_dump_o_exception_addr,

    // CPU Control Signals
    input fetch_enable_i,
    output alert_minor_o,
    output alert_major_o,
    output core_sleep_o,

    // DFT bypass controls
    input scan_rst_ni
);

	prim_ram_1p_pkg::ram_1p_cfg_t ibex_ram_config;
	ibex_pkg::crash_dump_t ibex_crash_dump;

	ibex_top #(
		.PMPEnable(1'b0),
	    .PMPGranularity(PMP_GRANULARITY),
	    .PMPNumRegions(PMP_NUM_REGIONS),
	    .MHPMCounterNum(MHPM_COUNTER_NUM),
	    .MHPMCounterWidth(MHPM_COUNTER_WIDTH),
	    .RV32E(1'b0),
	    .RV32M(RV32M),
	    .RV32B(RV32B),
	    .RegFile(REGFILE),
	    .BranchTargetALU(1'b0),
	    .WritebackStage(1'b0),
	    .ICache(1'b0),
	    .ICacheECC(1'b0),
	    .BranchPredictor(1'b0),
	    .DbgTriggerEn(1'b0),
	    .DbgHwBreakNum(DBG_HW_BREAK_NUM),
	    .SecureIbex(1'b0),
	    .DmHaltAddr(DM_HALT_ADDR),
	    .DmExceptionAddr(DM_EXCEPTION_ADDR)
	) i_ibex (
	    .clk_i,
	    .rst_ni,
	    .test_en_i,
	    .ram_cfg_i ( ibex_ram_config ), //CHECK
	    .hart_id_i,
	    .boot_addr_i,
		.instr_req_o,
	    .instr_gnt_i,
	    .instr_rvalid_i,
	    .instr_addr_o,
	    .instr_rdata_i,
	    .instr_err_i,
		.data_req_o,
	    .data_gnt_i,
	    .data_rvalid_i,
	    .data_we_o,
	    .data_be_o,
	    .data_addr_o,
	    .data_wdata_o,
	    .data_rdata_i,
	    .data_err_i,
		.irq_software_i,
	    .irq_timer_i,
	    .irq_external_i,
	    .irq_fast_i,
	    .irq_nm_i,
	    .debug_req_i,
	    .crash_dump_o ( ibex_crash_dump ),
	    .fetch_enable_i,
	    .alert_minor_o,
	    .alert_major_o,
	    .core_sleep_o,
	    .scan_rst_ni
	);

endmodule