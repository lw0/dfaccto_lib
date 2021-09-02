{{?.is_ms_input}}
{{? .type.x_has_aw}}
{{.x_wrapname}}_awaddr => std_logic_vector({{.identifier_ms}}.awaddr),
{{?  .type.x_tlen}}
{{.x_wrapname}}_awlen => std_logic_vector({{.identifier_ms}}.awlen),
{{/  .type.x_tlen}}
{{?  .type.x_tsize}}
{{.x_wrapname}}_awsize => std_logic_vector({{.identifier_ms}}.awsize),
{{/  .type.x_tsize}}
{{?  .type.x_tburst}}
{{.x_wrapname}}_awburst => std_logic_vector({{.identifier_ms}}.awburst),
{{/  .type.x_tburst}}
{{?  .type.x_tlock}}
{{.x_wrapname}}_awlock => std_logic_vector({{.identifier_ms}}.awlock),
{{/  .type.x_tlock}}
{{?  .type.x_tcache}}
{{.x_wrapname}}_awcache => std_logic_vector({{.identifier_ms}}.awcache),
{{/  .type.x_tcache}}
{{?  .type.x_tprot}}
{{.x_wrapname}}_awprot => std_logic_vector({{.identifier_ms}}.awprot),
{{/  .type.x_tprot}}
{{?  .type.x_tqos}}
{{.x_wrapname}}_awqos => std_logic_vector({{.identifier_ms}}.awqos),
{{/  .type.x_tqos}}
{{?  .type.x_tregion}}
{{.x_wrapname}}_awregion => std_logic_vector({{.identifier_ms}}.awregion),
{{/  .type.x_tregion}}
{{?  .type.x_tid}}
{{.x_wrapname}}_awid => std_logic_vector({{.identifier_ms}}.awid),
{{/  .type.x_tid}}
{{?  .type.x_tawuser}}
{{.x_wrapname}}_awuser => std_logic_vector({{.identifier_ms}}.awuser),
{{/  .type.x_tawuser}}
{{.x_wrapname}}_awvalid => {{.identifier_ms}}.awvalid,
{{/ .type.x_has_aw}}
{{? .type.x_has_w}}
{{.x_wrapname}}_wdata => std_logic_vector({{.identifier_ms}}.wdata),
{{.x_wrapname}}_wstrb => std_logic_vector({{.identifier_ms}}.wstrb),
{{?  .type.x_tlast}}
{{.x_wrapname}}_wlast => {{.identifier_ms}}.wlast,
{{/  .type.x_tlast}}
{{?  .type.x_twid}}
{{.x_wrapname}}_wid => std_logic_vector({{.identifier_ms}}.wid),
{{/  .type.x_twid}}
{{?  .type.x_twuser}}
{{.x_wrapname}}_wuser => std_logic_vector({{.identifier_ms}}.wuser),
{{/  .type.x_twuser}}
{{.x_wrapname}}_wvalid => {{.identifier_ms}}.wvalid,
{{/ .type.x_has_w}}
{{? .type.x_has_b}}
{{.x_wrapname}}_bready => {{.identifier_ms}}.bready,
{{/ .type.x_has_b}}
{{? .type.x_has_ar}}
{{.x_wrapname}}_araddr => std_logic_vector({{.identifier_ms}}.araddr),
{{?  .type.x_tlen}}
{{.x_wrapname}}_arlen => std_logic_vector({{.identifier_ms}}.arlen),
{{/  .type.x_tlen}}
{{?  .type.x_tsize}}
{{.x_wrapname}}_arsize => std_logic_vector({{.identifier_ms}}.arsize),
{{/  .type.x_tsize}}
{{?  .type.x_tburst}}
{{.x_wrapname}}_arburst => std_logic_vector({{.identifier_ms}}.arburst),
{{/  .type.x_tburst}}
{{?  .type.x_tlock}}
{{.x_wrapname}}_arlock => std_logic_vector({{.identifier_ms}}.arlock),
{{/  .type.x_tlock}}
{{?  .type.x_tcache}}
{{.x_wrapname}}_arcache => std_logic_vector({{.identifier_ms}}.arcache),
{{/  .type.x_tcache}}
{{?  .type.x_tprot}}
{{.x_wrapname}}_arprot => std_logic_vector({{.identifier_ms}}.arprot),
{{/  .type.x_tprot}}
{{?  .type.x_tqos}}
{{.x_wrapname}}_arqos => std_logic_vector({{.identifier_ms}}.arqos),
{{/  .type.x_tqos}}
{{?  .type.x_tregion}}
{{.x_wrapname}}_arregion => std_logic_vector({{.identifier_ms}}.arregion),
{{/  .type.x_tregion}}
{{?  .type.x_tid}}
{{.x_wrapname}}_arid => std_logic_vector({{.identifier_ms}}.arid),
{{/  .type.x_tid}}
{{?  .type.x_taruser}}
{{.x_wrapname}}_aruser => std_logic_vector({{.identifier_ms}}.aruser),
{{/  .type.x_taruser}}
{{.x_wrapname}}_arvalid => {{.identifier_ms}}.arvalid,
{{/ .type.x_has_ar}}
{{? .type.x_has_r}}
{{.x_wrapname}}_rready => {{.identifier_ms}}.rready,
{{/ .type.x_has_r}}
{{|.is_ms_input}}
{{? .type.x_has_aw}}
{{.type.x_taddr.qualified}}({{.x_wrapname}}_awaddr) => {{.identifier_ms}}.awaddr,
{{?  .type.x_tlen}}
{{.type.x_tlen.qualified}}({{.x_wrapname}}_awlen) => {{.identifier_ms}}.awlen,
{{/  .type.x_tlen}}
{{?  .type.x_tsize}}
{{.type.x_tsize.qualified}}({{.x_wrapname}}_awsize) => {{.identifier_ms}}.awsize,
{{/  .type.x_tsize}}
{{?  .type.x_tburst}}
{{.type.x_tburst.qualified}}({{.x_wrapname}}_awburst) => {{.identifier_ms}}.awburst,
{{/  .type.x_tburst}}
{{?  .type.x_tlock}}
{{.type.x_tlock.qualified}}({{.x_wrapname}}_awlock) => {{.identifier_ms}}.awlock,
{{/  .type.x_tlock}}
{{?  .type.x_tcache}}
{{.type.x_tcache.qualified}}({{.x_wrapname}}_awcache) => {{.identifier_ms}}.awcache,
{{/  .type.x_tcache}}
{{?  .type.x_tprot}}
{{.type.x_tprot.qualified}}({{.x_wrapname}}_awprot) => {{.identifier_ms}}.awprot,
{{/  .type.x_tprot}}
{{?  .type.x_tqos}}
{{.type.x_tqos.qualified}}({{.x_wrapname}}_awqos) => {{.identifier_ms}}.awqos,
{{/  .type.x_tqos}}
{{?  .type.x_tregion}}
{{.type.x_tregion.qualified}}({{.x_wrapname}}_awregion) => {{.identifier_ms}}.awregion,
{{/  .type.x_tregion}}
{{?  .type.x_tid}}
{{.type.x_tid.qualified}}({{.x_wrapname}}_awid) => {{.identifier_ms}}.awid,
{{/  .type.x_tid}}
{{?  .type.x_tawuser}}
{{.type.x_tawuser.qualified}}({{.x_wrapname}}_awuser) => {{.identifier_ms}}.awuser,
{{/  .type.x_tawuser}}
{{.x_wrapname}}_awvalid => {{.identifier_ms}}.awvalid,
{{/ .type.x_has_aw}}
{{? .type.x_has_w}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}_wdata) => {{.identifier_ms}}.wdata,
{{.type.x_tstrb.qualified}}({{.x_wrapname}}_wstrb) => {{.identifier_ms}}.wstrb,
{{?  .type.x_tlast}}
{{.x_wrapname}}_wlast => {{.identifier_ms}}.wlast,
{{/  .type.x_tlast}}
{{?  .type.x_twid}}
{{.type.x_twid.qualified}}({{.x_wrapname}}_wid) => {{.identifier_ms}}.wid,
{{/  .type.x_twid}}
{{?  .type.x_twuser}}
{{.type.x_twuser.qualified}}({{.x_wrapname}}_wuser) => {{.identifier_ms}}.wuser,
{{/  .type.x_twuser}}
{{.x_wrapname}}_wvalid => {{.identifier_ms}}.wvalid,
{{/ .type.x_has_w}}
{{? .type.x_has_b}}
{{.x_wrapname}}_bready => {{.identifier_ms}}.bready{{?.type.x_has_rd}},{{/.type.x_has_rd}}
{{/ .type.x_has_b}}
{{? .type.x_has_ar}}
{{.type.x_taddr.qualified}}({{.x_wrapname}}_araddr) => {{.identifier_ms}}.araddr,
{{?  .type.x_tlen}}
{{.type.x_tlen.qualified}}({{.x_wrapname}}_arlen) => {{.identifier_ms}}.arlen,
{{/  .type.x_tlen}}
{{?  .type.x_tsize}}
{{.type.x_tsize.qualified}}({{.x_wrapname}}_arsize) => {{.identifier_ms}}.arsize,
{{/  .type.x_tsize}}
{{?  .type.x_tburst}}
{{.type.x_tburst.qualified}}({{.x_wrapname}}_arburst) => {{.identifier_ms}}.arburst,
{{/  .type.x_tburst}}
{{?  .type.x_tlock}}
{{.type.x_tlock.qualified}}({{.x_wrapname}}_arlock) => {{.identifier_ms}}.arlock,
{{/  .type.x_tlock}}
{{?  .type.x_tcache}}
{{.type.x_tcache.qualified}}({{.x_wrapname}}_arcache) => {{.identifier_ms}}.arcache,
{{/  .type.x_tcache}}
{{?  .type.x_tprot}}
{{.type.x_tprot.qualified}}({{.x_wrapname}}_arprot) => {{.identifier_ms}}.arprot,
{{/  .type.x_tprot}}
{{?  .type.x_tqos}}
{{.type.x_tqos.qualified}}({{.x_wrapname}}_arqos) => {{.identifier_ms}}.arqos,
{{/  .type.x_tqos}}
{{?  .type.x_tregion}}
{{.type.x_tregion.qualified}}({{.x_wrapname}}_arregion) => {{.identifier_ms}}.arregion,
{{/  .type.x_tregion}}
{{?  .type.x_tid}}
{{.type.x_tid.qualified}}({{.x_wrapname}}_arid) => {{.identifier_ms}}.arid,
{{/  .type.x_tid}}
{{?  .type.x_taruser}}
{{.type.x_taruser.qualified}}({{.x_wrapname}}_aruser) => {{.identifier_ms}}.aruser,
{{/  .type.x_taruser}}
{{.x_wrapname}}_arvalid => {{.identifier_ms}}.arvalid,
{{/ .type.x_has_ar}}
{{? .type.x_has_r}}
{{.x_wrapname}}_rready => {{.identifier_ms}}.rready,
{{/ .type.x_has_r}}
{{/.is_ms_input}}
{{?.is_sm_input}}
{{? .type.x_has_aw}}
  {{.x_wrapname}}_awready => {{.identifier_sm}}.awready{{^.type.x_lst_aw}},{{^.type.x_lst_aw}}
{{/ .type.x_has_aw}}
{{? .type.x_has_w}}
{{.x_wrapname}}_wready => {{.identifier_sm}}.wready{{^.type.x_lst_w}},{{^.type.x_lst_w}}
{{/ .type.x_has_w}}
{{? .type.x_has_b}}
{{.x_wrapname}}_bresp => std_logic_vector({{.identifier_sm}}.bresp),
{{?  .type.x_tid}}
{{.x_wrapname}}_bid => std_logic_vector({{.identifier_sm}}.bid),
{{/  .type.x_tid}}
{{?  .type.x_tbuser}}
{{.x_wrapname}}_buser => std_logic_vector({{.identifier_sm}}.buser),
{{/  .type.x_tbuser}}
{{.x_wrapname}}_bvalid => {{.identifier_sm}}.bvalid{{^.type.x_lst_b}},{{^.type.x_lst_b}}
{{/ .type.x_has_b}}
{{? .type.x_has_ar}}
{{.x_wrapname}}_arready => {{.identifier_sm}}.arready{{^.type.x_lst_ar}},{{^.type.x_lst_ar}}
{{/ .type.x_has_ar}}
{{? .type.x_has_r}}
{{.x_wrapname}}_rdata => std_logic_vector({{.identifier_sm}}.rdata),
{{.x_wrapname}}_rresp => std_logic_vector({{.identifier_sm}}.rresp),
{{?  .type.x_tlast}}
{{.x_wrapname}}_rlast => {{.identifier_sm}}.rlast,
{{/  .type.x_tlast}}
{{?  .type.x_tid}}
{{.x_wrapname}}_rid => std_logic_vector({{.identifier_sm}}.rid),
{{/  .type.x_tid}}
{{?  .type.x_truser}}
{{.x_wrapname}}_ruser => std_logic_vector({{.identifier_sm}}.ruser),
{{/  .type.x_truser}}
{{.x_wrapname}}_rvalid => {{.identifier_sm}}.rvalid
{{/ .type.x_has_r}}
{{|.is_sm_input}}
{{? .type.x_has_aw}}
{{.x_wrapname}}_awready => {{.identifier_sm}}.awready{{^.type.x_lst_aw}},{{^.type.x_lst_aw}}
{{/ .type.x_has_aw}}
{{? .type.x_has_w}}
{{.x_wrapname}}_wready => {{.identifier_sm}}.wready{{^.type.x_lst_w}},{{^.type.x_lst_w}}
{{/ .type.x_has_w}}
{{? .type.x_has_b}}
{{.type.x_tresp.qualified}}({{.x_wrapname}}_bresp) => {{.identifier_sm}}.bresp,
{{?  .type.x_tid}}
{{.type.x_tid.qualified}}({{.x_wrapname}}_bid) => {{.identifier_sm}}.bid,
{{/  .type.x_tid}}
{{?  .type.x_tbuser}}
{{.type.x_tbuser.qualified}}({{.x_wrapname}}_buser) => {{.identifier_sm}}.buser,
{{/  .type.x_tbuser}}
{{.x_wrapname}}_bvalid => {{.identifier_sm}}.bvalid{{^.type.x_lst_b}},{{^.type.x_lst_b}}
{{/ .type.x_has_b}}
{{? .type.x_has_ar}}
{{.x_wrapname}}_arready => {{.identifier_sm}}.arready{{^.type.x_lst_ar}},{{^.type.x_lst_ar}}
{{/ .type.x_has_ar}}
{{? .type.x_has_r}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}_rdata) => {{.identifier_sm}}.rdata,
{{.type.x_tresp.qualified}}({{.x_wrapname}}_rresp) => {{.identifier_sm}}.rresp,
{{?  .type.x_tlast}}
{{.x_wrapname}}_rlast => {{.identifier_sm}}.rlast,
{{/  .type.x_tlast}}
{{?  .type.x_tid}}
{{.type.x_tid.qualified}}({{.x_wrapname}}_rid) => {{.identifier_sm}}.rid,
{{/  .type.x_tid}}
{{?  .type.x_truser}}
{{.type.x_truser.qualified}}({{.x_wrapname}}_ruser) => {{.identifier_sm}}.ruser,
{{/  .type.x_truser}}
{{.x_wrapname}}_rvalid => {{.identifier_sm}}.rvalid
{{/ .type.x_has_r}}
{{/.is_sm_input}}
