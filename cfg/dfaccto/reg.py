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

def _TypeRegPort(ctx, name, addr_bits, data_bytes=4):
  taddr = TypeUnsigned('{}Addr'.format(name), width=addr_bits)
  tdata = TypeUnsigned('{}Data'.format(name), width=data_bytes * 8)
  tstrb = TypeUnsigned('{}Strb'.format(name), width=data_bytes)
  return TypeC(name, x_is_regport=True,
               x_definition=ctx.Part('types/definition/regport.part'),
               x_format_ms=ctx.Part('types/format/regport_ms.part'),
               x_format_sm=ctx.Part('types/format/regport_sm.part'),
               x_wrapeport=ctx.Part('types/wrapeport/regport.part'),
               x_wrapeconv=ctx.Part('types/wrapeconv/regport.part'),
               x_wrapipmap=ctx.Part('types/wrapipmap/regport.part'),
               x_wrapigmap=None,
               x_taddr=taddr, x_tdata=tdata, x_tstrb=tstrb,
               x_tlogic=T('Logic', 'dfaccto'),
               x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit({})))
TypeRegPort = ModuleContext(_TypeRegPort)

