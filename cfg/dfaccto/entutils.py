Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)


class _Util(ModuleContext):
  def __init__(self):
    super().__init__()
    self._pkg_util = Pkg('dfaccto_util',
        x_templates={self.File('pkg/util.vhd.tpl'): self.File('pkg/dfaccto_util.vhd')})
    self._defined = dict()

  @property
  def package(self):
    return self._pkg_util

  @property
  def Arbiter(self):
    name = 'UtilArbiter'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/Arbiter.vhd.tpl') : self.File('ent/Arbiter.vhd')})
    return self._defined[name]

  @property
  def ArbiterStable(self):
    name = 'UtilArbiterStable'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/ArbiterStable.vhd.tpl') : self.File('ent/ArbiterStable.vhd')})
    return self._defined[name]


  @property
  def Barrier(self):
    name = 'UtilBarrier'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/Barrier.vhd.tpl') : self.File('ent/Barrier.vhd')})
    return self._defined[name]

  @property
  def Stage(self):
    name = 'UtilStage'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/Stage.vhd.tpl') : self.File('ent/Stage.vhd')})
    return self._defined[name]

  @property
  def MemorySP(self):
    name = 'UtilMemorySP'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/MemorySP.vhd.tpl') : self.File('ent/MemorySP.vhd')})
    return self._defined[name]

  @property
  def MemorySDP(self):
    name = 'UtilMemorySDP'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/MemorySDP.vhd.tpl') : self.File('ent/MemorySDP.vhd')})
    return self._defined[name]

  @property
  def FifoFast(self):
    name = 'UtilFifoFast'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_templates={self.File('entity/util/FifoFast.vhd.tpl') : self.File('ent/FifoFast.vhd')})
    return self._defined[name]

  @property
  def FifoLarge(self):
    name = 'UtilFifoLarge'
    if name not in self._defined:
      self._defined[name] = Ent(name,
          x_util=self._pkg_util,
          x_ememsdp=self.MemorySDP,
          x_templates={self.File('entity/util/FifoLarge.vhd.tpl') : self.File('ent/FifoLarge.vhd')})
    return self._defined[name]

Util = _Util()


