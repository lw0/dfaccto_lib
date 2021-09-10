{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture SingleContext of {{identifier}} is

  alias ai_clk        is {{x_psysc.identifier}}.clk;
  alias ai_rst_n      is {{x_psysc.identifier}}.rst_n;
  alias ao_sys        is {{x_psys.identifier}};

  alias ao_intrCtx_ms is {{x_pintrc.identifier_ms}};
  alias ai_intrCtx_sm is {{x_pintrc.identifier_sm}};
  alias ai_intr_ms    is {{x_pintr.identifier_ms}};
  alias ao_intr_sm    is {{x_pintr.identifier_sm}};

  alias ai_ctrlCtx_ms is {{x_pctrlc.identifier_ms}};
  alias ao_ctrlCtx_sm is {{x_pctrlc.identifier_sm}};
  alias ao_ctrl_ms    is {{x_pctrl.identifier_ms}};
  alias ai_ctrl_sm    is {{x_pctrl.identifier_sm}};

  alias ao_hostCtx_ms is {{x_phostc.identifier_ms}};
  alias ai_hostCtx_sm is {{x_phostc.identifier_sm}};
  alias ai_host_ms    is {{x_phost.identifier_ms}};
  alias ao_host_sm    is {{x_phost.identifier_sm}};

  subtype at_CtrlAddr is {{x_pctrl.x_taddr.qualified}};
  subtype at_Context  is {{x_pintrc.x_tctx.qualified}};

  signal s_curActive  : std_logic;
  signal s_curContext : at_Context;

  signal s_ctrlAwAddr : at_CtrlAddr;
  signal s_ctrlAwCtx  : at_Context;
  signal s_ctrlArAddr : at_CtrlAddr;
  signal s_ctrlArCtx  : at_Context;

begin

  process (ai_clk)
  begin
    -- TODO-lw this is quite incorrect once more than one context are in use
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_curContext <= (others => '0');
        s_curActive <= '0';
      elsif s_ctrlAwValid = '1' then
        s_curContext <= s_ctrlAwCtx;
        s_curActive <= '1';
      elsif s_ctrlArValid = '1' then
        s_curContext <= s_ctrlArCtx;
        s_curActive <= '1';
      end if;
    end if;
  end process;


  -- TODO-lw implement proper isolation mechanism
  ao_sys.clk   <= ai_clk;
  ao_sys.rst_n <= ai_rst_n;


  s_ctrlAwAddr          <= f_resize(ai_ctrlCtx_ms.awaddr, at_CtrlAddr'length);
  s_ctrlAwCtx           <= f_resize(ai_ctrlCtx_ms.awaddr, at_Context'length, at_CtrlAddr'length);
  s_ctrlArAddr          <= f_resize(ai_ctrlCtx_ms.araddr, at_CtrlAddr'length);
  s_ctrlArCtx           <= f_resize(ai_ctrlCtx_ms.araddr, at_Context'length, at_CtrlAddr'length);
  -- TODO-lw implement proper isolation mechanism with outstanding transfer counters &c
  ao_ctrlCtx_sm.awready <= ai_ctrl_sm.awready;
  ao_ctrlCtx_sm.wready  <= ai_ctrl_sm.wready;
  ao_ctrlCtx_sm.bresp   <= ai_ctrl_sm.bresp;
  ao_ctrlCtx_sm.bvalid  <= ai_ctrl_sm.bvalid;
  ao_ctrlCtx_sm.arready <= ai_ctrl_sm.arready;
  ao_ctrlCtx_sm.rdata   <= ai_ctrl_sm.rdata;
  ao_ctrlCtx_sm.rresp   <= ai_ctrl_sm.rresp;
  ao_ctrlCtx_sm.rvalid  <= ai_ctrl_sm.rvalid;
  ao_ctrl_ms.awaddr     <= s_ctrlAwAddr;
  ao_ctrl_ms.awvalid    <= ai_ctrlCtx_ms.awvalid;
  ao_ctrl_ms.wdata      <= ai_ctrlCtx_ms.wdata;
  ao_ctrl_ms.wstrb      <= ai_ctrlCtx_ms.wstrb;
  ao_ctrl_ms.wvalid     <= ai_ctrlCtx_ms.wvalid;
  ao_ctrl_ms.bready     <= ai_ctrlCtx_ms.bready;
  ao_ctrl_ms.araddr     <= s_ctrlArAddr;
  ao_ctrl_ms.arvalid    <= ai_ctrlCtx_ms.arvalid;
  ao_ctrl_ms.rready     <= ai_ctrlCtx_ms.rready;


  -- TODO-lw implement proper isolation mechanism with outstanding transfer counters &c
  ao_intrCtx_ms.ctx <= s_curContext;
  ao_intrCtx_ms.src <= ai_intr_ms.sdata;
  ao_intrCtx_ms.stb <= ai_intr_ms.stb;
  ao_intr_ms.ack    <= ai_intrCtx_ms.ack;


  -- TODO-lw implement proper isolation mechanism with outstanding transfer counters &c
  ao_hostCtx_ms.awaddr  <= ai_host_ms.awaddr;
  ao_hostCtx_ms.awlen   <= ai_host_ms.awlen;
  ao_hostCtx_ms.awsize  <= ai_host_ms.awsize;
  ao_hostCtx_ms.awburst <= ai_host_ms.awburst;
  ao_hostCtx_ms.awid    <= ai_host_ms.awid;
  ao_hostCtx_ms.awuser  <= s_curContext;
  ao_hostCtx_ms.awvalid <= ai_host_ms.awvalid;
  ao_hostCtx_ms.wdata   <= ai_host_ms.wdata;
  ao_hostCtx_ms.wstrb   <= ai_host_ms.wstrb;
  ao_hostCtx_ms.wlast   <= ai_host_ms.wlast;
  ao_hostCtx_ms.wvalid  <= ai_host_ms.wvalid;
  ao_hostCtx_ms.bready  <= ai_host_ms.bready;
  ao_hostCtx_ms.araddr  <= ai_host_ms.araddr;
  ao_hostCtx_ms.arlen   <= ai_host_ms.arlen;
  ao_hostCtx_ms.arsize  <= ai_host_ms.arsize;
  ao_hostCtx_ms.arburst <= ai_host_ms.arburst;
  ao_hostCtx_ms.arid    <= ai_host_ms.arid;
  ao_hostCtx_ms.aruser  <= s_curContext;
  ao_hostCtx_ms.arvalid <= ai_host_ms.arvalid;
  ao_hostCtx_ms.rready  <= ai_host_ms.rready;
  ao_host_sm.awready    <= ai_hostCtx_sm.awready;
  ao_host_sm.wready     <= ai_hostCtx_sm.wready;
  ao_host_sm.bresp      <= ai_hostCtx_sm.bresp;
  ao_host_sm.bid        <= ai_hostCtx_sm.bid;
  ao_host_sm.bvalid     <= ai_hostCtx_sm.bvalid;
  ao_host_sm.arready    <= ai_hostCtx_sm.arready;
  ao_host_sm.rdata      <= ai_hostCtx_sm.rdata;
  ao_host_sm.rresp      <= ai_hostCtx_sm.rresp;
  ao_host_sm.rlast      <= ai_hostCtx_sm.rlast;
  ao_host_sm.rid        <= ai_hostCtx_sm.rid;
  ao_host_sm.rvalid     <= ai_hostCtx_sm.rvalid;

end SingleContext;
