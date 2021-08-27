Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)


def _TypeEvent(ctx, name, stb_bits=None, ack_bits=None):

  tlogic = T('Logic', 'dfaccto')

  if stb_bits is not None:
    tsdata = TypeUnsigned('{}Strb'.format(name), width=stb_bits)
  else:
    tsdata = None

  if ack_bits is not None:
    tadata = TypeUnsigned('{}Ack'.format(name), width=ack_bits)
  else:
    tadata = None

  TypeC(name, x_is_event=True,
        x_definition=ctx.Part('types/definition/event.part.tpl'),
        x_format_ms=ctx.Part('types/format/event_ms.part.tpl'),
        x_format_sm=ctx.Part('types/format/event_sm.part.tpl'),
        x_wrapeport=ctx.Part('types/wrapeport/event.part.tpl'),
        x_wrapeconv=ctx.Part('types/wrapeconv/event.part.tpl'),
        x_wrapipmap=ctx.Part('types/wrapipmap/event.part.tpl'),
        x_wrapigmap=None,
        x_tlogic=tlogic, x_tsdata=tsdata, x_tadata=tadata,
        x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({'stb': False, 'ack': False})))
TypeEvent = ModuleContext(_TypeEvent)

