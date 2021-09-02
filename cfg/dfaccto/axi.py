Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)

with Pkg('dfaccto_axi',
    x_templates={File('generic/package.vhd.tpl'): File('pkg/dfaccto_axi.vhd')}):

  TypeUnsigned('AxiLen', width=8)

  TypeUnsigned('AxiSize', width=3)

  TypeUnsigned('AxiBurst', width=2,
      x_cfixed=lambda t: Con('AxiBurstFixed', t, value=Lit(0)),
      x_cincr=lambda t: Con('AxiBurstIncr', t, value=Lit(1)),
      x_cwrap=lambda t: Con('AxiBurstWrap', t, value=Lit(2)))

  TypeUnsigned('AxiLock', width=2,
      x_cnormal=lambda t: Con('AxiLockNormal', t, value=Lit(0)),
      x_cexclusive=lambda t: Con('AxiLockExclusive', t, value=Lit(1)),
      x_clocked=lambda t: Con('AxiLockLocked', t, value=Lit(2)))

  TypeUnsigned('AxiCache', width=4,
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

  TypeUnsigned('AxiProt', width=3,
      x_cpriv=lambda t: Con('AxiProtFlagPriv', t, value=Lit(0b001)),
      x_csec=lambda t: Con('AxiProtFlagSec', t, value=Lit(0b010)),
      x_cinst=lambda t: Con('AxiProtFlagInst', t, value=Lit(0b100)))

  TypeUnsigned('AxiQos', width=4)

  TypeUnsigned('AxiRegion', width=4)

  TypeUnsigned('AxiResp', width=2,
      x_cokay=lambda t: Con('AxiRespOkay', t, value=Lit(0)),
      x_cexokay=lambda t: Con('AxiRespExOkay', t, value=Lit(1)),
      x_cslverr=lambda t: Con('AxiRespSlvErr', t, value=Lit(2)),
      x_cdecerr=lambda t: Con('AxiRespDecErr', t, value=Lit(3)))


def _TypeAxi(ctx, name, data_bytes, addr_bits, id_bits=None,
    has_wid=False, has_burst=True, has_attr=False,
    has_lock=None, has_cache=None, has_prot=None, has_qos=None, has_region=None,
    aruser_bits=None, awuser_bits=None, ruser_bits=None, wuser_bits=None, buser_bits=None):

  assert data_bytes in (1, 2, 4, 8, 16, 32, 64, 128), \
    'Axi only supports power-of-two byte counts up to 128'
  word_idx_bits = uwidth(data_bytes - 1)
  word_addr_bits = addr_bits - word_idx_bits
  assert word_addr_bits >= 0, \
    'Axi address range must at least include a single data word'

  tdata = TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
  tstrb = TypeUnsigned('{}Strb'.format(name), width=data_bytes)
  taddr = TypeUnsigned('{}Addr'.format(name), width=addr_bits)
  twidx = TypeUnsigned('{}WordIdx'.format(name), width=word_idx_bits)
  twaddr = TypeUnsigned('{}WordAddr'.format(name), width=word_addr_bits)
  clen = T('AxiLen', 'dfaccto_axi').x_cnull
  csize = Con('{}FullSize'.format(name), T('AxiSize', 'dfaccto_axi'), value=Lit(word_idx_bits))
  cburst = T('AxiBurst', 'dfaccto_axi').x_cnull

  tlogic = T('Logic', 'dfaccto')
  tresp = T('AxiResp', 'dfaccto_axi')
  if id_bits is not None:
    tid = TypeUnsigned('{}Id'.format(name), width=id_bits)
  else:
    tid = None
  if has_wid:
    twid = tid
  else:
    twid = None
  if aruser_bits is not None:
    taruser = TypeUnsigned('{}ARUser'.format(name), width=aruser_bits)
  else:
    taruser = None
  if awuser_bits is not None:
    tawuser = TypeUnsigned('{}AWUser'.format(name), width=awuser_bits)
  else:
    tawuser = None
  if ruser_bits is not None:
    truser = TypeUnsigned('{}RUser'.format(name), width=ruser_bits)
  else:
    truser = None
  if wuser_bits is not None:
    twuser = TypeUnsigned('{}WUser'.format(name), width=wuser_bits)
  else:
    twuser = None
  if buser_bits is not None:
    tbuser = TypeUnsigned('{}BUser'.format(name), width=buser_bits)
  else:
    tbuser = None

  if has_burst:
    tlen = T('AxiLen', 'dfaccto_axi')
    tsize = T('AxiSize', 'dfaccto_axi')
    tburst = T('AxiBurst', 'dfaccto_axi')
    tlast = tlogic
  else:
    tlen = None
    tsize = None
    tburst = None
    tlast = None
  if has_attr if has_lock is None else has_lock:
    tlock = T('AxiLock', 'dfaccto_axi')
  else:
    tlock = None
  if has_attr if has_cache is None else has_cache:
    tcache = T('AxiCache', 'dfaccto_axi')
  else:
    tcache = None
  if has_attr if has_prot is None else has_prot:
    tprot = T('AxiProt', 'dfaccto_axi')
  else:
    tprot = None
  if has_attr if has_qos is None else has_qos:
    tqos = T('AxiQos', 'dfaccto_axi')
  else:
    tqos = None
  if has_attr if has_region is None else has_region:
    tregion = T('AxiRegion', 'dfaccto_axi')
  else:
    tregion = None

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
          x_definition=ctx.Part('types/definition/axi.part.tpl'),
          x_format_ms=ctx.Part('types/format/axi_ms.part.tpl'),
          x_format_sm=ctx.Part('types/format/axi_sm.part.tpl'),
          x_wrapeport=ctx.Part('types/wrapeport/axi.part.tpl'),
          x_wrapeconv=ctx.Part('types/wrapeconv/axi.part.tpl'),
          x_wrapipmap=ctx.Part('types/wrapipmap/axi.part.tpl'),
          x_wrapigmap=ctx.Part('types/wrapigmap/axi.part.tpl'),
          x_has_aw=hasaw, x_has_w=hasw, x_has_b=hasb,
          x_has_ar=hasar, x_has_r=hasr,
          x_lst_aw=not hasw and not hasb and not hasar and not hasr,
          x_fst_w=not hasaw,
          x_lst_w=not hasb and not hasar and not hasr,
          x_fst_b=not hasaw and not hasw,
          x_lst_b=not hasar and not hasr,
          x_fst_ar=not hasaw and not hasw and not hasb,
          x_lst_ar=not hasr,
          x_fst_r=not hasaw and not hasw and not hasb and not hasaw,
          x_tlogic=tlogic, x_tresp=tresp, x_tdata=tdata, x_tstrb=tstrb,
          x_taddr=taddr, x_twidx=twidx, x_twaddr=twaddr,
          x_tlen=tlen, x_tsize=tsize, x_tburst=tburst, x_tlast=tlast,
          x_clen=clen, x_csize=csize, x_cburst=cburst,
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
TypeAxi = ModuleContext(_TypeAxi)


class AxiCheck:

  def __init__(self, type):
    if not getattr(type, 'x_is_axi', False):
      raise AssertionError('{} must be an Axi type'.format(type))
    self._type = type

  @property
  def variant(self):
    return self._type.x_axi_variant

  @property
  def data_bits(self):
    return self._type.x_tdata.x_width

  @property
  def addr_bits(self):
    return self._type.x_taddr.x_width

  @property
  def id_bits(self):
    return self._type.x_tid and self._type.x_tid.x_width

  @property
  def is_axi3(self):
    return self._type.x_twid is not None

  @property
  def any_burst(self):
    return any((self._type.x_tlen is not None,
                self._type.x_tsize is not None,
                self._type.x_tburst is not None,
                self._type.x_tlast is not None))

  @property
  def all_burst(self):
    return all((self._type.x_tlen is not None,
                self._type.x_tsize is not None,
                self._type.x_tburst is not None,
                self._type.x_tlast is not None))

  @property
  def any_attr(self):
    return any((self._type.x_tlock is not None,
                self._type.x_tcache is not None,
                self._type.x_tprot is not None,
                self._type.x_tqos is not None,
                self._type.x_tregion is not None))

  @property
  def all_attr(self):
    return all((self._type.x_tlock is not None,
                self._type.x_tcache is not None,
                self._type.x_tprot is not None,
                self._type.x_tqos is not None,
                self._type.x_tregion is not None))

  @property
  def any_user(self):
    return any((self._type.x_tawuser is not None,
                self._type.x_twuser is not None,
                self._type.x_tbuser is not None,
                self._type.x_taruser is not None,
                self._type.x_truser is not None))

  @property
  def all_user(self):
    return all((self._type.x_tawuser is not None,
                self._type.x_twuser is not None,
                self._type.x_tbuser is not None,
                self._type.x_taruser is not None,
                self._type.x_truser is not None))

  @property
  def awuser_bits(self):
    return self._type.x_tawuser and self._type.x_tawuser.x_width

  @property
  def wuser_bits(self):
    return self._type.x_twuser and self._type.x_twuser.x_width

  @property
  def buser_bits(self):
    return self._type.x_tbuser and self._type.x_tbuser.x_width

  @property
  def aruser_bits(self):
    return self._type.x_taruser and self._type.x_taruser.x_width

  @property
  def ruser_bits(self):
    return self._type.x_truser and self._type.x_truser.x_width

  def req_variant(self, spec):
    if spec is None:
      if self.variant is not None:
        raise AssertionError('{} must not be an Axi variant type'.format(self._type))
    elif self.variant != spec: #TODO-lw this is incorrect, because of `and` above!
        raise AssertionError('{} must be an Axi {} type'.format(self._type, spec))
    return self

  def req_addr(self, bits):
    if self.addr_bits != bits:
      raise AssertionError('{} must have {:d} address bits'.format(self._type, bits))
    return self

  def req_data(self, bits):
    if self.data_bits != bits:
      raise AssertionError('{} must have {:d} data bits'.format(self._type, bits))
    return self

  def req_id(self, spec):
    if spec is False:
      if self.id_bits is not None:
        raise AssertionError('{} must not have id bits'.format(self._type))
    elif spec is True:
      if self.id_bits is None:
        raise AssertionError('{} must have id bits'.format(self._type))
    elif self.id_bits != spec:
      raise AssertionError('{} must have {:d} id bits'.format(self._type, spec))
    return self

  def req_axi3(self, spec):
    if spec is False and self.is_axi3:
      raise AssertionError('{} must not be an AXI3 type'.format(self._type))
    elif spec is True and not self.is_axi3:
      raise AssertionError('{} must be an AXI3 type'.format(self._type))
    return self

  def req_burst(self, spec):
    if spec is False and self.any_burst:
      raise AssertionError('{} must not have burst signals'.format(self._type))
    elif spec is True and not self.all_burst:
      raise AssertionError('{} must have burst signals'.format(self._type))
    return self

  def req_any_attr(self, spec):
    if spec is False and self.any_attr:
      raise AssertionError('{} must not have any attribute signals'.format(self._type))
    elif spec is True and not self.any_attr:
      raise AssertionError('{} must have some attribute signals'.format(self._type))
    return self

  def req_all_attr(self, spec):
    if spec is False and self.all_attr:
      raise AssertionError('{} must not have all attribute signals'.format(self._type))
    elif spec is True and not self.all_attr:
      raise AssertionError('{} must have all attribute signals'.format(self._type))
    return self

  def req_any_user(self, spec):
    if spec is False and self.any_user:
      raise AssertionError('{} must not have any user signals'.format(self._type))
    elif spec is True and not self.any_user:
      raise AssertionError('{} must have some user signals'.format(self._type))
    return self

  def req_all_user(self, spec):
    if spec is False and self.all_user:
      raise AssertionError('{} must not have all user signals'.format(self._type))
    elif spec is True and not self.all_user:
      raise AssertionError('{} must have all user signals'.format(self._type))
    return self

  def req_awuser(self, spec):
    if spec is False:
      if self.awuser_bits is not None:
        raise AssertionError('{} must not have an awuser signal'.format(self._type))
    elif spec is True:
      if self.awuser_bits is None:
        raise AssertionError('{} must have an awuser signal'.format(self._type))
    elif self.awuser_bits != spec:
      raise AssertionError('{} must have {:d} awuser bits'.format(self._type, spec))
    return self

  def req_wuser(self, spec):
    if spec is False:
      if self.wuser_bits is not None:
        raise AssertionError('{} must not have an wuser signal'.format(self._type))
    elif spec is True:
      if self.wuser_bits is None:
        raise AssertionError('{} must have an wuser signal'.format(self._type))
    elif self.wuser_bits != spec:
      raise AssertionError('{} must have {:d} wuser bits'.format(self._type, spec))
    return self

  def req_buser(self, spec):
    if spec is False:
      if self.buser_bits is not None:
        raise AssertionError('{} must not have an buser signal'.format(self._type))
    elif spec is True:
      if self.buser_bits is None:
        raise AssertionError('{} must have an buser signal'.format(self._type))
    elif self.buser_bits != spec:
      raise AssertionError('{} must have {:d} buser bits'.format(self._type, spec))
    return self

  def req_aruser(self, spec):
    if spec is False:
      if self.aruser_bits is not None:
        raise AssertionError('{} must not have an aruser signal'.format(self._type))
    elif spec is True:
      if self.aruser_bits is None:
        raise AssertionError('{} must have an aruser signal'.format(self._type))
    elif self.aruser_bits != spec:
      raise AssertionError('{} must have {:d} aruser bits'.format(self._type, spec))
    return self

  def req_ruser(self, spec):
    if spec is False:
      if self.ruser_bits is not None:
        raise AssertionError('{} must not have an ruser signal'.format(self._type))
    elif spec is True:
      if self.ruser_bits is None:
        raise AssertionError('{} must have an ruser signal'.format(self._type))
    elif self.ruser_bits != spec:
      raise AssertionError('{} must have {:d} ruser bits'.format(self._type, spec))
    return self


def _TypeAxiStream(ctx, name, data_bytes, id_bits=None,
    dest_bits=None, user_bits=None,
    has_strb=False, has_keep=True, has_last=True):

  tdata = TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
  if has_strb:
    tstrb = TypeUnsigned('{}Strb'.format(name), width=data_bytes)
  else:
    tstrb = None
  if has_keep:
    tkeep = TypeUnsigned('{}Keep'.format(name), width=data_bytes) if tstrb is None else tstrb
  else:
    tkeep = None
  if id_bits is not None:
    tid = TypeUnsigned('{}Id'.format(name), width=id_bits)
  else:
    tid = None
  if dest_bits is not None:
    tdest = TypeUnsigned('{}Dest'.format(name), width=user_bits)
  else:
    tdest = None
  if user_bits is not None:
    tuser = TypeUnsigned('{}User'.format(name), width=user_bits)
  else:
    tuser = None
  tlogic = T('Logic', 'dfaccto')

  return TypeC(name, x_is_axi_stream=True,
      x_definition=ctx.Part('types/definition/axis.part.tpl'),
      x_format_ms=ctx.Part('types/format/axis_ms.part.tpl'),
      x_format_sm=ctx.Part('types/format/axis_sm.part.tpl'),
      x_wrapeport=ctx.Part('types/wrapeport/axis.part.tpl'),
      x_wrapeconv=ctx.Part('types/wrapeconv/axis.part.tpl'),
      x_wrapipmap=ctx.Part('types/wrapipmap/axis.part.tpl'),
      x_wrapigmap=None,
      x_has_last=bool(has_last), x_tlogic=tlogic,
      x_tdata=tdata, x_tstrb=tstrb, x_tkeep=tkeep,
      x_tid=tid, x_tdest=tdest, x_tuser=tuser,
      x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({})))
