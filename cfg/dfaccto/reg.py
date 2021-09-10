Inc('dfaccto/util.py', abs=True)
Inc('dfaccto/check.py', abs=True)


class _Reg(ModuleContext):
  def __init__(self):
    ModuleContext.__init__(self)
    self._setup_packages()

  def _setup_packages(self):
    self._pkg_reg = Pkg('dfaccto_reg',
        x_templates={File('generic/package.vhd.tpl'): File('pkg/dfaccto_reg.vhd')})

    with self._pkg_reg:
      self.tmap = TypeS('RegMap', x_is_regmap=True,
          x_definition=self.Part('types/definition/regmap.part.tpl'),
          x_format=self.Part('types/format/regmap.part.tpl'),
          x_tsize=Util.tsize,
          x_cnull=lambda t: Con('RegMapNull', t, value=Lit({})))

  class _Entry:
    def __init__(self, offset, count, signal):
      self.offset = offset
      self.count = count
      self.signal = signal

  class _Map:
    def __init__(self, entries):
      if not all(isinstance(e, tuple) and len(e) == 3 for e in entries):
        raise AssertionError('RegMap must be constructed from 3-tuples (offset, count, sigName)')
      self._entries = tuple(_Reg._Entry(*e) for e in entries)

    def LitPorts(self):
      return tuple(Lit(e) for e in self._entries)

    def SigPorts(self):
      return tuple(S(e.signal) for e in self._entries)

  def Map(self, *entries):
    return _Reg._Map(entries)

  def TypePort(self, name, data_bytes, addr_bits):
    taddr = Util.TypeUnsigned('{}Addr'.format(name), width=addr_bits)
    tdata = Util.TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
    tstrb = Util.TypeUnsigned('{}Strb'.format(name), width=data_bytes)
    return TypeC(name, x_is_regport=True,
                 x_definition=self.Part('types/definition/regport.part.tpl'),
                 x_format_ms=self.Part('types/format/regport_ms.part.tpl'),
                 x_format_sm=self.Part('types/format/regport_sm.part.tpl'),
                 x_wrapeport=self.Part('types/wrapeport/regport.part.tpl'),
                 x_wrapeconv=self.Part('types/wrapeconv/regport.part.tpl'),
                 x_wrapipmap=self.Part('types/wrapipmap/regport.part.tpl'),
                 x_wrapigmap=None,
                 x_taddr=taddr, x_tdata=tdata, x_tstrb=tstrb,
                 x_tlogic=Util.tlogic,
                 x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({})))

  def EntDemux(self, name, axi_type, reg_type, x_file):
    axi_info = CheckAxi(axi_type).req_id(False).req_burst(False).req_any_attr(False).req_any_user(False)
    CheckRegPort(reg_type).req_data(axi_info.data_bits)

    return Ent(name,
        Generic('PortCount', Util.tsize, label='gcount'),
        Generic('Ports', self.tmap, vector='PortCount', label='gports'),
        PortI('sys', Util.tsys, label='psys'),
        PortS('axi', axi_type, label='paxi'),
        PortM('ports', reg_type, vector='PortCount', label='pports'),
        x_util=Util.pkg_util,
        x_templates={self.File('entity/reg/Demux.vhd.tpl'): x_file})

  def EntFile(self, name, reg_type, x_file):
    CheckRegPort(reg_type)

    return Ent(name,
        Generic('RegCount', Util.tsize,                          label='gcount'),
        PortI('sys',        Util.tsys,                           label='psys'),
        PortS('reg',        reg_type,                            label='preg'),
        PortI('rdValues',   reg_type.x_tdata, vector='RegCount', label='prdval'),
        PortO('wrValues',   reg_type.x_tdata, vector='RegCount', label='pwrval'),
        PortO('rdEvent',    Util.tlogic,                         label='prdevt'),
        PortO('wrEvent',    Util.tlogic,                         label='pwrevt'),
        PortO('rdEvents',   Util.tlogic,      vector='RegCount', label='prdevts'),
        PortO('wrEvents',   Util.tlogic,      vector='RegCount', label='pwrevts'),
        x_util=Util.pkg_util,
        x_templates={self.File('entity/reg/File.vhd.tpl'): x_file})

Reg = _Reg()

