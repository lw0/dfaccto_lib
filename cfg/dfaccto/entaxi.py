Inc('dfaccto/utils.py', abs=True)
Inc('dfaccto/base.py', abs=True)
Inc('dfaccto/entutils.py', abs=True)
Inc('dfaccto/axi.py', abs=True)
Inc('dfaccto/reg.py', abs=True)


def _EntAxiWiring(ctx, name, master_type, slave_type, x_file,
      master_mode='full', slave_mode='full', **directives):
  # modes:
  #   full:    (AW, W, B, AR, R)
  #   split:   (AW, W, B), (AR, R)
  #   chans:   (AW), (W), (B), (AR), (R)
  #   wr:      (AW, W, B)
  #   wrchans: (AW), (W), (B)
  #   rd:      (AR, R)
  #   rdchans: (AR), (R)
  #   none:     
  AxiCheck(master_type).req_variant(None)
  AxiCheck(slave_type).req_variant(None)
  if master_mode not in ('full', 'wr_rd', 'aw_w_b_ar_r', 'wr', 'aw_w_b', 'rd', 'ar_r', 'none'):
    raise AssertionError('Invalid master_mode "{}"'.format(master_mode))
  if slave_mode not in ('full', 'wr_rd', 'aw_w_b_ar_r', 'wr', 'aw_w_b', 'rd', 'ar_r', 'none'):
    raise AssertionError('Invalid slave_mode "{}"'.format(slave_mode))

  ports = [PortI('sys', T('Sys'), label='psys')]
  if master_mode in ('full',):
    ports.append(PortM('master',   master_type,            labels=('pm', 'pmaw', 'pmw', 'pmb', 'pmar', 'pmr')))
  if master_mode in ('wr_rd', 'wr'):
    ports.append(PortM('masterWr', master_type.x_tpart_wr, labels=('pmwr', 'pmaw', 'pmw', 'pmb')))
  if master_mode in ('wr_rd', 'rd'):
    ports.append(PortM('masterRd', master_type.x_tpart_rd, labels=('pmrd', 'pmar', 'pmr')))
  if master_mode in ('aw_w_b_ar_r', 'aw_w_b'):
    ports.append(PortM('masterAW', master_type.x_tpart_aw,  label='pmaw'))
    ports.append(PortM('masterW',  master_type.x_tpart_w,  label='pmw'))
    ports.append(PortM('masterB',  master_type.x_tpart_b,  label='pmb'))
  if master_mode in ('aw_w_b_ar_r', 'ar_r'):
    ports.append(PortM('masterAR', master_type.x_tpart_ar,  label='pmar'))
    ports.append(PortM('masterR',  master_type.x_tpart_r,  label='pmr'))

  if slave_mode in ('full',):
    ports.append(PortS('slave',   slave_type,            labels=('ps', 'psaw', 'psw', 'psb', 'psar', 'psr')))
  if slave_mode in ('wr_rd', 'wr'):
    ports.append(PortS('slaveWr', slave_type.x_tpart_wr, labels=('pswr', 'psaw', 'psw', 'psb')))
  if slave_mode in ('wr_rd', 'rd'):
    ports.append(PortS('slaveRd', slave_type.x_tpart_rd, labels=('psrd', 'psar', 'psr')))
  if slave_mode in ('aw_w_b_ar_r', 'aw_w_b'):
    ports.append(PortS('slaveAW', slave_type.x_tpart_aw,  label='psaw'))
    ports.append(PortS('slaveW',  slave_type.x_tpart_w,  label='psw'))
    ports.append(PortS('slaveB',  slave_type.x_tpart_b,  label='psb'))
  if slave_mode in ('aw_w_b_ar_r', 'ar_r'):
    ports.append(PortS('slaveAR', slave_type.x_tpart_ar,  label='psar'))
    ports.append(PortS('slaveR',  slave_type.x_tpart_r,  label='psr'))

  return Ent(name, *ports,
      x_util=Util.package,
      x_templates={ctx.File('entity/axi/Wiring.vhd.tpl'): x_file},
      **directives)
EntAxiWiring = ModuleContext(_EntAxiWiring)


def _EntRegDemux(ctx, name, axi_type, reg_type, x_file):
  axi_info = AxiCheck(axi_type).req_id(False).req_burst(False).req_any_attr(False).req_any_user(False)
  RegPortCheck(reg_type).req_data(axi_info.data_bits)

  return Ent(name,
      Generic('PortCount', T('Size'), label='gcount'),
      Generic('Ports', T('RegMap'), vector='PortCount', label='gports'),
      PortI('sys', T('Sys'), label='psys'),
      PortS('axi', axi_type, label='paxi'),
      PortM('ports', reg_type, vector='PortCount', label='pports'),
      x_util=Util.package,
      x_templates={ctx.File('entity/reg/Demux.vhd.tpl'): x_file})
EntRegDemux = ModuleContext(_EntRegDemux)


