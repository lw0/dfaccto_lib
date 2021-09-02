type {{.identifier_ms}} is record
{{?.x_has_aw}}
  awaddr   : {{.x_taddr.qualified}};
{{? .x_tlen}}
  awlen    : {{.x_tlen.qualified}};
{{/ .x_tlen}}
{{? .x_tsize}}
  awsize   : {{.x_tsize.qualified}};
{{/ .x_tsize}}
{{? .x_tburst}}
  awburst  : {{.x_tburst.qualified}};
{{/ .x_tburst}}
{{? .x_tlock}}
  awlock   : {{.x_tlock.qualified}};
{{/ .x_tlock}}
{{? .x_tcache}}
  awcache  : {{.x_tcache.qualified}};
{{/ .x_tcache}}
{{? .x_tprot}}
  awprot   : {{.x_tprot.qualified}};
{{/ .x_tprot}}
{{? .x_tqos}}
  awqos    : {{.x_tqos.qualified}};
{{/ .x_tqos}}
{{? .x_tregion}}
  awregion : {{.x_tregion.qualified}};
{{/ .x_tregion}}
{{? .x_tid}}
  awid     : {{.x_tid.qualified}};
{{/ .x_tid}}
{{? .x_tawuser}}
  awuser   : {{.x_tawuser.qualified}};
{{/ .x_tawuser}}
  awvalid  : {{.x_tlogic.qualified}};
{{/.x_has_aw}}
{{?.x_has_w}}
  wdata    : {{.x_tdata.qualified}};
  wstrb    : {{.x_tstrb.qualified}};
{{? .x_tlast}}
  wlast    : {{.x_tlast.qualified}};
{{/ .x_tlast}}
{{? .x_twid}}
  wid      : {{.x_twid.qualified}};
{{/ .x_twid}}
{{? .x_twuser}}
  wuser    : {{.x_twuser.qualified}};
{{/ .x_twuser}}
  wvalid   : {{.x_tlogic.qualified}};
{{/.x_has_w}}
{{?.x_has_b}}
  bready   : {{.x_tlogic.qualified}};
{{/.x_has_b}}
{{?.x_has_ar}}
  araddr   : {{.x_taddr.qualified}};
{{? .x_tlen}}
  arlen    : {{.x_tlen.qualified}};
{{/ .x_tlen}}
{{? .x_tsize}}
  arsize   : {{.x_tsize.qualified}};
{{/ .x_tsize}}
{{? .x_tburst}}
  arburst  : {{.x_tburst.qualified}};
{{/ .x_tburst}}
{{? .x_tlock}}
  arlock   : {{.x_tlock.qualified}};
{{/ .x_tlock}}
{{? .x_tcache}}
  arcache  : {{.x_tcache.qualified}};
{{/ .x_tcache}}
{{? .x_tprot}}
  arprot   : {{.x_tprot.qualified}};
{{/ .x_tprot}}
{{? .x_tqos}}
  arqos    : {{.x_tqos.qualified}};
{{/ .x_tqos}}
{{? .x_tregion}}
  arregion : {{.x_tregion.qualified}};
{{/ .x_tregion}}
{{? .x_tid}}
  arid     : {{.x_tid.qualified}};
{{/ .x_tid}}
{{? .x_taruser}}
  aruser   : {{.x_taruser.qualified}};
{{/ .x_taruser}}
  arvalid  : {{.x_tlogic.qualified}};
{{/.x_has_ar}}
{{?.x_has_r}}
  rready   : {{.x_tlogic.qualified}};
{{/.x_has_r}}
end record;
type {{.identifier_sm}} is record
{{?.x_has_aw}}
  awready  : {{.x_tlogic.qualified}};
{{/.x_has_aw}}
{{?.x_has_w}}
  wready   : {{.x_tlogic.qualified}};
{{/.x_has_w}}
{{?.x_has_b}}
  bresp    : {{.x_tresp.qualified}};
{{? .x_tid}}
  bid      : {{.x_tid.qualified}};
{{/ .x_tid}}
{{? .x_tbuser}}
  buser   : {{.x_tbuser.qualified}};
{{/ .x_tbuser}}
  bvalid   : {{.x_tlogic.qualified}};
{{/.x_has_b}}
{{?.x_has_ar}}
  arready  : {{.x_tlogic.qualified}};
{{/.x_has_ar}}
{{?.x_has_r}}
  rdata    : {{.x_tdata.qualified}};
  rresp    : {{.x_tresp.qualified}};
{{? .x_tlast}}
  rlast    : {{.x_tlast.qualified}};
{{/ .x_tlast}}
{{? .x_tid}}
  rid      : {{.x_tid.qualified}};
{{/ .x_tid}}
{{? .x_truser}}
  ruser   : {{.x_truser.qualified}};
{{/ .x_truser}}
  rvalid   : {{.x_tlogic.qualified}};
{{/.x_has_r}}
end record;
type {{.identifier_v_ms}} is array (integer range <>) of {{.qualified_ms}};
type {{.identifier_v_sm}} is array (integer range <>) of {{.qualified_sm}};
