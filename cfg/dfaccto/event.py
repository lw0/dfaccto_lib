Inc('dfaccto/util.py', abs=True)


class _Event(ModuleContext):
  def __init__(self):
    ModuleContext.__init__(self)
    self._setup_packages()

  def _setup_packages(self):
    self.pkg = Pkg('dfaccto_event',
        x_templates={self.File('generic/package.vhd.tpl'): self.File('pkg/dfaccto_event.vhd')})

    with self.pkg:
      self.tEvent = self.TypeEvent('Event')

  def TypeEvent(self, name, stb_bits=None, ack_bits=None):

    tlogic = Util.tlogic

    if stb_bits is not None:
      tsdata = Util.TypeUnsigned('{}Strb'.format(name), width=stb_bits)
    else:
      tsdata = None

    if ack_bits is not None:
      tadata = Util.TypeUnsigned('{}Ack'.format(name), width=ack_bits)
    else:
      tadata = None

    return TypeC(name, x_is_event=True,
          x_definition=self.Part('types/definition/event.part.tpl'),
          x_format_ms=self.Part('types/format/event_ms.part.tpl'),
          x_format_sm=self.Part('types/format/event_sm.part.tpl'),
          x_wrapeport=self.Part('types/wrapeport/event.part.tpl'),
          x_wrapeconv=self.Part('types/wrapeconv/event.part.tpl'),
          x_wrapipmap=self.Part('types/wrapipmap/event.part.tpl'),
          x_wrapigmap=None,
          x_tlogic=tlogic, x_tsdata=tsdata, x_tadata=tadata,
          x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({'stb': False, 'ack': False})))

Event = _Event()
