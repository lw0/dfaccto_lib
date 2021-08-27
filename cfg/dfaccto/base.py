Inc('dfaccto/utils.py', abs=True)


with Pkg('dfaccto',
    x_templates={File('generic/package.vhd.tpl'): File('pkg/dfaccto.vhd')}):

  TypeS('Bool',
        x_definition=Part('types/definition/bool.part.tpl'),
        x_format=Part('types/format/bool.part.tpl'),
        x_wrapeport=None,
        x_wrapeconv=None,
        x_wrapipmap=None,
        x_wrapigmap=None,
        x_cnull=lambda t: Con('BoolNull', t, value=Lit(False)))

  TypeS('String',
        x_definition=Part('types/definition/string.part.tpl'),
        x_format=Part('types/format/string.part.tpl'),
        x_wrapeport=None,
        x_wrapeconv=None,
        x_wrapipmap=None,
        x_wrapigmap=None,
        x_cnull=lambda t: Con('StringNull', t, value=Lit('')))

  TypeS('Time', # base unit nanoseconds
        x_definition=Part('types/definition/time.part.tpl'),
        x_format=Part('types/format/time.part.tpl'),
        x_wrapeport=None,
        x_wrapeconv=None,
        x_wrapipmap=None,
        x_wrapigmap=None,
        x_cnull=lambda t: Con('TimeNull', t, value=Lit(0)))

  TypeInteger('Integer')

  TypeInteger('Size', min=0)

  TypeS('Logic',
        x_definition=Part('types/definition/logic.part.tpl'),
        x_format=Part('types/format/logic.part.tpl'),
        x_wrapeport=Part('types/wrapeport/logic.part.tpl'),
        x_wrapeconv=Part('types/wrapeconv/logic.part.tpl'),
        x_wrapipmap=Part('types/wrapipmap/logic.part.tpl'),
        x_wrapigmap=None,
        x_cnull=lambda t: Con('LogicNull', t, value=Lit(False)))

  TypeS('Sys', x_is_sys=True,
        x_definition=Part('types/definition/sys.part.tpl'),
        x_format=Part('types/format/sys.part.tpl'),
        x_wrapeport=Part('types/wrapeport/sys.part.tpl'),
        x_wrapeconv=Part('types/wrapeconv/sys.part.tpl'),
        x_wrapipmap=Part('types/wrapipmap/sys.part.tpl'),
        x_wrapigmap=None,
        x_tlogic=T('Logic', 'dfaccto'),
        x_cnull=lambda t: Con('SysNull', t, value=Lit({'clk': False, 'rst_n': False})))

