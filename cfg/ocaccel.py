Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)
Inc('dfaccto/axi.py', abs=True)


class _OCAccelEnv(ModuleContext):

  def __init__(self):
    super().__init__()
    import os

    self.ContextBits = 1
    self.InterruptBits = 64
    self.AxiCtrl_DataBytes = 4
    self.AxiCtrl_AddrBits = 32
    self.AxiHost_DataBytes = 64 if os.environ.get('ACTION_HALF_WIDTH', False) else 128
    self.AxiHost_AddrBits = 64
    self.AxiHost_IdBits = os.environ.get('AXI_ID_WIDTH', 5)
    self.AxiHost_UserBits = self.ContextBits
    self.AxiDdr_DataBytes = 64
    self.AxiDdr_AddrBits = 33
    self.AxiDdr_IdBits = 4
    self.AxiDdr_UserBits = 1
    self.AxiDdrEnabled = 'ENABLE_DDR' in os.environ
    self.AxiHbm_DataBytes = 32
    self.AxiHbm_AddrBits = 34
    self.AxiHbm_IdBits = 4
    self.AxiHbm_UserBits = 1
    self.AxiHbmEnabled = 'ENABLE_HBM' in os.environ
    self.AxiHbmCount = int(os.environ.get('HBM_AXI_IF_NUM', '1'))
    self.StmEth_DataBytes = 64
    self.StmEth_UserBits = 1
    self.StmEthEnabled = os.environ.get('ETHERNET_USED', 'FALSE') == 'TRUE'

  def make_pkg(self, pkg_name):
    self.tlogic = T('Logic', 'dfaccto')
    self.tsys = T('Sys', 'dfaccto')
    self.pkg = Pkg(pkg_name,
        x_templates={self.File('generic/package.vhd.tpl'): self.File('pkg/ocaccel.vhd')})
    with self.pkg:
      self.tctrl = TypeAxi('AxiCtrl',
          self.AxiCtrl_DataBytes,
          self.AxiCtrl_AddrBits,
          has_burst=False)
      self.thost = TypeAxi('AxiHost',
          self.AxiHost_DataBytes,
          self.AxiHost_AddrBits,
          id_bits=self.AxiHost_IdBits,
          has_attr=True,
          aruser_bits=self.AxiHost_UserBits,
          awuser_bits=self.AxiHost_UserBits,
          ruser_bits=self.AxiHost_UserBits,
          wuser_bits=self.AxiHost_UserBits,
          buser_bits=self.AxiHost_UserBits,
          add_split=True)

      self.tddr = TypeAxi('AxiDdr',
          self.AxiDdr_DataBytes,
          self.AxiDdr_AddrBits,
          id_bits=self.AxiDdr_IdBits,
          has_attr=True,
          aruser_bits=self.AxiDdr_UserBits,
          awuser_bits=self.AxiDdr_UserBits,
          ruser_bits=self.AxiDdr_UserBits,
          wuser_bits=self.AxiDdr_UserBits,
          buser_bits=self.AxiDdr_UserBits)
      self.thbm = TypeAxi('AxiHbm',
          self.AxiHbm_DataBytes,
          self.AxiHbm_AddrBits,
          id_bits=self.AxiHbm_IdBits,
          has_attr=True,
          aruser_bits=self.AxiHbm_UserBits,
          awuser_bits=self.AxiHbm_UserBits,
          ruser_bits=self.AxiHbm_UserBits,
          wuser_bits=self.AxiHbm_UserBits,
          buser_bits=self.AxiHbm_UserBits)
      self.teth = TypeAxiStream('StmEth',
          self.StmEth_DataBytes,
          user_bits=self.StmEth_UserBits)

      self.tctx = TypeUnsigned('Context', width=self.ContextBits)

      self.tisrc = TypeUnsigned('InterruptSrc', width=self.InterruptBits)

      self.tintr = TypeC('Interrupt',
          x_definition=self.Part('types/definition/interrupt.part.tpl'),
          x_format_ms=self.Part('types/format/interrupt_ms.part.tpl'),
          x_format_sm=self.Part('types/format/interrupt_sm.part.tpl'),
          x_wrapeport=self.Part('types/wrapeport/interrupt.part.tpl'),
          x_wrapeconv=self.Part('types/wrapeconv/interrupt.part.tpl'),
          x_wrapipmap=self.Part('types/wrapipmap/interrupt.part.tpl'),
          x_wrapigmap=None,
          x_tlogic=self.tlogic,
          x_tctx=self.tctx,
          x_tsrc=self.tisrc,
          x_cnull=lambda t: Con('InterruptNull', t, value=Lit({})))

    def get_ports(self):
      ports = [PortI('sys', self.tsys, x_wrapname='ap'),
               PortM('intr', self.tintr, x_wrapname='interrupt'),
               PortS('ctrl', self.tctrl, x_wrapname='s_axi_ctrl_reg'),
               PortM('hmem', self.thost, x_wrapname='m_axi_host_mem')]

      if self.AxiDdrEnabled:
        ports.append(PortM('cmem', self.tddr, x_wrapname='m_axi_card_mem0'))

      if self.AxiHbmEnabled:
        for i in range(self.AxiHbmCount):
          ports.append(PortM('hbm{:d}'.format(i), self.thbm,
              x_wrapname='m_axi_card_hbm_p{:d}'.format(i)))

      if self.StmEthEnabled:
        ports.append(PortM('ethTx', self.teth, x_wrapname='dout_eth'))
        ports.append(PortS('ethRx', self.teth, x_wrapname='din_eth'))
        ports.append(PortO('ethRxRst', self.tlogic, x_wrapname='eth_rx_fifo_reset'))
        ports.append(PortI('ethRxStatus', self.tlogic, x_wrapname='eth_stat_rx_status'))
        ports.append(PortI('ethRxAligned', self.tlogic, x_wrapname='eth_stat_rx_aligned'))

      return ports

OCAccelEnv = _OCAccelEnv()
