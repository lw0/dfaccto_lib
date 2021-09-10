Inc('dfaccto/util.py', abs=True)
Inc('dfaccto/axi.py', abs=True)
Inc('dfaccto/event.py', abs=True)
Inc('dfaccto/reg.py', abs=True)


class _OCAccel(ModuleContext):

  def __init__(self):
    ModuleContext.__init__(self)
    self._read_config()
    self._setup_oneshots()

  def _read_config(self):
    import os
    self.ContextBits = 9
    self.InterruptBits = 64
    self.Ctrl_DataBytes = 4
    self.Ctrl_AddrBits_Ctx = 32
    self.Ctrl_AddrBits_NoCtx = self.Ctrl_AddrBits_Ctx - self.ContextBits - 1 # bit 31 always 0 (selects global vs action register space)
    self.Host_DataBytes = 64 if os.environ.get('ACTION_HALF_WIDTH', False) else 128
    self.Host_AddrBits = 64
    self.Host_IdBits = os.environ.get('AXI_ID_WIDTH', 5)
    self.Host_UserBits = 1
    self.Ddr_DataBytes = 64
    self.Ddr_AddrBits = 33
    self.Ddr_IdBits = 4
    self.Ddr_UserBits = 1
    self.DdrEnabled = 'ENABLE_DDR' in os.environ
    self.Hbm_DataBytes = 32
    self.Hbm_AddrBits = 34
    self.Hbm_IdBits = 4
    self.Hbm_UserBits = 1
    self.HbmEnabled = 'ENABLE_HBM' in os.environ
    self.HbmCount = int(os.environ.get('HBM_AXI_IF_NUM', '1'))
    self.Eth_DataBytes = 64
    self.Eth_UserBits = 1
    self.EthEnabled = os.environ.get('ETHERNET_USED', 'FALSE') == 'TRUE'

  def _setup_oneshots(self):
    self._register_oneshot('pkg',
        lambda self: Pkg('dfaccto_ocaccel',
            x_templates={self.File('generic/package.vhd.tpl'): self.File('pkg/dfaccto_ocaccel.vhd')}))
    self._register_oneshot('tCtrlCtx',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiCtrlCtx',
                data_bytes=self.Ctrl_DataBytes,
                addr_bits=self.Ctrl_AddrBits_Ctx,
                has_burst=False)))
    self._register_oneshot('tCtrl',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiCtrl',
                data_bytes=self.Ctrl_DataBytes,
                addr_bits=self.Ctrl_AddrBits_NoCtx,
                has_burst=False)))
    self._register_oneshot('tCtrlRegCtx',
        lambda self: self._in_pkg(
            lambda self: Reg.TypePort('CtrlRegCtx',
                data_bytes=self.Ctrl_DataBytes,
                addr_bits=self.Ctrl_AddrBits_Ctx)))
    self._register_oneshot('tCtrlReg',
        lambda self: self._in_pkg(
            lambda self: Reg.TypePort('CtrlReg',
                data_bytes=self.Ctrl_DataBytes,
                addr_bits=self.Ctrl_AddrBits_NoCtx)))
    self._register_oneshot('tHost_ext',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiHostExt',
                data_bytes=self.Host_DataBytes,
                addr_bits=self.Host_AddrBits,
                id_bits=self.Host_IdBits,
                has_attr=True,
                aruser_bits=self.ContextBits,
                awuser_bits=self.ContextBits,
                ruser_bits=self.Host_UserBits,
                wuser_bits=self.Host_UserBits,
                buser_bits=self.Host_UserBits)))
    self._register_oneshot('tHostCtx',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiHostCtx',
                data_bytes=self.Host_DataBytes,
                addr_bits=self.Host_AddrBits,
                id_bits=self.Host_IdBits,
                aruser_bits=self.ContextBits,
                awuser_bits=self.ContextBits)))
    self._register_oneshot('tHost',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiHost',
                data_bytes=self.Host_DataBytes,
                addr_bits=self.Host_AddrBits,
                id_bits=self.Host_IdBits)))
    self._register_oneshot('tDdr_ext',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiDdrExt',
                data_bytes=self.Ddr_DataBytes,
                addr_bits=self.Ddr_AddrBits,
                id_bits=self.Ddr_IdBits,
                has_attr=True,
                aruser_bits=self.Ddr_UserBits,
                awuser_bits=self.Ddr_UserBits,
                ruser_bits=self.Ddr_UserBits,
                wuser_bits=self.Ddr_UserBits,
                buser_bits=self.Ddr_UserBits)))
    self._register_oneshot('tDdr',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiDdr',
                data_bytes=self.Ddr_DataBytes,
                addr_bits=self.Ddr_AddrBits,
                id_bits=self.Ddr_IdBits)))
    self._register_oneshot('tHbm_ext',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiHbmExt',
                data_bytes=self.Hbm_DataBytes,
                addr_bits=self.Hbm_AddrBits,
                id_bits=self.Hbm_IdBits,
                has_attr=True,
                aruser_bits=self.Hbm_UserBits,
                awuser_bits=self.Hbm_UserBits,
                ruser_bits=self.Hbm_UserBits,
                wuser_bits=self.Hbm_UserBits,
                buser_bits=self.Hbm_UserBits)))
    self._register_oneshot('tHbm',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeAxi('AxiHbm',
                data_bytes=self.Hbm_DataBytes,
                addr_bits=self.Hbm_AddrBits,
                id_bits=self.Hbm_IdBits)))
    self._register_oneshot('tEth',
        lambda self: self._in_pkg(
            lambda self: Axi.TypeStream('StmEth',
              data_bytes=self.Eth_DataBytes,
              user_bits=self.Eth_UserBits)))
    self._register_oneshot('tCtx',
        lambda self: self._in_pkg(
            lambda self: Util.TypeUnsigned('Context', width=self.ContextBits)))
    self._register_oneshot('tIntrSrc',
        lambda self: self._in_pkg(
            lambda self: Util.TypeUnsigned('InterruptSrc', width=self.InterruptBits)))
    self._register_oneshot('tIntrCtx',
        lambda self: self._in_pkg(
            lambda self: TypeC('InterruptCtx', x_is_interrupt=True,
                x_definition=self.Part('types/definition/interrupt.part.tpl'),
                x_format_ms=self.Part('types/format/interrupt_ms.part.tpl'),
                x_format_sm=self.Part('types/format/interrupt_sm.part.tpl'),
                x_wrapeport=self.Part('types/wrapeport/interrupt.part.tpl'),
                x_wrapeconv=self.Part('types/wrapeconv/interrupt.part.tpl'),
                x_wrapipmap=self.Part('types/wrapipmap/interrupt.part.tpl'),
                x_wrapigmap=None,
                x_tlogic=Util.tlogic,
                x_tctx=self.tCtx,
                x_tsrc=self.tIntrSrc,
                x_cnull=lambda t: Con('InterruptCtxNull', t, value=Lit({})))))
    self._register_oneshot('tIntr',
        lambda self: self._in_pkg(
            lambda self: Event.TypeEvent('Interrupt',
                stb_bits=self.InterruptBits)))
    self._register_oneshot('EntCtrlDemux',
        lambda self: Reg.EntDemux('OCAccelCtrlDemux',
            axi_type=OCAccel.tCtrl,
            reg_type=OCAccel.tCtrlReg,
            x_file=self.File('entity/ocaccel/CtrlDemux.vhd')))
    self._register_oneshot('EntRegFile',
        lambda self: Reg.EntFile('OCAccelRegFile',
            reg_type=self.tCtrlReg,
            x_file=self.File('entity/ocaccel/RegFile.vhd')))
    self._register_oneshot('EntControl',
        lambda self: Ent('OCAccelControl',
            Generic('StartCount', Util.tsize, label='gscount'),
            Generic('ExtIrqCount', Util.tsize, label='gicount'),
            Generic('ActionType', Util.tsize, label='gactyp'),
            Generic('ActionVersion', Util.tsize, label='gacver'),
            PortI('sys', Util.tsys, label='psys'),
            PortS('reg', self.tCtrlReg, label='preg'),
            PortM('intr', self.tIntr, label='pintr'),
            PortM('start', Event.tEvent , vector='StartCount', label='pstart'),
            PortS('irq',  Event.tEvent, vector='ExtIrqCount', label='pirq'),
            x_ebarrier=Util.Barrier,
            x_earbiter=Util.ArbiterStable,
            x_eregfile=self.EntRegFile,
            x_util=Util.pkg_util,
            x_templates={self.File('entity/ocaccel/Control.vhd.tpl'): self.File('entity/ocaccel/Control.vhd')}))
    self._register_oneshot('EntSimplifyHost',
        lambda self: Axi.EntWiring('OCAccelSimplifyHost',
            master_type=self.tHost_ext,
            slave_type=self.tHostCtx,
            master_mode='full',
            slave_mode='full',
            x_file=self.File('entity/ocaccel/SimplifyHost.vhd')))
    self._register_oneshot('EntSimplifyDdr',
        lambda self: Axi.EntWiring('OCAccelSimplifyDdr',
            master_type=self.tDdr_ext,
            slave_type=self.tDdr,
            master_mode='full',
            slave_mode='full',
            x_file=self.File('entity/ocaccel/SimplifyDdr.vhd')))
    self._register_oneshot('EntSimplifyHbm',
        lambda self: Axi.EntWiring('OCAccelSimplifyHbm',
            master_type=self.tHbm_ext,
            slave_type=self.tHbm,
            master_mode='full',
            slave_mode='full',
            x_file=self.File('entity/ocaccel/SimplifyHbm.vhd')))
    self._register_oneshot('EntSingleContext',
        lambda self: Ent('OCAccelSingleContext',
            PortI('sysCtx', Util.tsys, label='psysc'),
            PortM('intrCtx', self.tIntrCtx, label='pintrc'),
            PortS('ctrlCtx', self.tCtrlCtx, label='pctrlc'),
            PortM('hostCtx', self.tHostCtx, label='phostc'),
            PortO('sys', Util.tsys, label='psys'),
            PortS('intr', self.tIntr, label='pintr'),
            PortM('ctrl', self.tCtrl, label='pctrl'),
            PortS('host', self.tHost, label='phost'),
            x_util=Util.pkg_util,
            x_templates={self.File('entity/ocaccel/SingleContext.vhd.tpl'): self.File('entity/ocaccel/SingleContext.vhd')}))

  def _in_pkg(self, func):
    with self.pkg:
      return func(self)

  def EntWrapper(self, name, single_context, x_file):
    psys_name = 'sysCtx' if single_context else 'sys'
    pintr_name = 'intrCtx' if single_context else 'intr'
    pctrl_name = 'ctrlCtx' if single_context else 'ctrl'
    shost_name = 'hostCtx' if single_context else 'host'

    ports = [PortI(psys_name,  Util.tsys,      x_wrapname='ap'),
             PortM(pintr_name, self.tIntrCtx,  x_wrapname='interrupt'),
             PortS(pctrl_name, self.tCtrlCtx, x_wrapname='s_axi_ctrl_reg'),
             PortM('host_ext', self.tHost_ext, x_wrapname='m_axi_host_mem')]
    if self.DdrEnabled:
      ports.append(PortM('ddr', self.tDdr_ext, x_wrapname='m_axi_card_mem0'))
    if self.HbmEnabled:
      for i in range(self.HbmCount):
        name = 'hbm{:d}'.format(i)
        wrapname = 'm_axi_card_hbm_p{:d}'.format(i)
        ports.append(PortM(name, self.tHbm_ext, x_wrapname=wrapname))
    if self.EthEnabled:
      ports.append(PortM('ethTx',        self.tEth,   x_wrapname='dout_eth'))
      ports.append(PortS('ethRx',        self.tEth,   x_wrapname='din_eth'))
      ports.append(PortO('ethRxRst',     Util.tlogic, x_wrapname='eth_rx_fifo_reset'))
      ports.append(PortI('ethRxStatus',  Util.tlogic, x_wrapname='eth_stat_rx_status'))
      ports.append(PortI('ethRxAligned', Util.tlogic, x_wrapname='eth_stat_rx_aligned'))

    ewrap = Ent(name, *ports,
      x_templates={self.File('generic/ext_wrapper.vhd.tpl'): x_file})
    with ewrap:
      Ins(self.EntSimplifyHost.name, 'simplifyHost',
          MapPort('master', S('host_ext')),
          MapPort('slave', S(shost_name)))
      if self.DdrEnabled:
        Ins(self.EntSimplifyDdr.name, 'simplifyDdr',
            MapPort('master', S('ddr_ext')),
            MapPort('slave', S('ddr')))
      if self.HbmEnabled:
        for i in range(self.HbmCount):
          Ins(self.EntSimplifyHbm.name, 'simplifyHbm{:d}'.format(i),
              MapPort('master', S('hbm{:d}_ext'.format(i))),
              MapPort('slave', S('hbm{:d}'.format(i))))
      if single_context:
        Ins(self.EntSingleContext.name, 'singleContext',
            MapPort('sysCtx', S(psys_name)),
            MapPort('intrCtx', S(pintr_name)),
            MapPort('ctrlCtx', S(pctrl_name)),
            MapPort('hostCtx', S(shost_name)),
            MapPort('sys', S('sys')),
            MapPort('intr', S('intr')),
            MapPort('ctrl', S('ctrl')),
            MapPort('host', S('host')))

      S('host').set_default((self.tHost if single_context else self.tHostCtx).x_cnull)
      if self.DdrEnabled:
        S('ddr').set_default(self.tDdr.x_cnull)
      if self.HbmEnabled:
        for i in range(self.HbmCount):
          S('hbm{:d}', expand=i).set_default(self.tHbm.x_cnull)
    return ewrap

OCAccel = _OCAccel()
