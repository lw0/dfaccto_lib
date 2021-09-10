
def Check(type, **directives):
  for key,value in directives.items():
    if getattr(type, key, None) != value:
      raise AssertionError('{} must have {} set to {}'.format(type, key, value))


class CheckUnsigned:
  def __init__(self, type):
    if not getattr(type, 'x_is_unsigned', False):
      raise AssertionError('{} must be an Unsigned type'.format(type))
    self._type = type

  @property
  def width(self):
    return self._type.x_width

  def req_width(self, bits):
    if self.width != bits:
      raise AssertionError('{} must be {:d} bits wide'.format(self._type, bits))
    return self


class CheckAxi:
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


class CheckAxiStream:
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


class CheckRegPort:
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


class CheckEvent:
  def __init__(self, type):
    if not getattr(type, 'x_is_event', False):
      raise AssertionError('{} must be an Event type'.format(type))
    self._type = type

  @property
  def stb_bits(self):
    return self._type.x_tsdata and self._type.x_tsdata.x_width

  @property
  def ack_bits(self):
    return self._type.x_tadata and self._type.x_tadata.x_width

  def req_stb(self, spec):
    if spec is False:
      if self.stb_bits is not None:
        raise AssertionError('{} must not have stb data signals'.format(self._type))
    elif spec is True:
      if self.stb_bits is None:
        raise AssertionError('{} must have stb data signals'.format(self._type))
    elif self.stb_bits != spec:
      raise AssertionError('{} must have {:d} stb data bits'.format(self._type, spec))

  def req_ack(self, spec):
    if spec is False:
      if self.ack_bits is not None:
        raise AssertionError('{} must not have ack data signals'.format(self._type))
    elif spec is True:
      if self.ack_bits is None:
        raise AssertionError('{} must have ack data signals'.format(self._type))
    elif self.ack_bits != spec:
      raise AssertionError('{} must have {:d} ack data bits'.format(self._type, spec))
