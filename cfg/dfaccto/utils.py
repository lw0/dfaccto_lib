

class ModuleContext:
  def __init__(self, func=None):
    self._mod = Mod()
    self._func = func

  def Part(self, name):
    return Part(name, mod=self._mod)

  def File(self, name):
    return File(name, mod=self._mod)

  def Mod(self):
    return self._mod

  def __call__(self, *args, **kwargs):
    if self._func is not None:
      return self._func(self, *args, **kwargs)


def _TypeInteger(ctx, name, min=None, max=None):
  return TypeS(name,
      x_min=min,
      x_max=max,
      x_definition=ctx.Part('types/definition/integer.part.tpl'),
      x_format=ctx.Part('types/format/integer.part.tpl'),
      x_wrapeport=None,
      x_wrapeconv=None,
      x_wrapipmap=None,
      x_wrapigmap=None,
      x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit(0)))
TypeInteger = ModuleContext(_TypeInteger)


def _TypeUnsigned(ctx, name, width, **directives):
  return TypeS(name,
      x_is_unsigned=True,
      x_width=width,
      x_definition=ctx.Part('types/definition/unsigned.part.tpl'),
      x_format=ctx.Part('types/format/unsigned.part.tpl'),
      x_wrapeport=ctx.Part('types/wrapeport/unsigned.part.tpl'),
      x_wrapeconv=ctx.Part('types/wrapeconv/unsigned.part.tpl'),
      x_wrapipmap=ctx.Part('types/wrapipmap/unsigned.part.tpl'),
      x_wrapigmap=None,
      x_cnull=lambda t: Con('{}Null'.format(name), t, value=Lit(0)),
      **directives)
TypeUnsigned = ModuleContext(_TypeUnsigned)


def uwidth(x):
    assert x >= 0, 'Can not compute unsigned width on a negative value'
    return x.bit_length()


def swidth(x):
    if x < 0:
        x = ~x
    return x.bit_length() + 1
