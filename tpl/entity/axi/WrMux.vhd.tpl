{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture AxiWrMuxNoId of {{identifier}} is

  alias ag_FifoLogDepth is {{x_gdepth.identifier}};
  alias ag_Count is {{x_gcount.identifier}};

  alias ai_clk   is {{x_psys.identifier}}.clk;
  alias ai_rst_n is {{x_psys.identifier}}.rst_n;

  subtype at_AxiAW_ms   is {{x_pm.type.x_tpart_aw.qualified_ms}};
  subtype at_AxiAW_sm   is {{x_pm.type.x_tpart_aw.qualified_sm}};
  subtype at_AxiAW_v_ms is {{x_pm.type.x_tpart_aw.qualified_v_ms}};
  subtype at_AxiAW_v_sm is {{x_pm.type.x_tpart_aw.qualified_v_sm}};
  subtype at_AxiW_ms    is {{x_pm.type.x_tpart_w.qualified_ms}};
  subtype at_AxiW_sm    is {{x_pm.type.x_tpart_w.qualified_sm}};
  subtype at_AxiW_v_ms  is {{x_pm.type.x_tpart_w.qualified_v_ms}};
  subtype at_AxiW_v_sm  is {{x_pm.type.x_tpart_w.qualified_v_sm}};
  subtype at_AxiB_ms    is {{x_pm.type.x_tpart_b.qualified_ms}};
  subtype at_AxiB_sm    is {{x_pm.type.x_tpart_b.qualified_sm}};
  subtype at_AxiB_v_ms  is {{x_pm.type.x_tpart_b.qualified_v_ms}};
  subtype at_AxiB_v_sm  is {{x_pm.type.x_tpart_b.qualified_v_sm}};

  alias ac_AxiAWNull_ms is {{x_pm.type.x_tpart_aw.x_cnull.qualified_ms}};
  alias ac_AxiAWNull_sm is {{x_pm.type.x_tpart_aw.x_cnull.qualified_sm}};
  alias ac_AxiWNull_ms  is {{x_pm.type.x_tpart_w.x_cnull.qualified_ms}};
  alias ac_AxiWNull_sm  is {{x_pm.type.x_tpart_w.x_cnull.qualified_sm}};
  alias ac_AxiBNull_ms  is {{x_pm.type.x_tpart_b.x_cnull.qualified_ms}};
  alias ac_AxiBNull_sm  is {{x_pm.type.x_tpart_b.x_cnull.qualified_sm}};

  subtype t_PortVector  is unsigned (ag_Count-1 downto 0);
  subtype t_PortNumber  is unsigned (f_clog2(ag_Count)-1 downto 0);

  -- Separate AW, W and B Channels:
  signal s_masterAW_ms   : at_AxiAW_ms;
  signal s_masterAW_sm   : at_AxiAW_sm;
  signal s_masterW_ms    : at_AxiW_ms;
  signal s_masterW_sm    : at_AxiW_sm;
  signal s_masterB_ms    : at_AxiB_ms;
  signal s_masterB_sm    : at_AxiB_sm;

  signal s_slavesAW_ms   : at_AxiAW_v_ms(ag_Count-1 downto 0);
  signal s_slavesAW_sm   : at_AxiAW_v_sm(ag_Count-1 downto 0);
  signal s_slavesW_ms    : at_AxiW_v_ms(ag_Count-1 downto 0);
  signal s_slavesW_sm    : at_AxiW_v_sm(ag_Count-1 downto 0);
  signal s_slavesB_ms    : at_AxiB_v_ms(ag_Count-1 downto 0);
  signal s_slavesB_sm    : at_AxiB_v_sm(ag_Count-1 downto 0);

  -- Shortcut Signals:
  signal s_awValid       : std_logic;
  signal s_awReady       : std_logic;
  signal s_wLast         : std_logic;
  signal s_wValid        : std_logic;
  signal s_wReady        : std_logic;
  signal s_bValid        : std_logic;
  signal s_bReady        : std_logic;

  signal s_awValidReq    : t_PortVector;

  -- Address/Write Channel Arbiter and Switches:
  signal s_arbitRequest  : t_PortVector;
  signal s_arbitPort     : t_PortNumber;
  signal s_arbitValid    : std_logic;
  signal s_arbitReady    : std_logic;

  signal s_barDone       : unsigned(2 downto 0);
  alias a_barDoneA is s_barDone(0);
  alias a_barDoneW is s_barDone(1);
  alias a_barDoneB is s_barDone(2);
  signal s_barMask       : unsigned(2 downto 0);
  alias a_barMaskA is s_barMask(0);
  alias a_barMaskW is s_barMask(1);
  alias a_barMaskB is s_barMask(2);
  signal s_barContinue   : std_logic;

  signal s_switchAEnable : std_logic;
  signal s_switchASelect : t_PortNumber;
  signal s_slavesAValid  : t_PortVector;

  -- Write Channel FIFO and Switch:
  signal s_fifoWInReady  : std_logic;
  signal s_fifoWInValid  : std_logic;

  signal s_fifoWOutPort  : t_PortNumber;
  signal s_fifoWOutReady : std_logic;
  signal s_fifoWOutValid : std_logic;

  signal s_switchWEnable : std_logic;
  signal s_switchWSelect : t_PortNumber;

  -- Response Channel FIFO and Switch:
  signal s_fifoBInValid  : std_logic;
  signal s_fifoBInReady  : std_logic;

  signal s_fifoBOutPort  : t_PortNumber;
  signal s_fifoBOutValid : std_logic;
  signal s_fifoBOutReady : std_logic;

  signal s_switchBEnable : std_logic;
  signal s_switchBSelect : t_PortNumber;

begin

  -- Separate AW, W and B Channels:
  i_join : entity work.{{x_ejoin}}
    port map(
      {{x_ejoin.x_psys.identifier}} => {{x_psys.identifier}},
      {{x_ejoin.x_psaw.identifier_ms}} => s_masterAW_ms,
      {{x_ejoin.x_psaw.identifier_sm}} => s_masterAW_sm,
      {{x_ejoin.x_psw.identifier_ms}} => s_masterW_ms,
      {{x_ejoin.x_psw.identifier_sm}} => s_masterW_sm,
      {{x_ejoin.x_psb.identifier_ms}} => s_masterB_ms,
      {{x_ejoin.x_psb.identifier_sm}} => s_masterB_sm,
      {{x_ejoin.x_pmwr.identifier_ms}} => {{x_pm.identifier_ms}},
      {{x_ejoin.x_pmwr.identifier_sm}} => {{x_pm.identifier_sm}});
  s_awValid <= s_masterAW_ms.awvalid;
  s_awReady <= s_masterAW_sm.awready;
{{?x_pm.type.x_tlast}}
  s_wLast   <= s_masterW_ms.wlast;
{{|x_pm.type.x_tlast}}
  s_wLast   <= '1';
{{/x_pm.type.x_tlast}}
  s_wValid  <= s_masterW_ms.wvalid;
  s_wReady  <= s_masterW_sm.wready;
  s_bValid  <= s_masterB_sm.bvalid;
  s_bReady  <= s_masterB_ms.bready;

  i_splits : for v_idx in 0 to ag_Count-1 generate
    i_split : entity work.{{x_esplit}}
      port map(
        {{x_esplit.x_psys.identifier}} => {{x_psys.identifier}},
        {{x_esplit.x_pswr.identifier_ms}} => {{x_psv.identifier_ms}}({{x_psv.identifier_ms}}'low + v_idx),
        {{x_esplit.x_pswr.identifier_sm}} => {{x_psv.identifier_sm}}({{x_psv.identifier_sm}}'low + v_idx),
        {{x_esplit.x_pmaw.identifier_ms}} => s_slavesAW_ms(v_idx),
        {{x_esplit.x_pmaw.identifier_sm}} => s_slavesAW_sm(v_idx),
        {{x_esplit.x_pmw.identifier_ms}} => s_slavesW_ms(v_idx),
        {{x_esplit.x_pmw.identifier_sm}} => s_slavesW_sm(v_idx),
        {{x_esplit.x_pmb.identifier_ms}} => s_slavesB_ms(v_idx),
        {{x_esplit.x_pmb.identifier_sm}} => s_slavesB_sm(v_idx));
    s_awValidReq(v_idx) <= s_slavesAW_ms(v_idx).awvalid;
  end generate;

  -- Address Channel Arbiter:
  s_arbitRequest <= s_awValidReq;
  s_arbitReady <= s_barContinue;
  i_arbiter : entity work.{{x_earbiter.identifier}}
    generic map (
      g_PortCount => ag_Count)
    port map (
      pi_clk      => ai_clk,
      pi_rst_n    => ai_rst_n,
      pi_request  => s_arbitRequest,
      po_port     => s_arbitPort,
      po_valid    => s_arbitValid,
      pi_ready    => s_arbitReady);

  i_barrier : entity work.{{x_ebarrier.identifier}}
    generic map (
      g_Count => 3)
    port map (
      pi_clk => ai_clk,
      pi_rst_n => ai_rst_n,
      pi_signal => s_barDone,
      po_mask => s_barMask,
      po_continue => s_barContinue);

  -- Address Channel Switch
  s_switchAEnable <= s_arbitValid and not a_barMaskA;
  s_switchASelect <= s_arbitPort;
  a_barDoneA <= s_awValid and s_awReady;
  process (s_switchAEnable, s_switchASelect, s_slavesAW_ms, s_masterAW_sm)
  begin
    s_masterAW_ms <= ac_AxiAWNull_ms;
    for v_idx in 0 to ag_Count-1 loop
      s_slavesAW_sm(v_idx) <= ac_AxiAWNull_sm;
      if s_switchAEnable = '1' and v_idx = to_integer(s_switchASelect) then
        s_masterAW_ms <= s_slavesAW_ms(v_idx);
        s_slavesAW_sm(v_idx) <= s_masterAW_sm;
      end if;
    end loop;
  end process;

  -- Write Channel FIFO:
  s_fifoWInValid <= s_arbitValid and not a_barMaskW;
  a_barDoneW <= s_fifoWInValid and s_fifoWInReady;
  i_fifoW : entity work.{{x_efifo.identifier}}
    generic map (
      g_DataWidth => t_PortNumber'length,
      g_LogDepth  => ag_FifoLogDepth)
    port map (
      pi_clk      => ai_clk,
      pi_rst_n    => ai_rst_n,
      pi_inData   => s_arbitPort,
      pi_inValid  => s_fifoWInValid,
      po_inReady  => s_fifoWInReady,
      po_outData  => s_fifoWOutPort,
      po_outValid => s_fifoWOutValid,
      pi_outReady => s_fifoWOutReady);

  -- Write Channel Switch
  s_switchWEnable <= s_fifoWOutValid;
  s_switchWSelect <= s_fifoWOutPort;
  s_fifoWOutReady <= s_wLast and s_wValid and s_wReady;
  process (s_switchWEnable, s_switchWSelect, s_slavesW_ms, s_masterW_sm)
  begin
    s_masterW_ms <= ac_AxiWNull_ms;
    for v_idx in 0 to ag_Count-1 loop
      s_slavesW_sm(v_idx) <= ac_AxiWNull_sm;
      if s_switchWEnable = '1' and v_idx = to_integer(s_switchWSelect) then
        s_masterW_ms <= s_slavesW_ms(v_idx);
        s_slavesW_sm(v_idx) <= s_masterW_sm;
      end if;
    end loop;
  end process;

  -- Response Channel FIFO:
  s_fifoBInValid <= s_arbitValid and not a_barMaskB;
  a_barDoneB <= s_fifoBInValid and s_fifoBInReady;
  i_fifoB : entity work.{{x_efifo.identifier}}
    generic map (
      g_DataWidth => t_PortNumber'length,
      g_LogDepth  => ag_FifoLogDepth)
    port map (
      pi_clk      => ai_clk,
      pi_rst_n    => ai_rst_n,
      pi_inData   => s_arbitPort,
      pi_inValid  => s_fifoBInValid,
      po_inReady  => s_fifoBInReady,
      po_outData  => s_fifoBOutPort,
      po_outValid => s_fifoBOutValid,
      pi_outReady => s_fifoBOutReady);

  -- Response Channel Switch
  s_switchBEnable <= s_fifoBOutValid;
  s_switchBSelect <= s_fifoBOutPort;
  s_fifoBOutReady <= s_bValid and s_bReady;
  process (s_switchBEnable, s_switchBSelect, s_slavesB_ms, s_masterB_sm)
  begin
    s_masterB_ms <= ac_AxiBNull_ms;
    for v_idx in 0 to ag_Count-1 loop
      s_slavesB_sm(v_idx) <= ac_AxiBNull_sm;
      if s_switchBEnable = '1' and v_idx = to_integer(s_switchBSelect) then
        s_masterB_ms <= s_slavesB_ms(v_idx);
        s_slavesB_sm(v_idx) <= s_masterB_sm;
      end if;
    end loop;
  end process;

end AxiWrMuxNoId;