def _EntAxiWrMux(ctx, name, axi_type, x_file_split, x_file_join, x_file):
  AxiCheck(axi_type).req_variant(None).req_id(False).req_any_attr(False).req_any_user(False)
  # TODO-lw handle presence of ID signals, switch different template?

  ejoin = EntAxiWiring('{}Joiner'.format(name),
      master_type=axi_type, slave_type=axi_type,
      master_mode='wr', slave_mode='aw_w_b',
      x_file=x_file_join)

  esplit = EntAxiWiring('{}Splitter'.format(name),
      master_type=axi_type, slave_type=axi_type,
      master_mode='aw_w_b', slave_mode='wr',
      x_file=x_file_split)

  return Ent(name,
    Generic('PortCount', T('Size'), label='gcount'),
    PortI('sys', T('Sys'), label='psys'),
    PortM('master', axi_type.x_tpart_wr, label='pm'),
    PortS('slaves', axi_type.x_tpart_wr, vector='PortCount', label='psv'),
    x_esplit=esplit, x_ejoin=ejoin,
    x_earbiter=Util.ArbiterStable,
    x_ebarrier=Util.Barrier,
    x_efifo=Util.FifoFast,
    x_util=Util.package,
    x_templates={ctx.File('entity/axi/WrMux.vhd.tpl'): x_file})
EntAxiWrMux = ModuleContext(_EntAxiWrMux)


def _EntAxiRdMux(ctx, name, axi_type, x_file_split, x_file_join, x_file):
  AxiCheck(axi_type).req_variant(None).req_id(False).req_any_attr(False).req_any_user(False)
  # TODO-lw handle presence of ID signals, switch different template?

  ejoin = EntAxiWiring('{}Joiner'.format(name),
      master_type=axi_type, slave_type=axi_type,
      master_mode='rd', slave_mode='ar_r',
      x_file=x_file_join)

  esplit = EntAxiWiring('{}Splitter'.format(name),
      master_type=axi_type, slave_type=axi_type,
      master_mode='ar_r', slave_mode='rd',
      x_file=x_file_split)

  return Ent(name,
    Generic('PortCount', T('Size'), label='gcount'),
    PortI('sys', T('Sys'), label='psys'),
    PortM('master', axi_type.x_tpart_rd, label='pm'),
    PortS('slaves', axi_type.x_tpart_rd, vector='PortCount', label='psv'),
    x_esplit=esplit, x_ejoin=ejoin,
    x_earbiter=Util.ArbiterStable,
    x_ebarrier=Util.Barrier,
    x_efifo=Util.FifoFast,
    x_util=Util.package,
    x_templates={ctx.File('entity/axi/RdMux.vhd.tpl'): x_file})
EntAxiRdMux = ModuleContext(_EntAxiRdMux)


def _EntAxiAddrMachine(ctx, name, axi_type, reg_type, x_file):
  tlogic = T('Logic')
  return Ent(name,
    PortI('sys',        T('Sys'),          label='psys'),
    PortI('start',      tlogic,            label='pstart'),
    PortO('ready',      tlogic,            label='pready'),
    PortI('hold',       tlogic,            label='phold'),
    PortI('abort',      tlogic,            label='pabort'),
    PortI('address',    axi_type.x_twaddr, label='paddr'),
    PortI('count',      reg_type.x_tdata,  label='pcount'),
    PortI('len',        axi_type.x_tlen,   label='plen'),
    PortO('axiAddr',    axi_type.x_taddr,  label='paaddr'),
    PortO('axiLen',     axi_type.x_tlen,   label='palen'),
    PortO('axiValid',   tlogic,            label='pavalid'),
    PortI('axiReady',   tlogic,            label='paready'),
    PortO('queueLen',   axi_type.x_tlen,   label='pqlen'),
    PortO('queueLast',  tlogic,            label='pqlast'),
    PortO('queueValid', tlogic,            label='pqvalid'),
    PortI('queueReady', tlogic,            label='pqready'),
    x_templates={ctx.File('entity/axi/AddrMachine.vhd.tpl'): x_file})

def _EntAxiWriter(ctx, name, axi_type, stm_type, reg_type, x_file_amach, x_file):
  axi_info = AxiCheck(axi_type).req_variant(None).req_burst(True).req_any_attr(False).req_any_user(False)
  AxiStreamCheck(stm_type).req_data(axi_info.data_bits).req_id(False).req_dest(False).req_user(False)
  RegPortCheck(reg_type)

  eamach = _EntAxiAddrMachine(ctx, '{}AddrMachine'.format(name), axi_type, reg_type, x_file_amach)
  return Ent(name,
    PortI('sys', T('Sys'), label='psys'),
    PortS('reg', reg_type, label='preg'),
    PortM('axiWr', axi_type.x_tpart_wr, label='paxi'),
    PortS('stm', stm_type, label='pstm'),
    x_eamach=eamach,
    x_templates={ctx.File('entity/axi/Writer.vhd.tpl'): x_file})
EntAxiWriter = ModuleContext(_EntAxiWriter)

def _EntAxiReader(ctx, name, axi_type, stm_type, reg_type, x_file_amach, x_file):
  axi_info = AxiCheck(axi_type).req_variant(None).req_burst(True).req_any_attr(False).req_any_user(False)
  AxiStreamCheck(stm_type).req_data(axi_info.data_bits).req_id(False).req_dest(False).req_user(False)
  RegPortCheck(reg_type)

  eamach = _EntAxiAddrMachine(ctx, '{}AddrMachine'.format(name), axi_type, reg_type, x_file_amach)
  return Ent(name,
    PortI('sys', T('Sys'), label='psys'),
    PortS('reg', reg_type, label='preg'),
    PortM('axiRd', axi_type.x_tpart_wr, label='paxi'),
    PortM('stm', stm_type, label='pstm'),
    x_eamach=eamach,
    x_templates={ctx.File('entity/axi/Reader.vhd.tpl'): x_file})
EntAxiReader = ModuleContext(_EntAxiReader)

