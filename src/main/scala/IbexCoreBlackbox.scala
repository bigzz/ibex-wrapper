package ibex

import sys.process._

import chisel3._
import chisel3.util._
import chisel3.experimental.{IntParam, StringParam, RawParam}

import scala.collection.mutable.{ListBuffer}

//FIXME: probably dont need axi4
import freechips.rocketchip.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.diplomaticobjectmodel.logicaltree.{LogicalModuleTree, LogicalTreeNode, RocketLogicalTreeNode, ICacheLogicalTreeNode}
import freechips.rocketchip.rocket._
import freechips.rocketchip.subsystem.{RocketCrossingParams}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.interrupts._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.amba.axi4._

class IbexCoreBlackbox(
	pmpGranularity: Int,
	pmpNumRegions: Int,
	mhpmCounterNum: Int,
	mhpmCounterWidth: Int,
	rv32m: String,
	rv32b: String,
	regfile: String,
	dbgHwBreakNum: Int,
	dmHaltAddr: Int,
	dmExceptionAddr: Int)
	extends BlackBox(
		Map(
			"PMP_GRANULARITY" -> IntParam(pmpGranularity),
			"PMP_NUM_REGIONS" -> IntParam(pmpNumRegions),
			"MHPM_COUNTER_NUM" -> IntParam(mhpmCounterNum),
			"MHPM_COUNTER_WIDTH" -> IntParam(mhpmCounterWidth),
			"RV32M" -> RawParam(rv32m),
    		"RV32B" -> RawParam(rv32b),
    		"REGFILE" -> RawParam(regfile),
			"DBG_HW_BREAK_NUM" -> IntParam(dbgHwBreakNum),
			"DM_HALT_ADDR" -> IntParam(dmHaltAddr),
			"DM_EXCEPTION_ADDR" -> IntParam(dmExceptionAddr))
	)
	with HasBlackBoxResource
{
	val io = IO(new Bundle {
		val clk_i = Input(Clock())
    	val rst_ni = Input(Bool())
    	val test_en_i = Input(Bool())
    	val ram_cfg_i_ram_cfg_en = Input(Bool())
    	val ram_cfg_i_ram_cfg = Input(UInt(4.W)) //logic [3:0]
    	val ram_cfg_i_rf_cfg_en = Input(Bool())
    	val ram_cfg_i_rf_cfg = Input(UInt(4.W)) //logic [3:0]
    	val hart_id_i = Input(UInt(32.W))
    	val boot_addr_i = Input(UInt(32.W))
    	val instr_req_o = Output(Bool())
    	val instr_gnt_i = Input(Bool())
    	val instr_rvalid_i = Input(Bool())
    	val instr_addr_o = Output(UInt(32.W))
    	val instr_rdata_i = Input(UInt(32.W))
    	val instr_err_i = Input(Bool())
    	val data_req_o = Output(Bool())
    	val data_gnt_i = Input(Bool())
    	val data_rvalid_i = Input(Bool())
    	val data_we_o = Output(Bool())
    	val data_be_o = Output(UInt(4.W))
    	val data_addr_o = Output(UInt(32.W))
    	val data_wdata_o = Output(UInt(32.W))
    	val data_rdata_i = Input(UInt(32.W))
    	val data_err_i = Input(Bool())
    	val irq_software_i = Input(Bool())
    	val irq_timer_i = Input(Bool())
    	val irq_external_i = Input(Bool())
    	val irq_fast_i = Input(UInt(15.W))
    	val irq_nm_i = Input(Bool())
    	val debug_req_i = Input(Bool())
    	val crash_dump_o_current_pc = Output(UInt(32.W))
    	val crash_dump_o_next_pc = Output(UInt(32.W))
    	val crash_dump_o_last_data_addr = Output(UInt(32.W))
    	val crash_dump_o_exception_addr = Output(UInt(32.W))
    	//skip rvfi
    	val fetch_enable_i = Input(Bool())
    	val alert_minor_o = Output(Bool())
    	val alert_major_o = Output(Bool())
    	val core_sleep_o = Output(Bool())
    	val scan_rst_ni = Input(Bool())
	})

	val proc = "make -C generators/ibex/src/main/resources/vsrc default"
	require (proc.! == 0, "Failed to run preprocessing step")

	addResource("/vsrc/IbexCoreBlackbox.preprocessed.sv")
}