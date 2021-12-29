set BRAMClkNm [dict get $BRAMentry SyncClk Label]
set BRAMFreq  [dict get $BRAMentry SyncClk Freq]
set BRAMname  [dict get $BRAMentry SyncClk Name]
set BRAMintf  [dict get $BRAMentry IntfLabel]

set BRAMaddrWidth [dict get $BRAMentry AxiAddrWidth]
set BRAMdataWidth [dict get $BRAMentry AxiDataWidth]
set BRAMidWidth   [dict get $BRAMentry AxiIdWidth]
set BRAMUserWidth [dict get $BRAMentry AxiUserWidth]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0

set_property -dict [list CONFIG.DATA_WIDTH $BRAMdataWidth CONFIG.SINGLE_PORT_BRAM {1} \
CONFIG.ECC_TYPE {0}] [get_bd_cells axi_bram_ctrl_0]


## Create the Shell interface to the RTL
## CAUTION: The user can't specify USER, QOS and REGION signal for this interface
## This means those signals can't be in the module definition file

  # Create interface ports
  set bram_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $BRAMintf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $BRAMaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $BRAMdataWidth \
   CONFIG.FREQ_HZ $BRAMFreq \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $BRAMidWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $bram_axi

 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins rst_ea_$BRAMClkNm/slowest_sync_clk]
 connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins rst_ea_$BRAMClkNm/peripheral_aresetn]
 
 connect_bd_intf_net [get_bd_intf_ports $BRAMintf] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

 apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]

### Set Base Addresses to peripheral
# BRAM
set BRAMbaseAddr [dict get $BRAMentry BaseAddr]
set BRAMMemRange [expr {2**$BRAMaddrWidth/1024}]

putdebugs "Base Addr BRAM: $BRAMbaseAddr"
putdebugs "Mem Range BRAM: $BRAMMemRange"

assign_bd_address [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]

putdebugs "BRAM INTF: $BRAMintf"
set_property offset $BRAMbaseAddr   [get_bd_addr_segs $BRAMintf/SEG_axi_bram_ctrl_0_Mem0]
set_property range ${BRAMMemRange}K [get_bd_addr_segs $BRAMintf/SEG_axi_bram_ctrl_0_Mem0]

save_bd_design




