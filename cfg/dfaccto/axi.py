Inc('dfaccto/util.py', abs=True)
Inc('dfaccto/check.py', abs=True)


class _Axi(ModuleContext):

  def __init__(self):
    ModuleContext.__init__(self)
    self._setup_packages()
    self._setup_oneshots()

  def _setup_packages(self):
    self._pkg_axi = Pkg('dfaccto_axi',
        x_templates={File('generic/package.vhd.tpl'): File('pkg/dfaccto_axi.vhd')})

    with self._pkg_axi:
      self.cbound = Con('AxiBound', Util.tsize, value=Lit(12)) # 4KiB = 2**12

      self.tlen = Util.TypeUnsigned('AxiLen', width=8)

      self.tsize = Util.TypeUnsigned('AxiSize', width=3)

      self.tburst = Util.TypeUnsigned('AxiBurst', width=2,
          x_cfixed=lambda t: Con('AxiBurstFixed', t, value=Lit(0)),
          x_cincr=lambda t: Con('AxiBurstIncr', t, value=Lit(1)),
          x_cwrap=lambda t: Con('AxiBurstWrap', t, value=Lit(2)))

      self.tlock = Util.TypeUnsigned('AxiLock', width=2,
          x_cnormal=lambda t: Con('AxiLockNormal', t, value=Lit(0)),
          x_cexclusive=lambda t: Con('AxiLockExclusive', t, value=Lit(1)),
          x_clocked=lambda t: Con('AxiLockLocked', t, value=Lit(2)))

      self.tcache = Util.TypeUnsigned('AxiCache', width=4,
          x_cdn=lambda t: Con('AxiCacheDevNoBuf', t, value=Lit(0b0000)),
          x_cdb=lambda t: Con('AxiCacheDevBuf', t, value=Lit(0b0001)),
          x_cnn=lambda t: Con('AxiCacheNormNoBuf', t, value=Lit(0b0010)),
          x_cnb=lambda t: Con('AxiCacheNormBuf', t, value=Lit(0b0011)),
          x_ctrn=lambda t: Con('AxiCacheThruRdNoA', t, value=Lit(0b1010)),
          x_ctwn=lambda t: Con('AxiCacheThruWrNoA', t, value=Lit(0b0110)),
          x_cta=lambda t: Con('AxiCacheThruAlloc', t, value=Lit(0b1110)),
          x_cwrn=lambda t: Con('AxiCacheBackRdNoA', t, value=Lit(0b1011)),
          x_cwwn=lambda t: Con('AxiCacheBackWrNoA', t, value=Lit(0b0111)),
          x_cwa=lambda t: Con('AxiCacheBackAlloc', t, value=Lit(0b1111)))

      self.tprot = Util.TypeUnsigned('AxiProt', width=3,
          x_cpriv=lambda t: Con('AxiProtFlagPriv', t, value=Lit(0b001)),
          x_csec=lambda t: Con('AxiProtFlagSec', t, value=Lit(0b010)),
          x_cinst=lambda t: Con('AxiProtFlagInst', t, value=Lit(0b100)))

      self.tqos = Util.TypeUnsigned('AxiQos', width=4)

      self.tregion = Util.TypeUnsigned('AxiRegion', width=4)

      self.tresp = Util.TypeUnsigned('AxiResp', width=2,
          x_cokay=lambda t: Con('AxiRespOkay', t, value=Lit(0)),
          x_cexokay=lambda t: Con('AxiRespExOkay', t, value=Lit(1)),
          x_cslverr=lambda t: Con('AxiRespSlvErr', t, value=Lit(2)),
          x_cdecerr=lambda t: Con('AxiRespDecErr', t, value=Lit(3)))

  def _setup_oneshots(self):
    self._register_oneshot('AddrMachine',
        lambda self: Ent('AxiAddrMachine',
            x_util=Util.pkg_util,
            x_efifo=Util.FifoFast,
            x_templates={self.File('entity/axi/AddrMachine.vhd.tpl'): self.File('entity/axi/AddrMachine.vhd')}))
  @property
  def pkg_axi(self):
    return self._pkg_axi

  def TypeAxi(self, name, data_bytes, addr_bits, id_bits=None,
      has_wid=False, has_burst=True, has_attr=False,
      has_lock=None, has_cache=None, has_prot=None, has_qos=None, has_region=None,
      aruser_bits=None, awuser_bits=None, ruser_bits=None, wuser_bits=None, buser_bits=None):

    assert data_bytes in (1, 2, 4, 8, 16, 32, 64, 128), \
      'Axi only supports power-of-two byte counts up to 128'
    word_idx_bits = uwidth(data_bytes - 1)
    word_addr_bits = addr_bits - word_idx_bits
    assert word_addr_bits >= 0, \
      'Axi address range must at least include a single data word'

    tdata   = Util.TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
    tstrb   = Util.TypeUnsigned('{}Strb'.format(name), width=data_bytes)
    taddr   = Util.TypeUnsigned('{}Addr'.format(name), width=addr_bits)
    twidx   = Util.TypeUnsigned('{}WordIdx'.format(name), width=word_idx_bits)
    twaddr  = Util.TypeUnsigned('{}WordAddr'.format(name), width=word_addr_bits)
    clen    = self.tlen.x_cnull
    csize   = Con('{}FullSize'.format(name), self.tsize, value=Lit(word_idx_bits))
    cburst  = self.tburst.x_cnull
    cwbound = Con('{}WordBound'.format(name), Util.tsize, value=Lit(12 - word_idx_bits))

    tid     = Util.TypeUnsigned('{}Id'.format(name), width=id_bits) if id_bits is not None else None
    twid    = tid if has_wid else None

    taruser = Util.TypeUnsigned('{}ARUser'.format(name), width=aruser_bits) if aruser_bits is not None else None
    tawuser = Util.TypeUnsigned('{}AWUser'.format(name), width=awuser_bits) if awuser_bits is not None else None
    truser  = Util.TypeUnsigned('{}RUser'.format(name), width=ruser_bits) if ruser_bits is not None else None
    twuser  = Util.TypeUnsigned('{}WUser'.format(name), width=wuser_bits) if wuser_bits is not None else None
    tbuser  = Util.TypeUnsigned('{}BUser'.format(name), width=buser_bits) if buser_bits is not None else None

    tlen    = self.tlen    if has_burst else None
    tsize   = self.tsize   if has_burst else None
    tburst  = self.tburst  if has_burst else None
    tlast   = Util.tlogic  if has_burst else None
    tlock   = self.tlock   if (has_attr if has_lock is None else has_lock) else None
    tcache  = self.tcache  if (has_attr if has_cache is None else has_cache) else None
    tprot   = self.tprot   if (has_attr if has_prot is None else has_prot) else None
    tqos    = self.tqos    if (has_attr if has_qos is None else has_qos) else None
    tregion = self.tregion if (has_attr if has_region is None else has_region) else None

    variants = [(name,                None, True,  True,  True,  True, True),
                ('{}Wr'.format(name), 'wr', True,  True,  True,  False, False),
                ('{}Rd'.format(name), 'rd', False, False, False, True, True),
                ('{}AW'.format(name), 'aw', True,  False, False, False, False) ,
                ('{}W'.format(name),  'w',  False, True,  False, False, False),
                ('{}B'.format(name),  'b',  False, False, True,  False, False),
                ('{}AR'.format(name), 'ar', False, False, False, True , False) ,
                ('{}R'.format(name),  'r',  False, False, False, False, True)]

    types = {}
    for variant, label, hasaw, hasw, hasb, hasar, hasr in variants:
      types[label] = TypeC(variant, x_is_axi=True, x_axi_variant=label,
            x_definition=self.Part('types/definition/axi.part.tpl'),
            x_format_ms=self.Part('types/format/axi_ms.part.tpl'),
            x_format_sm=self.Part('types/format/axi_sm.part.tpl'),
            x_wrapeport=self.Part('types/wrapeport/axi.part.tpl'),
            x_wrapeconv=self.Part('types/wrapeconv/axi.part.tpl'),
            x_wrapipmap=self.Part('types/wrapipmap/axi.part.tpl'),
            x_wrapigmap=self.Part('types/wrapigmap/axi.part.tpl'),
            x_has_aw=hasaw, x_has_w=hasw, x_has_b=hasb,
            x_has_ar=hasar, x_has_r=hasr,
            x_lst_aw=not hasw and not hasb and not hasar and not hasr,
            x_fst_w=not hasaw,
            x_lst_w=not hasb and not hasar and not hasr,
            x_fst_b=not hasaw and not hasw,
            x_lst_b=not hasar and not hasr,
            x_fst_ar=not hasaw and not hasw and not hasb,
            x_lst_ar=not hasr,
              x_fst_r=not hasaw and not hasw and not hasb and not hasar,
            x_tlogic=Util.tlogic, x_tresp=self.tresp, x_tdata=tdata, x_tstrb=tstrb,
            x_taddr=taddr, x_twidx=twidx, x_twaddr=twaddr,
            x_tlen=tlen, x_tsize=tsize, x_tburst=tburst, x_tlast=tlast,
            x_clen=clen, x_csize=csize, x_cburst=cburst,
            x_cbound=self.cbound, x_cwbound=cwbound,
            x_tid=tid, x_twid=twid, x_taruser=taruser, x_tawuser=tawuser,
            x_truser=truser, x_twuser=twuser, x_tbuser=tbuser,
            x_tlock=tlock, x_tcache=tcache, x_tprot=tprot,
            x_tqos=tqos, x_tregion=tregion,
            x_cnull=lambda t: Con('{}Null'.format(variant), t, value=Lit({'awsize': word_idx_bits, 'arsize': word_idx_bits})))

    for type in types.values():
      for label, ref_type in types.items():
        if label is None:
          type.set_prop('tmain'.format(label), ref_type)
        else:
          type.set_prop('tpart_{}'.format(label), ref_type)
    return types[None]

  def TypeStream(self, name, data_bytes, id_bits=None,
    dest_bits=None, user_bits=None,
    has_strb=False, has_keep=True, has_last=True):

    tdata = Util.TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
    if has_strb or has_keep:
      tmask = Util.TypeUnsigned('{}{}'.format(name, 'Strb' if has_strb else 'Keep'), width=data_bytes)
    tstrb = tmask if has_strb else None
    tkeep = tmask if has_keep else None
    tid   = Util.TypeUnsigned('{}Id'.format(name), width=id_bits) if id_bits is not None else None
    tdest = Util.TypeUnsigned('{}Dest'.format(name), width=user_bits) if dest_bits is not None else None
    tuser = Util.TypeUnsigned('{}User'.format(name), width=user_bits) if user_bits is not None else None

    return TypeC(name, x_is_axi_stream=True,
        x_definition=self.Part('types/definition/axis.part.tpl'),
        x_format_ms=self.Part('types/format/axis_ms.part.tpl'),
        x_format_sm=self.Part('types/format/axis_sm.part.tpl'),
        x_wrapeport=self.Part('types/wrapeport/axis.part.tpl'),
        x_wrapeconv=self.Part('types/wrapeconv/axis.part.tpl'),
        x_wrapipmap=self.Part('types/wrapipmap/axis.part.tpl'),
        x_wrapigmap=None,
        x_has_last=bool(has_last), x_tlogic=Util.tlogic,
        x_tdata=tdata, x_tstrb=tstrb, x_tkeep=tkeep,
        x_tid=tid, x_tdest=tdest, x_tuser=tuser,
        x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({})))

  def EntWiring(self, name, master_type, slave_type, x_file,
                master_mode='full', slave_mode='full', **directives):
    # modes:
    #   full:    (AW, W, B, AR, R)
    #   split:   (AW, W, B), (AR, R)
    #   chans:   (AW), (W), (B), (AR), (R)
    #   wr:      (AW, W, B)
    #   wrchans: (AW), (W), (B)
    #   rd:      (AR, R)
    #   rdchans: (AR), (R)
    #   none:
    CheckAxi(master_type).req_variant(None)
    CheckAxi(slave_type).req_variant(None)
    if master_mode not in ('full', 'wr_rd', 'aw_w_b_ar_r', 'wr', 'aw_w_b', 'rd', 'ar_r', 'none'):
      raise AssertionError('Invalid master_mode "{}"'.format(master_mode))
    if slave_mode not in ('full', 'wr_rd', 'aw_w_b_ar_r', 'wr', 'aw_w_b', 'rd', 'ar_r', 'none'):
      raise AssertionError('Invalid slave_mode "{}"'.format(slave_mode))

    ports = [PortI('sys', Util.tsys, label='psys')]
    if master_mode in ('full',):
      ports.append(PortM('master',   master_type,            labels=('pm', 'pmaw', 'pmw', 'pmb', 'pmar', 'pmr')))
    if master_mode in ('wr_rd', 'wr'):
      ports.append(PortM('masterWr', master_type.x_tpart_wr, labels=('pmwr', 'pmaw', 'pmw', 'pmb')))
    if master_mode in ('wr_rd', 'rd'):
      ports.append(PortM('masterRd', master_type.x_tpart_rd, labels=('pmrd', 'pmar', 'pmr')))
    if master_mode in ('aw_w_b_ar_r', 'aw_w_b'):
      ports.append(PortM('masterAW', master_type.x_tpart_aw,  label='pmaw'))
      ports.append(PortM('masterW',  master_type.x_tpart_w,  label='pmw'))
      ports.append(PortM('masterB',  master_type.x_tpart_b,  label='pmb'))
    if master_mode in ('aw_w_b_ar_r', 'ar_r'):
      ports.append(PortM('masterAR', master_type.x_tpart_ar,  label='pmar'))
      ports.append(PortM('masterR',  master_type.x_tpart_r,  label='pmr'))

    if slave_mode in ('full',):
      ports.append(PortS('slave',   slave_type,            labels=('ps', 'psaw', 'psw', 'psb', 'psar', 'psr')))
    if slave_mode in ('wr_rd', 'wr'):
      ports.append(PortS('slaveWr', slave_type.x_tpart_wr, labels=('pswr', 'psaw', 'psw', 'psb')))
    if slave_mode in ('wr_rd', 'rd'):
      ports.append(PortS('slaveRd', slave_type.x_tpart_rd, labels=('psrd', 'psar', 'psr')))
    if slave_mode in ('aw_w_b_ar_r', 'aw_w_b'):
      ports.append(PortS('slaveAW', slave_type.x_tpart_aw,  label='psaw'))
      ports.append(PortS('slaveW',  slave_type.x_tpart_w,  label='psw'))
      ports.append(PortS('slaveB',  slave_type.x_tpart_b,  label='psb'))
    if slave_mode in ('aw_w_b_ar_r', 'ar_r'):
      ports.append(PortS('slaveAR', slave_type.x_tpart_ar,  label='psar'))
      ports.append(PortS('slaveR',  slave_type.x_tpart_r,  label='psr'))

    return Ent(name, *ports,
        x_util=Util.pkg_util,
        x_templates={self.File('entity/axi/Wiring.vhd.tpl'): x_file},
        **directives)

  def EntWrMux(self, name, axi_type, x_file_split, x_file_join, x_file):
    CheckAxi(axi_type).req_variant(None).req_any_attr(False).req_any_user(False)
    # TODO-lw handle presence of ID signals, switch different template?
    #   current RdMux template handles IDs incorrectly
    #   (simply passes through without handling possible reordering)

    ejoin = self.EntWiring('{}Joiner'.format(name),
        master_type=axi_type, slave_type=axi_type,
        master_mode='wr', slave_mode='aw_w_b',
        x_file=x_file_join)

    esplit = self.EntWiring('{}Splitter'.format(name),
        master_type=axi_type, slave_type=axi_type,
        master_mode='aw_w_b', slave_mode='wr',
        x_file=x_file_split)

    return Ent(name,
        Generic('FifoLogDepth', Util.tsize, label='gdepth', default=Lit(3)),
        Generic('PortCount', Util.tsize, label='gcount'),
        PortI('sys', Util.tsys, label='psys'),
        PortM('master', axi_type.x_tpart_wr, label='pm'),
        PortS('slaves', axi_type.x_tpart_wr, vector='PortCount', label='psv'),
        x_esplit=esplit, x_ejoin=ejoin,
        x_earbiter=Util.ArbiterStable,
        x_ebarrier=Util.Barrier,
        x_efifo=Util.FifoFast,
        x_util=Util.pkg_util,
        x_templates={self.File('entity/axi/WrMux.vhd.tpl'): x_file})

  def EntRdMux(self, name, axi_type, x_file_split, x_file_join, x_file):
    CheckAxi(axi_type).req_variant(None).req_any_attr(False).req_any_user(False)
    # TODO-lw handle presence of ID signals, switch different template?
    #   current RdMux template handles IDs incorrectly
    #   (simply passes through without handling possible reordering)

    ejoin = self.EntWiring('{}Joiner'.format(name),
        master_type=axi_type, slave_type=axi_type,
        master_mode='rd', slave_mode='ar_r',
        x_file=x_file_join)

    esplit = self.EntWiring('{}Splitter'.format(name),
        master_type=axi_type, slave_type=axi_type,
        master_mode='ar_r', slave_mode='rd',
        x_file=x_file_split)

    return Ent(name,
        Generic('FifoLogDepth', Util.tsize, label='gdepth', default=Lit(3)),
        Generic('PortCount', Util.tsize, label='gcount'),
        PortI('sys', Util.tsys, label='psys'),
        PortM('master', axi_type.x_tpart_rd, label='pm'),
        PortS('slaves', axi_type.x_tpart_rd, vector='PortCount', label='psv'),
        x_esplit=esplit, x_ejoin=ejoin,
        x_earbiter=Util.ArbiterStable,
        x_ebarrier=Util.Barrier,
        x_efifo=Util.FifoFast,
        x_util=Util.pkg_util,
        x_templates={self.File('entity/axi/RdMux.vhd.tpl'): x_file})

  def EntWriter(self, name, axi_type, stm_type, reg_type, x_file):
    axi_info = CheckAxi(axi_type).req_variant(None).req_burst(True).req_any_attr(False).req_any_user(False)
    CheckAxiStream(stm_type).req_data(axi_info.data_bits).req_id(False).req_dest(False).req_user(False)
    CheckRegPort(reg_type)

    return Ent(name,
        Generic('FifoLogDepth', Util.tsize, label='gdepth', default=Lit(3)),
        PortI('sys', Util.tsys, label='psys'),
        PortS('start', Event.tEvent, label='pstart'),
        PortI('hold', Util.tlogic, label='phold', default=Lit(False)),
        PortS('reg', reg_type, label='preg'),
        PortM('axi', axi_type.x_tpart_wr, label='paxi'),
        PortS('stm', stm_type, label='pstm'),
        x_eamach=self.AddrMachine,
        x_util=Util.pkg_util,
        x_templates={self.File('entity/axi/Writer.vhd.tpl'): x_file})

  def EntReader(self, name, axi_type, stm_type, reg_type, x_file):
    axi_info = CheckAxi(axi_type).req_variant(None).req_burst(True).req_any_attr(False).req_any_user(False)
    CheckAxiStream(stm_type).req_data(axi_info.data_bits).req_id(False).req_dest(False).req_user(False)
    CheckRegPort(reg_type)

    return Ent(name,
        Generic('FifoLogDepth', Util.tsize, label='gdepth', default=Lit(3)),
        PortI('sys', Util.tsys, label='psys'),
        PortS('reg', reg_type, label='preg'),
        PortS('start', Event.tEvent, label='pstart'),
        PortI('hold', Util.tlogic, label='phold', default=Lit(False)),
        PortM('axi', axi_type.x_tpart_rd, label='paxi'),
        PortM('stm', stm_type, label='pstm'),
        x_eamach=self.AddrMachine,
        x_util=Util.pkg_util,
        x_templates={self.File('entity/axi/Reader.vhd.tpl'): x_file})

Axi = _Axi()

