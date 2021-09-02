{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture AxiWiring of {{identifier}} is

begin

{{; ------- AW -------}}
{{?x_pmaw.type.x_has_aw}}
{{; ----- awaddr -----}}
{{?  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awaddr   <= f_resize({{x_psaw.identifier_ms}}.awaddr, {{x_pmaw.type.x_taddr.x_width}});
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awaddr   <= {{=x_cawaddr}}{{>vhdl/putvalue.part.tpl}}{{|x_cawaddr}}{{x_pmaw.type.x_taddr.x_cnull.qualified}}{{/x_cawaddr}};
{{/  x_psaw.type.x_has_aw}}
{{; ----- awlen -----}}
{{? x_pmaw.type.x_tlen}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tlen}}
  {{x_pmaw.identifier_ms}}.awlen    <= {{x_psaw.identifier_ms}}.awlen;
{{|   x_psaw.type.x_tlen}}
  {{x_pmaw.identifier_ms}}.awlen    <= {{=x_cawlen}}{{>vhdl/putvalue.part.tpl}}{{|x_cawlen}}{{x_pmaw.type.x_tlen.x_cnull.qualified}}{{/x_cawlen}};
{{/   x_psaw.type.x_tlen}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awlen    <= {{=x_cawlen}}{{>vhdl/putvalue.part.tpl}}{{|x_cawlen}}{{x_pmaw.type.x_tlen.x_cnull.qualified}}{{/x_cawlen}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tlen}}
{{; ----- awsize -----}}
{{? x_pmaw.type.x_tsize}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tsize}}
  {{x_pmaw.identifier_ms}}.awsize   <= {{x_psaw.identifier_ms}}.awsize;
{{|   x_psaw.type.x_tsize}}
  {{x_pmaw.identifier_ms}}.awsize   <= {{=x_cawsize}}{{>vhdl/putvalue.part.tpl}}{{|x_cawsize}}{{x_pmaw.type.x_tsize.x_cnull.qualified}}{{/x_cawsize}};
{{/   x_psaw.type.x_tsize}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awsize   <= {{=x_cawsize}}{{>vhdl/putvalue.part.tpl}}{{|x_cawsize}}{{x_pmaw.type.x_tsize.x_cnull.qualified}}{{/x_cawsize}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tsize}}
{{; ----- awburst -----}}
{{? x_pmaw.type.x_tburst}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tburst}}
  {{x_pmaw.identifier_ms}}.awburst  <= {{x_psaw.identifier_ms}}.awburst;
{{|   x_psaw.type.x_tburst}}
  {{x_pmaw.identifier_ms}}.awburst  <= {{=x_cawburst}}{{>vhdl/putvalue.part.tpl}}{{|x_cawburst}}{{x_pmaw.type.x_tburst.x_cnull.qualified}}{{/x_cawburst}};
{{/   x_psaw.type.x_tburst}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awburst  <= {{=x_cawburst}}{{>vhdl/putvalue.part.tpl}}{{|x_cawburst}}{{x_pmaw.type.x_tburst.x_cnull.qualified}}{{/x_cawburst}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tburst}}
{{; ----- awlock -----}}
{{? x_pmaw.type.x_tlock}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tlock}}
  {{x_pmaw.identifier_ms}}.awlock   <= {{x_psaw.identifier_ms}}.awlock;
{{|   x_psaw.type.x_tlock}}
  {{x_pmaw.identifier_ms}}.awlock   <= {{=x_cawlock}}{{>vhdl/putvalue.part.tpl}}{{|x_cawlock}}{{x_pmaw.type.x_tlock.x_cnull.qualified}}{{/x_cawlock}};
{{/   x_psaw.type.x_tlock}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awlock   <= {{=x_cawlock}}{{>vhdl/putvalue.part.tpl}}{{|x_cawlock}}{{x_pmaw.type.x_tlock.x_cnull.qualified}}{{/x_cawlock}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tlock}}
{{; ----- awcache -----}}
{{? x_pmaw.type.x_tcache}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tcache}}
  {{x_pmaw.identifier_ms}}.awcache  <= {{x_psaw.identifier_ms}}.awcache;
{{|   x_psaw.type.x_tcache}}
  {{x_pmaw.identifier_ms}}.awcache  <= {{=x_cawcache}}{{>vhdl/putvalue.part.tpl}}{{|x_cawcache}}{{x_pmaw.type.x_tcache.x_cnull.qualified}}{{/x_cawcache}};
{{/   x_psaw.type.x_tcache}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awcache  <= {{=x_cawcache}}{{>vhdl/putvalue.part.tpl}}{{|x_cawcache}}{{x_pmaw.type.x_tcache.x_cnull.qualified}}{{/x_cawcache}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tcache}}
{{; ----- awprot -----}}
{{? x_pmaw.type.x_tprot}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tprot}}
  {{x_pmaw.identifier_ms}}.awprot   <= {{x_psaw.identifier_ms}}.awprot;
{{|   x_psaw.type.x_tprot}}
  {{x_pmaw.identifier_ms}}.awprot   <= {{=x_cawprot}}{{>vhdl/putvalue.part.tpl}}{{|x_cawprot}}{{x_pmaw.type.x_tprot.x_cnull.qualified}}{{/x_cawprot}};
{{/   x_psaw.type.x_tprot}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awprot   <= {{=x_cawprot}}{{>vhdl/putvalue.part.tpl}}{{|x_cawprot}}{{x_pmaw.type.x_tprot.x_cnull.qualified}}{{/x_cawprot}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tprot}}
{{; ----- awqos -----}}
{{? x_pmaw.type.x_tqos}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tqos}}
  {{x_pmaw.identifier_ms}}.awqos    <= {{x_psaw.identifier_ms}}.awqos;
{{|   x_psaw.type.x_tqos}}
  {{x_pmaw.identifier_ms}}.awqos    <= {{=x_cawqos}}{{>vhdl/putvalue.part.tpl}}{{|x_cawqos}}{{x_pmaw.type.x_tqos.x_cnull.qualified}}{{/x_cawqos}};
{{/   x_psaw.type.x_tqos}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awqos    <= {{=x_cawqos}}{{>vhdl/putvalue.part.tpl}}{{|x_cawqos}}{{x_pmaw.type.x_tqos.x_cnull.qualified}}{{/x_cawqos}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tqos}}
{{; ----- awregion -----}}
{{? x_pmaw.type.x_tregion}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tregion}}
  {{x_pmaw.identifier_ms}}.awregion <= {{x_psaw.identifier_ms}}.awregion;
{{|   x_psaw.type.x_tregion}}
  {{x_pmaw.identifier_ms}}.awregion <= {{=x_cawregion}}{{>vhdl/putvalue.part.tpl}}{{|x_cawregion}}{{x_pmaw.type.x_tregion.x_cnull.qualified}}{{/x_cawregion}};
{{/   x_psaw.type.x_tregion}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awregion <= {{=x_cawregion}}{{>vhdl/putvalue.part.tpl}}{{|x_cawregion}}{{x_pmaw.type.x_tregion.x_cnull.qualified}}{{/x_cawregion}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tregion}}
{{; ----- awid -----}}
{{? x_pmaw.type.x_tid}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tid}}
  {{x_pmaw.identifier_ms}}.awid     <= f_resize({{x_psaw.identifier_ms}}.awid, {{x_pmaw.type.x_tid.x_width}});
{{|   x_psaw.type.x_tid}}
  {{x_pmaw.identifier_ms}}.awid     <= {{=x_cawid}}{{>vhdl/putvalue.part.tpl}}{{|x_cawid}}{{x_pmaw.type.x_tid.x_cnull.qualified}}{{/x_cawid}};
{{/   x_psaw.type.x_tid}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awid     <= {{=x_cawid}}{{>vhdl/putvalue.part.tpl}}{{|x_cawid}}{{x_pmaw.type.x_tid.x_cnull.qualified}}{{/x_cawid}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tid}}
{{; ----- awuser -----}}
{{? x_pmaw.type.x_tawuser}}
{{?  x_psaw.type.x_has_aw}}
{{?   x_psaw.type.x_tawuser}}
  {{x_pmaw.identifier_ms}}.awuser   <= f_resize({{x_psaw.identifier_ms}}.awuser, {{x_pmaw.type.x_tawuser.x_width}});
{{|   x_psaw.type.x_tawuser}}
  {{x_pmaw.identifier_ms}}.awuser   <= {{=x_cawuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cawuser}}{{x_pmaw.type.x_tawuser.x_cnull.qualified}}{{/x_cawuser}};
{{/   x_psaw.type.x_tawuser}}
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awuser   <= {{=x_cawuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cawuser}}{{x_pmaw.type.x_tawuser.x_cnull.qualified}}{{/x_cawuser}};
{{/  x_psaw.type.x_has_aw}}
{{/ x_pmaw.type.x_tawuser}}
{{; ----- awvalid -----}}
{{?  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awvalid  <= {{x_psaw.identifier_ms}}.awvalid;
{{|  x_psaw.type.x_has_aw}}
  {{x_pmaw.identifier_ms}}.awvalid  <= {{=x_cawvalid}}{{>vhdl/putvalue.part.tpl}}{{|x_cawvalid}}{{x_pmaw.type.x_tlogic.x_cnull.qualified}}{{/x_cawvalid}};
{{/  x_psaw.type.x_has_aw}}
{{/x_pmaw.type.x_has_aw}}
{{?x_psaw.type.x_has_aw}}
{{; ----- awready -----}}
{{?  x_pmaw.type.x_has_aw}}
  {{x_psaw.identifier_sm}}.awready  <= {{x_pmaw.identifier_sm}}.awready;
{{|  x_pmaw.type.x_has_aw}}
  {{x_psaw.identifier_sm}}.awready  <= {{=x_cawready}}{{>vhdl/putvalue.part.tpl}}{{|x_cawready}}{{x_psaw.type.x_tlogic.x_cnull.qualified}}{{/x_cawready}};
{{/  x_pmaw.type.x_has_aw}}
{{/x_psaw.type.x_has_aw}}

{{; ------- W -------}}
{{?x_pmw.type.x_has_w}}
{{; ----- wdata -----}}
{{?  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wdata     <= f_resize({{x_psw.identifier_ms}}.wdata, {{x_pmw.type.x_tdata.x_width}});
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wdata     <= {{=x_cwdata}}{{>vhdl/putvalue.part.tpl}}{{|x_cwdata}}{{x_pmw.type.x_tdata.x_cnull.qualified}}{{/x_cwdata}};
{{/  x_psw.type.x_has_w}}
{{; ----- wstrb -----}}
{{?  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wstrb     <= f_resize({{x_psw.identifier_ms}}.wstrb, {{x_pmw.type.x_tstrb.x_width}});
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wstrb     <= {{=x_cwstrb}}{{>vhdl/putvalue.part.tpl}}{{|x_cwstrb}}{{x_pmw.type.x_tstrb.x_cnull.qualified}}{{/x_cwstrb}};
{{/  x_psw.type.x_has_w}}
{{; ----- wlast -----}}
{{? x_pmw.type.x_tlast}}
{{?  x_psw.type.x_has_w}}
{{?   x_psw.type.x_tlast}}
  {{x_pmw.identifier_ms}}.wlast     <= {{x_psw.identifier_ms}}.wlast;
{{|   x_psw.type.x_tlast}}
  {{x_pmw.identifier_ms}}.wlast     <= {{=x_cwlast}}{{>vhdl/putvalue.part.tpl}}{{|x_cwlast}}{{x_pmw.type.x_tlast.x_cnull.qualified}}{{/x_cwlast}};
{{/   x_psw.type.x_tlast}}
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wlast     <= {{=x_cwlast}}{{>vhdl/putvalue.part.tpl}}{{|x_cwlast}}{{x_pmw.type.x_tlast.x_cnull.qualified}}{{/x_cwlast}};
{{/  x_psw.type.x_has_w}}
{{/ x_pmw.type.x_tlast}}
{{; ----- wid -----}}
{{? x_pmw.type.x_twid}}
{{?  x_psw.type.x_has_w}}
{{?   x_psw.type.x_tid}}
  {{x_pmw.identifier_ms}}.wid       <= f_resize({{x_psw.identifier_ms}}.wid, {{x_pmw.type.x_tid.x_width}});
{{|   x_psw.type.x_tid}}
  {{x_pmw.identifier_ms}}.wid       <= {{=x_cwid}}{{>vhdl/putvalue.part.tpl}}{{|x_cwid}}{{x_pmw.type.x_tid.x_cnull.qualified}}{{/x_cwid}};
{{/   x_psw.type.x_tid}}
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wid       <= {{=x_cwid}}{{>vhdl/putvalue.part.tpl}}{{|x_cwid}}{{x_pmw.type.x_tid.x_cnull.qualified}}{{/x_cwid}};
{{/  x_psw.type.x_has_w}}
{{/ x_pmw.type.x_twid}}
{{; ----- wuser -----}}
{{? x_pmw.type.x_twuser}}
{{?  x_psw.type.x_has_w}}
{{?   x_psw.type.x_twuser}}
  {{x_pmw.identifier_ms}}.wuser     <= f_resize({{x_psw.identifier_ms}}.wuser, {{x_pmw.type.x_twuser.x_width}});
{{|   x_psw.type.x_twuser}}
  {{x_pmw.identifier_ms}}.wuser     <= {{=x_cwuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cwuser}}{{x_pmw.type.x_twuser.x_cnull.qualified}}{{/x_cwuser}};
{{/   x_psw.type.x_twuser}}
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wuser     <= {{=x_cwuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cwuser}}{{x_pmw.type.x_twuser.x_cnull.qualified}}{{/x_cwuser}};
{{/  x_psw.type.x_has_w}}
{{/ x_pmw.type.x_twuser}}
{{; ----- wvalid -----}}
{{?  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wvalid    <= {{x_psw.identifier_ms}}.wvalid;
{{|  x_psw.type.x_has_w}}
  {{x_pmw.identifier_ms}}.wvalid    <= {{=x_cwvalid}}{{>vhdl/putvalue.part.tpl}}{{|x_cwvalid}}{{x_pmw.type.x_tlogic.x_cnull.qualified}}{{/x_cwvalid}};
{{/  x_psw.type.x_has_w}}
{{/x_pmw.type.x_has_w}}
{{?x_psw.type.x_has_w}}
{{; ----- wready -----}}
{{?  x_pmw.type.x_has_w}}
  {{x_psw.identifier_sm}}.wready    <= {{x_pmw.identifier_sm}}.wready;
{{|  x_pmw.type.x_has_w}}
  {{x_psw.identifier_sm}}.wready    <= {{=x_cwready}}{{>vhdl/putvalue.part.tpl}}{{|x_cwready}}{{x_psw.type.x_tlogic.x_cnull.qualified}}{{/x_cwready}};
{{/  x_pmw.type.x_has_w}}
{{/x_psw.type.x_has_w}}

{{; ------- B -------}}
{{?x_psb.type.x_has_b}}
{{; ----- bresp -----}}
{{?  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.bresp     <= {{x_pmb.identifier_sm}}.bresp;
{{|  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.bresp     <= {{=x_cbresp}}{{>vhdl/putvalue.part.tpl}}{{|x_cbresp}}{{x_psb.type.x_tresp.x_cnull.qualified}}{{/x_cbresp}};
{{/  x_pmb.type.x_has_b}}
{{; ----- bid -----}}
{{? x_psb.type.x_tid}}
{{?  x_pmb.type.x_has_b}}
{{?   x_pmb.type.x_tid}}
  {{x_psb.identifier_sm}}.bid       <= f_resize({{x_pmb.identifier_sm}}.bid, {{x_psb.type.x_tid.x_width}});
{{|   x_pmb.type.x_tid}}
  {{x_psb.identifier_sm}}.bid       <= {{=x_cbid}}{{>vhdl/putvalue.part.tpl}}{{|x_cbid}}{{x_psb.type.x_tid.x_cnull.qualified}}{{/x_cbid}};
{{/   x_pmb.type.x_tid}}
{{|  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.bid       <= {{=x_cbid}}{{>vhdl/putvalue.part.tpl}}{{|x_cbid}}{{x_psb.type.x_tid.x_cnull.qualified}}{{/x_cbid}};
{{/  x_pmb.type.x_has_b}}
{{/ x_psb.type.x_tid}}
{{; ----- buser -----}}
{{? x_psb.type.x_tbuser}}
{{?  x_pmb.type.x_has_b}}
{{?   x_pmb.type.x_tbuser}}
  {{x_psb.identifier_sm}}.buser     <= f_resize({{x_pmb.identifier_sm}}.buser, {{x_psb.type.x_tbuser.x_width}});
{{|   x_pmb.type.x_tbuser}}
  {{x_psb.identifier_sm}}.buser     <= {{=x_cbuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cbuser}}{{x_psb.type.x_tbuser.x_cnull.qualified}}{{/x_cbuser}};
{{/   x_pmb.type.x_tbuser}}
{{|  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.buser     <= {{=x_cbuser}}{{>vhdl/putvalue.part.tpl}}{{|x_cbuser}}{{x_psb.type.x_tbuser.x_cnull.qualified}}{{/x_cbuser}};
{{/  x_pmb.type.x_has_b}}
{{/ x_psb.type.x_tbuser}}
{{; ----- bvalid -----}}
{{?  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.bvalid    <= {{x_pmb.identifier_sm}}.buser;
{{|  x_pmb.type.x_has_b}}
  {{x_psb.identifier_sm}}.bvalid    <= {{=x_cbvalid}}{{>vhdl/putvalue.part.tpl}}{{|x_cbvalid}}{{x_psb.type.x_tlogic.x_cnull.qualified}}{{/x_cbvalid}};
{{/  x_pmb.type.x_has_b}}
{{/x_psb.type.x_has_b}}
{{?x_pmb.type.x_has_b}}
{{; ----- bready -----}}
{{?  x_psb.type.x_has_b}}
  {{x_pmb.identifier_ms}}.bready    <= {{x_psb.identifier_ms}}.bready;
{{|  x_psb.type.x_has_b}}
  {{x_pmb.identifier_ms}}.bready    <= {{=x_cbready}}{{>vhdl/putvalue.part.tpl}}{{|x_cbready}}{{x_pmb.type.x_tlogic.x_cnull.qualified}}{{/x_cbready}};
{{/  x_psb.type.x_has_b}}
{{/x_pmb.type.x_has_b}}

{{; ------- AR -------}}
{{?x_pmar.type.x_has_ar}}
{{; ----- araddr -----}}
{{?  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.araddr   <= f_resize({{x_psar.identifier_ms}}.araddr, {{x_pmar.type.x_taddr.x_width}});
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.araddr   <= {{=x_caraddr}}{{>vhdl/putvalue.part.tpl}}{{|x_caraddr}}{{x_pmar.type.x_taddr.x_cnull.qualified}}{{/x_caraddr}};
{{/  x_psar.type.x_has_ar}}
{{; ----- arlen -----}}
{{? x_pmar.type.x_tlen}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tlen}}
  {{x_pmar.identifier_ms}}.arlen    <= {{x_psar.identifier_ms}}.arlen;
{{|   x_psar.type.x_tlen}}
  {{x_pmar.identifier_ms}}.arlen    <= {{=x_carlen}}{{>vhdl/putvalue.part.tpl}}{{|x_carlen}}{{x_pmar.type.x_tlen.x_cnull.qualified}}{{/x_carlen}};
{{/   x_psar.type.x_tlen}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arlen    <= {{=x_carlen}}{{>vhdl/putvalue.part.tpl}}{{|x_carlen}}{{x_pmar.type.x_tlen.x_cnull.qualified}}{{/x_carlen}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tlen}}
{{; ----- arsize -----}}
{{? x_pmar.type.x_tsize}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tsize}}
  {{x_pmar.identifier_ms}}.arsize   <= {{x_psar.identifier_ms}}.arsize;
{{|   x_psar.type.x_tsize}}
  {{x_pmar.identifier_ms}}.arsize   <= {{=x_carsize}}{{>vhdl/putvalue.part.tpl}}{{|x_carsize}}{{x_pmar.type.x_tsize.x_cnull.qualified}}{{/x_carsize}};
{{/   x_psar.type.x_tsize}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arsize   <= {{=x_carsize}}{{>vhdl/putvalue.part.tpl}}{{|x_carsize}}{{x_pmar.type.x_tsize.x_cnull.qualified}}{{/x_carsize}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tsize}}
{{; ----- arburst -----}}
{{? x_pmar.type.x_tburst}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tburst}}
  {{x_pmar.identifier_ms}}.arburst  <= {{x_psar.identifier_ms}}.arburst;
{{|   x_psar.type.x_tburst}}
  {{x_pmar.identifier_ms}}.arburst  <= {{=x_carburst}}{{>vhdl/putvalue.part.tpl}}{{|x_carburst}}{{x_pmar.type.x_tburst.x_cnull.qualified}}{{/x_carburst}};
{{/   x_psar.type.x_tburst}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arburst  <= {{=x_carburst}}{{>vhdl/putvalue.part.tpl}}{{|x_carburst}}{{x_pmar.type.x_tburst.x_cnull.qualified}}{{/x_carburst}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tburst}}
{{; ----- arlock -----}}
{{? x_pmar.type.x_tlock}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tlock}}
  {{x_pmar.identifier_ms}}.arlock   <= {{x_psar.identifier_ms}}.arlock;
{{|   x_psar.type.x_tlock}}
  {{x_pmar.identifier_ms}}.arlock   <= {{=x_carlock}}{{>vhdl/putvalue.part.tpl}}{{|x_carlock}}{{x_pmar.type.x_tlock.x_cnull.qualified}}{{/x_carlock}};
{{/   x_psar.type.x_tlock}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arlock   <= {{=x_carlock}}{{>vhdl/putvalue.part.tpl}}{{|x_carlock}}{{x_pmar.type.x_tlock.x_cnull.qualified}}{{/x_carlock}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tlock}}
{{; ----- arcache -----}}
{{? x_pmar.type.x_tcache}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tcache}}
  {{x_pmar.identifier_ms}}.arcache  <= {{x_psar.identifier_ms}}.arcache;
{{|   x_psar.type.x_tcache}}
  {{x_pmar.identifier_ms}}.arcache  <= {{=x_carcache}}{{>vhdl/putvalue.part.tpl}}{{|x_carcache}}{{x_pmar.type.x_tcache.x_cnull.qualified}}{{/x_carcache}};
{{/   x_psar.type.x_tcache}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arcache  <= {{=x_carcache}}{{>vhdl/putvalue.part.tpl}}{{|x_carcache}}{{x_pmar.type.x_tcache.x_cnull.qualified}}{{/x_carcache}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tcache}}
{{; ----- arprot -----}}
{{? x_pmar.type.x_tprot}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tprot}}
  {{x_pmar.identifier_ms}}.arprot   <= {{x_psar.identifier_ms}}.arprot;
{{|   x_psar.type.x_tprot}}
  {{x_pmar.identifier_ms}}.arprot   <= {{=x_carprot}}{{>vhdl/putvalue.part.tpl}}{{|x_carprot}}{{x_pmar.type.x_tprot.x_cnull.qualified}}{{/x_carprot}};
{{/   x_psar.type.x_tprot}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arprot   <= {{=x_carprot}}{{>vhdl/putvalue.part.tpl}}{{|x_carprot}}{{x_pmar.type.x_tprot.x_cnull.qualified}}{{/x_carprot}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tprot}}
{{; ----- arqos -----}}
{{? x_pmar.type.x_tqos}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tqos}}
  {{x_pmar.identifier_ms}}.arqos    <= {{x_psar.identifier_ms}}.arqos;
{{|   x_psar.type.x_tqos}}
  {{x_pmar.identifier_ms}}.arqos    <= {{=x_carqos}}{{>vhdl/putvalue.part.tpl}}{{|x_carqos}}{{x_pmar.type.x_tqos.x_cnull.qualified}}{{/x_carqos}};
{{/   x_psar.type.x_tqos}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arqos    <= {{=x_carqos}}{{>vhdl/putvalue.part.tpl}}{{|x_carqos}}{{x_pmar.type.x_tqos.x_cnull.qualified}}{{/x_carqos}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tqos}}
{{; ----- arregion -----}}
{{? x_pmar.type.x_tregion}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tregion}}
  {{x_pmar.identifier_ms}}.arregion <= {{x_psar.identifier_ms}}.arregion;
{{|   x_psar.type.x_tregion}}
  {{x_pmar.identifier_ms}}.arregion <= {{=x_carregion}}{{>vhdl/putvalue.part.tpl}}{{|x_carregion}}{{x_pmar.type.x_tregion.x_cnull.qualified}}{{/x_carregion}};
{{/   x_psar.type.x_tregion}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arregion <= {{=x_carregion}}{{>vhdl/putvalue.part.tpl}}{{|x_carregion}}{{x_pmar.type.x_tregion.x_cnull.qualified}}{{/x_carregion}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tregion}}
{{; ----- arid -----}}
{{? x_pmar.type.x_tid}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_tid}}
  {{x_pmar.identifier_ms}}.arid     <= f_resize({{x_psar.identifier_ms}}.arid, {{x_pmar.type.x_tid.x_width}});
{{|   x_psar.type.x_tid}}
  {{x_pmar.identifier_ms}}.arid     <= {{=x_carid}}{{>vhdl/putvalue.part.tpl}}{{|x_carid}}{{x_pmar.type.x_tid.x_cnull.qualified}}{{/x_carid}};
{{/   x_psar.type.x_tid}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arid     <= {{=x_carid}}{{>vhdl/putvalue.part.tpl}}{{|x_carid}}{{x_pmar.type.x_tid.x_cnull.qualified}}{{/x_carid}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_tid}}
{{; ----- aruser -----}}
{{? x_pmar.type.x_taruser}}
{{?  x_psar.type.x_has_ar}}
{{?   x_psar.type.x_taruser}}
  {{x_pmar.identifier_ms}}.aruser   <= f_resize({{x_psar.identifier_ms}}.aruser, {{x_pmar.type.x_taruser.x_width}});
{{|   x_psar.type.x_taruser}}
  {{x_pmar.identifier_ms}}.aruser   <= {{=x_caruser}}{{>vhdl/putvalue.part.tpl}}{{|x_caruser}}{{x_pmar.type.x_taruser.x_cnull.qualified}}{{/x_caruser}};
{{/   x_psar.type.x_taruser}}
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.aruser   <= {{=x_caruser}}{{>vhdl/putvalue.part.tpl}}{{|x_caruser}}{{x_pmar.type.x_taruser.x_cnull.qualified}}{{/x_caruser}};
{{/  x_psar.type.x_has_ar}}
{{/ x_pmar.type.x_taruser}}
{{; ----- arvalid -----}}
{{?  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arvalid  <= {{x_psar.identifier_ms}}.arvalid;
{{|  x_psar.type.x_has_ar}}
  {{x_pmar.identifier_ms}}.arvalid  <= {{=x_carvalid}}{{>vhdl/putvalue.part.tpl}}{{|x_carvalid}}{{x_pmar.type.x_tlogic.x_cnull.qualified}}{{/x_carvalid}};
{{/  x_psar.type.x_has_ar}}
{{/x_pmar.type.x_has_ar}}
{{?x_psar.type.x_has_ar}}
{{; ----- arready -----}}
{{?  x_pmar.type.x_has_ar}}
  {{x_psar.identifier_sm}}.arready  <= {{x_pmar.identifier_sm}}.arready;
{{|  x_pmar.type.x_has_ar}}
  {{x_psar.identifier_sm}}.arready  <= {{=x_carready}}{{>vhdl/putvalue.part.tpl}}{{|x_carready}}{{x_psar.type.x_tlogic.x_cnull.qualified}}{{/x_carready}};
{{/  x_pmar.type.x_has_ar}}
{{/x_psar.type.x_has_ar}}

{{; ------- R -------}}
{{?x_psr.type.x_has_r}}
{{; ----- rdata -----}}
{{?  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rdata     <= f_resize({{x_pmr.identifier_sm}}.rdata, {{x_psr.type.x_tdata.x_width}});
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rdata     <= {{=x_crdata}}{{>vhdl/putvalue.part.tpl}}{{|x_crdata}}{{x_psr.type.x_tdata.x_cnull.qualified}}{{/x_crdata}};
{{/  x_pmr.type.x_has_r}}
{{; ----- rresp -----}}
{{?  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rresp     <= {{x_pmr.identifier_sm}}.rresp;
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rresp     <= {{=x_crresp}}{{>vhdl/putvalue.part.tpl}}{{|x_crresp}}{{x_psr.type.x_tresp.x_cnull.qualified}}{{/x_crresp}};
{{/  x_pmr.type.x_has_r}}
{{; ----- rlast -----}}
{{? x_psr.type.x_tlast}}
{{?  x_pmr.type.x_has_r}}
{{?   x_pmr.type.x_tlast}}
  {{x_psr.identifier_sm}}.rlast     <= {{x_pmr.identifier_sm}}.rlast;
{{|   x_pmr.type.x_tlast}}
  {{x_psr.identifier_sm}}.rlast     <= {{=x_crlast}}{{>vhdl/putvalue.part.tpl}}{{|x_crlast}}{{x_psr.type.x_tlast.x_cnull.qualified}}{{/x_crlast}};
{{/   x_pmr.type.x_tlast}}
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rlast     <= {{=x_crlast}}{{>vhdl/putvalue.part.tpl}}{{|x_crlast}}{{x_psr.type.x_tlast.x_cnull.qualified}}{{/x_crlast}};
{{/  x_pmr.type.x_has_r}}
{{/ x_psr.type.x_tlast}}
{{; ----- rid -----}}
{{? x_psr.type.x_tid}}
{{?  x_pmr.type.x_has_r}}
{{?   x_pmr.type.x_tid}}
  {{x_psr.identifier_sm}}.rid       <= f_resize({{x_pmr.identifier_sm}}.rid, {{x_psr.type.x_tid.x_width}});
{{|   x_pmr.type.x_tid}}
  {{x_psr.identifier_sm}}.rid       <= {{=x_crid}}{{>vhdl/putvalue.part.tpl}}{{|x_crid}}{{x_psr.type.x_tid.x_cnull.qualified}}{{/x_crid}};
{{/   x_pmr.type.x_tid}}
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rid       <= {{=x_crid}}{{>vhdl/putvalue.part.tpl}}{{|x_crid}}{{x_psr.type.x_tid.x_cnull.qualified}}{{/x_crid}};
{{/  x_pmr.type.x_has_r}}
{{/ x_psr.type.x_tid}}
{{; ----- ruser -----}}
{{? x_psr.type.x_truser}}
{{?  x_pmr.type.x_has_r}}
{{?   x_pmr.type.x_truser}}
  {{x_psr.identifier_sm}}.ruser     <= f_resize({{x_pmr.identifier_sm}}.ruser, {{x_psr.type.x_truser.x_width}});
{{|   x_pmr.type.x_truser}}
  {{x_psr.identifier_sm}}.ruser     <= {{=x_cruser}}{{>vhdl/putvalue.part.tpl}}{{|x_cruser}}{{x_psr.type.x_truser.x_cnull.qualified}}{{/x_cruser}};
{{/   x_pmr.type.x_truser}}
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.ruser     <= {{=x_cruser}}{{>vhdl/putvalue.part.tpl}}{{|x_cruser}}{{x_psr.type.x_truser.x_cnull.qualified}}{{/x_cruser}};
{{/  x_pmr.type.x_has_r}}
{{/ x_psr.type.x_truser}}
{{; ----- rvalid -----}}
{{?  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rvalid    <= {{x_pmr.identifier_sm}}.rvalid;
{{|  x_pmr.type.x_has_r}}
  {{x_psr.identifier_sm}}.rvalid    <= {{=x_crvalid}}{{>vhdl/putvalue.part.tpl}}{{|x_crvalid}}{{x_psr.type.x_tlogic.x_cnull.qualified}}{{/x_crvalid}};
{{/  x_pmr.type.x_has_r}}
{{/x_psr.type.x_has_r}}
{{?x_pmr.type.x_has_r}}
{{; ----- rready -----}}
{{?  x_psr.type.x_has_r}}
  {{x_pmr.identifier_ms}}.rready    <= {{x_psr.identifier_ms}}.rready;
{{|  x_psr.type.x_has_r}}
  {{x_pmr.identifier_ms}}.rready    <= {{=x_crready}}{{>vhdl/putvalue.part.tpl}}{{|x_crready}}{{x_pmr.type.x_tlogic.x_cnull.qualified}}{{/x_crready}};
{{/  x_psr.type.x_has_r}}
{{/x_pmr.type.x_has_r}}

end AxiWiring;
