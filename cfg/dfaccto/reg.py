Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)


with Pkg('dfaccto_reg',
    x_templates={File('generic/package.vhd.tpl'): File('pkg/dfaccto_reg.vhd')}):
  TypeS('RegMap',
      x_definition=Part('types/definition/regmap.part.tpl'),
      x_format=Part('types/format/regmap.part.tpl'),
      x_tsize=T('Size', 'dfaccto'),
      x_wrapeport=None,
      x_wrapeconv=None,
      x_wrapipmap=None,
      x_wrapigmap=None,
      x_cnull=lambda t: Con('RegMapNull', t, value=Lit({})))

class RegEntry:
  def __init__(self, offset, count, signal):
    self.offset = offset
    self.count = count
    self.signal = signal

class RegMap:
  def __init__(self, *entries):
    if not all(isinstance(e, RegEntry) for e in entries):
      raise AssertionError('RegMap must be constructed with RegEntry arguments')
    self._entries = entries

  def LitPorts(self):
    return tuple(Lit(e) for e in self._entries)

  def SigPorts(self):
    return tuple(S(e.signal) for e in self._entries)

def _TypeRegPort(ctx, name, data_bytes, addr_bits):
  taddr = TypeUnsigned('{}Addr'.format(name), width=addr_bits)
  tdata = TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
  tstrb = TypeUnsigned('{}Strb'.format(name), width=data_bytes)
  return TypeC(name, x_is_regport=True,
               x_definition=ctx.Part('types/definition/regport.part.tpl'),
               x_format_ms=ctx.Part('types/format/regport_ms.part.tpl'),
               x_format_sm=ctx.Part('types/format/regport_sm.part.tpl'),
               x_wrapeport=ctx.Part('types/wrapeport/regport.part.tpl'),
               x_wrapeconv=ctx.Part('types/wrapeconv/regport.part.tpl'),
               x_wrapipmap=ctx.Part('types/wrapipmap/regport.part.tpl'),
               x_wrapigmap=None,
               x_taddr=taddr, x_tdata=tdata, x_tstrb=tstrb,
               x_tlogic=T('Logic', 'dfaccto'),
               x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({})))
TypeRegPort = ModuleContext(_TypeRegPort)

class RegPortCheck:

  def __init__(self, type):
    if not getattr(type, 'x_is_regport', False):
      raise AssertionError('{} must be a RegPort type'.format(type))
    self._type = type

  @property
  def data_bits(self):
    return self._type.x_tdata.x_width

  @property
  def addr_bits(self):
    return self._type.x_taddr.x_width

  def req_data(self, spec):
    if self.data_bits != spec:
      raise AssertionError('{} must have {:d} data bits'.format(self._type, spec))
    return self

  def req_addr(self, spec):
    if self.addr_bits != spec:
      raise AssertionError('{} must have {:d} addr bits'.format(self._type, spec))
    return self


