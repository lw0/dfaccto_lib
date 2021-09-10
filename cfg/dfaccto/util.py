

class ModuleContext:
  def __init__(self, func=None):
    self._mod = Mod()
    self._func = func
    self._oneshot_funcs = dict()
    self._oneshot_values = dict()

  def _register_oneshot(self, name, func):
    self._oneshot_funcs[name] = func

  def _get_oneshot(self, name):
    if name not in self._oneshot_values:
      self._oneshot_values[name] = self._oneshot_funcs[name](self)
    return self._oneshot_values[name]

  def Part(self, name):
    return Part(name, mod=self._mod)

  def File(self, name):
    return File(name, mod=self._mod)

  def Mod(self):
    return self._mod

  def __call__(self, *args, **kwargs):
    if self._func is not None:
      return self._func(self, *args, **kwargs)

  def __getattr__(self, key):
    if key in self._oneshot_funcs:
      return self._get_oneshot(key)
    else:
      raise AttributeError(key)


class _Util(ModuleContext):
  def __init__(self):
    ModuleContext.__init__(self)
    self._setup_packages()
    self._setup_oneshots()

  def _setup_packages(self):
    self._pkg_util = Pkg('dfaccto_util',
        x_templates={self.File('pkg/util.vhd.tpl'): self.File('pkg/dfaccto_util.vhd')})

    self._pkg_type = Pkg('dfaccto_type',
        x_templates={self.File('generic/package.vhd.tpl'): self.File('pkg/dfaccto_type.vhd')})

    with self._pkg_type:
      self.tbool = TypeS('Bool', x_is_nosynth=True,
            x_definition=self.Part('types/definition/bool.part.tpl'),
            x_format=self.Part('types/format/bool.part.tpl'),
            x_cnull=lambda t: Con('BoolNull', t, value=Lit(False)))

      self.tstring = TypeS('String', x_is_nosynth=True,
            x_definition=self.Part('types/definition/string.part.tpl'),
            x_format=self.Part('types/format/string.part.tpl'),
            x_cnull=lambda t: Con('StringNull', t, value=Lit('')))

      self.ttime = TypeS('Time', x_is_nosynth=True, # base unit nanoseconds
            x_definition=self.Part('types/definition/time.part.tpl'),
            x_format=self.Part('types/format/time.part.tpl'),
            x_cnull=lambda t: Con('TimeNull', t, value=Lit(0)))

      self.tint = self.TypeInteger('Integer')

      self.tsize = self.TypeInteger('Size', min=0)

      self.tlogic = TypeS('Logic', x_is_logic=True,
            x_definition=self.Part('types/definition/logic.part.tpl'),
            x_format=self.Part('types/format/logic.part.tpl'),
            x_wrapeport=self.Part('types/wrapeport/logic.part.tpl'),
            x_wrapeconv=self.Part('types/wrapeconv/logic.part.tpl'),
            x_wrapipmap=self.Part('types/wrapipmap/logic.part.tpl'),
            x_wrapigmap=None,
            x_cnull=lambda t: Con('LogicNull', t, value=Lit(False)))

      self.tsys = TypeS('Sys', x_is_sys=True,
            x_definition=self.Part('types/definition/sys.part.tpl'),
            x_format=self.Part('types/format/sys.part.tpl'),
            x_wrapeport=self.Part('types/wrapeport/sys.part.tpl'),
            x_wrapeconv=self.Part('types/wrapeconv/sys.part.tpl'),
            x_wrapipmap=self.Part('types/wrapipmap/sys.part.tpl'),
            x_wrapigmap=None,
            x_tlogic=self.tlogic,
            x_cnull=lambda t: Con('SysNull', t, value=Lit({'clk': False, 'rst_n': False})))


  def _setup_oneshots(self):
    self._register_oneshot('Arbiter',
        lambda ctx: Ent('UtilArbiter',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/Arbiter.vhd.tpl') : ctx.File('entity/util/Arbiter.vhd')}))

    self._register_oneshot('ArbiterStable',
        lambda ctx: Ent('UtilArbiterStable',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/ArbiterStable.vhd.tpl') : ctx.File('entity/util/ArbiterStable.vhd')}))

    self._register_oneshot('Barrier',
        lambda ctx: Ent('UtilBarrier',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/Barrier.vhd.tpl') : ctx.File('entity/util/Barrier.vhd')}))

    self._register_oneshot('Stage',
        lambda ctx: Ent('UtilStage',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/Stage.vhd.tpl') : ctx.File('entity/util/Stage.vhd')}))

    self._register_oneshot('MemorySP',
        lambda ctx: Ent('UtilMemorySP',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/MemorySP.vhd.tpl') : ctx.File('entity/util/MemorySP.vhd')}))

    self._register_oneshot('MemorySDP',
        lambda ctx: Ent('UtilMemorySDP',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/MemorySDP.vhd.tpl') : ctx.File('entity/util/MemorySDP.vhd')}))

    self._register_oneshot('FifoFast',
        lambda ctx: Ent('UtilFifoFast',
            x_util=ctx._pkg_util,
            x_templates={ctx.File('entity/util/FifoFast.vhd.tpl') : ctx.File('entity/util/FifoFast.vhd')}))

    self._register_oneshot('FifoLarge',
        lambda ctx: Ent('UtilFifoLarge',
            x_util=ctx._pkg_util,
            x_ememsdp=ctx.MemorySDP,
            x_templates={ctx.File('entity/util/FifoLarge.vhd.tpl') : ctx.File('entity/util/FifoLarge.vhd')}))

  @property
  def pkg_util(self):
    return self._pkg_util

  @property
  def pkg_type(self):
    return self._pkg_type

  def TypeInteger(self, name, min=None, max=None):
    return TypeS(name, x_is_nosynth=True,
        x_min=min,
        x_max=max,
        x_definition=self.Part('types/definition/integer.part.tpl'),
        x_format=self.Part('types/format/integer.part.tpl'),
        x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit(0)))

  def TypeUnsigned(self, name, width, **directives):
    return TypeS(name, x_is_unsigned=True,
        x_width=width,
        x_definition=self.Part('types/definition/unsigned.part.tpl'),
        x_format=self.Part('types/format/unsigned.part.tpl'),
        x_wrapeport=self.Part('types/wrapeport/unsigned.part.tpl'),
        x_wrapeconv=self.Part('types/wrapeconv/unsigned.part.tpl'),
        x_wrapipmap=self.Part('types/wrapipmap/unsigned.part.tpl'),
        x_wrapigmap=None,
        x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit(0)),
        **directives)

Util = _Util()


def uwidth(x):
    assert x >= 0, 'Can not compute unsigned width on a negative value'
    return x.bit_length()


def swidth(x):
    if x < 0:
        x = ~x
    return x.bit_length() + 1