TypeAxiStream = ModuleContext(_TypeAxiStream)


class AxiStreamCheck:

  def __init__(self, type):
    if not getattr(type, 'x_is_axi_stream', False):
      raise AssertionError('{} must be an AxiStream type'.format(type))
    self._type = type

  @property
  def data_bits(self):
    return self._type.x_tdata.x_width

  @property
  def has_keep(self):
    return self._type.x_tkeep is not None

  @property
  def has_strb(self):
    return self._type.x_tstrb is not None

  @property
  def id_bits(self):
    return self._type.x_tid and self._type.x_tid.x_width

  @property
  def dest_bits(self):
    return self._type.x_tdest and self._type.x_tdest.x_width

  @property
  def user_bits(self):
    return self._type.x_tuser and self._type.x_tuser.x_width

  def req_data(self, spec):
    if self.data_bits != spec:
      raise AssertionError('{} must have {:d} data bits'.format(self._type, spec))
    return self

  def req_keep(self, spec):
    if spec is False and self.has_keep:
      raise AssertionError('{} must not have keep signals'.format(self._type))
    elif spec is True and not self.has_keep:
      raise AssertionError('{} must have keep signals'.format(self._type))
    return self

  def req_strb(self, spec):
    if spec is False and self.has_strb:
      raise AssertionError('{} must not have strb signals'.format(self._type))
    elif spec is True and not self.has_strb:
      raise AssertionError('{} must have strb signals'.format(self._type))
    return self

  def req_id(self, spec):
    if spec is False:
      if self.id_bits is not None:
        raise AssertionError('{} must not have id signals'.format(self._type))
    elif spec is True:
      if self.id_bits is None:
        raise AssertionError('{} must have id signals'.format(self._type))
    elif self.id_bits != spec:
      raise AssertionError('{} must have {:d} id bits'.format(self._type, spec))
    return self

  def req_dest(self, spec):
    if spec is False:
      if self.dest_bits is not None:
        raise AssertionError('{} must not have dest signals'.format(self._type))
    elif spec is True:
      if self.dest_bits is None:
        raise AssertionError('{} must have dest signals'.format(self._type))
    elif self.dest_bits != spec:
      raise AssertionError('{} must have {:d} dest bits'.format(self._type, spec))
    return self

  def req_user(self, spec):
    if spec is False:
      if self.user_bits is not None:
        raise AssertionError('{} must not have user signals'.format(self._type))
    elif spec is True:
      if self.user_bits is None:
        raise AssertionError('{} must have user signals'.format(self._type))
    elif self.user_bits != spec:
      raise AssertionError('{} must have {:d} user bits'.format(self._type, spec))
    return self

