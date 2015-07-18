
module dyract #(parameter RECONFIG_ENABLE  = 0
  )
  (
  input   [7:0]        pci_exp_rxp,
  input   [7:0]        pci_exp_rxn, 
  output  [7:0]        pci_exp_txp,
  output  [7:0]        pci_exp_txn,  
  input                sys_clk_p,
  input                sys_clk_n,
  input                sys_reset_n,
//axi clock and reset
  input                m_axi_aclk,
  input                m_axi_aresetn,
  output  [31 : 0]     m_axi_awaddr,
  output  [7 : 0]      m_axi_awlen,
  output  [2 : 0]      m_axi_awsize,
  output  [1 : 0]      m_axi_awburst,
  output  [0 : 0]      m_axi_awlock,
  output  [3 : 0]      m_axi_awcache,
  output  [2 : 0]      m_axi_awprot,
  output  [3 : 0]      m_axi_awregion,
  output  [3 : 0]      m_axi_awqos,
  output               m_axi_awvalid,
  input                m_axi_awready,
  output  [511 : 0]    m_axi_wdata,
  output  [63 : 0]     m_axi_wstrb,
  output               m_axi_wlast,
  output               m_axi_wvalid,
  input                m_axi_wready,
  input  [1 : 0]       m_axi_bresp,
  input                m_axi_bvalid,
  output               m_axi_bready,
  output  [31 : 0]     m_axi_araddr,
  output  [7 : 0]      m_axi_arlen,
  output  [2 : 0]      m_axi_arsize,
  output  [1 : 0]      m_axi_arburst,
  output  [0 : 0]      m_axi_arlock,
  output  [3 : 0]      m_axi_arcache,
  output  [2 : 0]      m_axi_arprot,
  output  [3 : 0]      m_axi_arregion,
  output  [3 : 0]      m_axi_arqos,
  output               m_axi_arvalid,
  input                m_axi_arready,
  input  [511 : 0]     m_axi_rdata,
  input  [1 : 0]       m_axi_rresp,
  input                m_axi_rlast,
  input                m_axi_rvalid,
  output               m_axi_rready,
  output               pcie_link_status,
  output               heartbeat
);


wire [255:0] user_str1_wr_data;
wire [255:0] user_str1_rd_data;
wire [31:0]  sys_user_dma_addr;
wire [31:0]  user_sys_dma_addr;
wire [31:0]  sys_user_dma_len;
wire [31:0]  user_sys_dma_len; 

//assign o_axi_clk = pcie_clk;


// Instantiate the module
(*KEEP_HIERARCHY = "SOFT"*)
pcie_top #(
     .RECONFIG_ENABLE(RECONFIG_ENABLE) 
     )
     pcie (
    .pci_exp_txp(pci_exp_txp), 
    .pci_exp_txn(pci_exp_txn), 
    .pci_exp_rxp(pci_exp_rxp), 
    .pci_exp_rxn(pci_exp_rxn), 
    .sys_clk_p(sys_clk_p), 
    .sys_clk_n(sys_clk_n), 
    .sys_reset_n(sys_reset_n), 
    .user_clk_o(user_clk), 
	.pcie_clk_o(pcie_clk),
    .user_reset_o(user_reset),
    //user stream interface 
    .user_intr_req_i(user_intr_req), 
    .user_intr_ack_o(user_intr_ack), 
    .user_str_data_valid_o(user_str1_data_wr_valid),
    .user_str_ack_i(user_str1_wr_ack),
    .user_str_data_o(user_str1_wr_data),
    .user_str_data_valid_i(user_str1_data_rd_valid),
    .user_str_ack_o(user_str1_rd_ack),
    .user_str_data_i(user_str1_rd_data),
    .sys_user_dma_addr_o(sys_user_dma_addr),
    .user_sys_dma_addr_o(user_sys_dma_addr),
    .sys_user_dma_len_o(sys_user_dma_len), 
    .user_sys_dma_len_o(user_sys_dma_len), 
    .user_sys_dma_en_o(user_sys_dma_en),
    .sys_user_dma_en_o(sys_user_dma_en),
    .pcie_link_status(pcie_link_status)
);
	 
(*KEEP_HIERARCHY = "SOFT"*)
    axi_adapter adpt(
         .i_pcie_clk(pcie_clk),
         .i_rst_n(user_reset),
         //pcie strm 1
         .i_pcie_str_data_valid(user_str1_data_wr_valid),
         .o_pcie_str_ack(user_str1_wr_ack),
         .i_pcie_str_data(user_str1_wr_data),
         .o_pcie_str_data_valid(user_str1_data_rd_valid),
         .i_pcie_str_ack(user_str1_rd_ack),
         .o_pcie_str_data(user_str1_rd_data),
         .sys_user_dma_addr_i(sys_user_dma_addr),
         .user_sys_dma_addr_i(user_sys_dma_addr),
         .sys_user_dma_len_i(sys_user_dma_len), 
         .user_sys_dma_len_i(user_sys_dma_len), 
         .user_sys_dma_en_i(user_sys_dma_en),
         .sys_user_dma_en_i(sys_user_dma_en),
         //intr
         .o_intr_req(user_intr_req),
         .i_intr_ack(user_intr_ack),
         //AXI
         .m_axi_aclk(m_axi_aclk),
         .m_axi_aresetn(m_axi_aresetn),
         .m_axi_awaddr(m_axi_awaddr),
         .m_axi_awlen(m_axi_awlen),
         .m_axi_awsize(m_axi_awsize),
         .m_axi_awburst(m_axi_awburst),
         .m_axi_awlock(m_axi_awlock), 
         .m_axi_awcache(m_axi_awcache), 
         .m_axi_awprot(m_axi_awprot), 
         .m_axi_awregion(m_axi_awregion), 
         .m_axi_awqos(m_axi_awqos),
         .m_axi_awvalid(m_axi_awvalid),
         .m_axi_awready(m_axi_awready),
         .m_axi_wdata(m_axi_wdata),
         .m_axi_wstrb(m_axi_wstrb),
         .m_axi_wlast(m_axi_wlast), 
         .m_axi_wvalid(m_axi_wvalid), 
         .m_axi_wready(m_axi_wready),  
         .m_axi_bresp(m_axi_bresp), 
         .m_axi_bvalid(m_axi_bvalid),
         .m_axi_bready(m_axi_bready), 
         .m_axi_araddr(m_axi_araddr), 
         .m_axi_arlen(m_axi_arlen), 
         .m_axi_arsize(m_axi_arsize),
         .m_axi_arburst(m_axi_arburst), 
         .m_axi_arlock(m_axi_arlock),
         .m_axi_arcache(m_axi_arcache), 
         .m_axi_arprot(m_axi_arprot),
         .m_axi_arregion(m_axi_arregion),
         .m_axi_arqos(m_axi_arqos),
         .m_axi_arvalid(m_axi_arvalid),
         .m_axi_arready(m_axi_arready),
         .m_axi_rdata(m_axi_rdata),
         .m_axi_rresp(m_axi_rresp),
         .m_axi_rlast(m_axi_rlast),
         .m_axi_rvalid(m_axi_rvalid),
         .m_axi_rready(m_axi_rready)
    );



reg   [28:0] led_counter;

always @( posedge user_clk)
begin
    led_counter <= led_counter + 1;
end

assign heartbeat = led_counter[27];
	 
endmodule
	 