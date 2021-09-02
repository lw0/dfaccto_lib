{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture RdMuxNoId of {{identifier}} is

  alias ag_Count is {{x_gcount.identifier}};

  alias ai_clk   is {{x_psys.identifier}}.clk;
  alias ai_rst_n is {{x_psys.identifier}}.rst_n;

  -- Address Channel AR or AW:
  subtype at_AxiAR_ms   is {{x_pm.type.x_tpart_ar.identifier_ms}};
  subtype at_AxiAR_sm   is {{x_pm.type.x_tpart_ar.identifier_sm}};
  subtype at_AxiAR_v_ms is {{x_pm.type.x_tpart_ar.identifier_v_ms}};
  subtype at_AxiAR_v_sm is {{x_pm.type.x_tpart_ar.identifier_v_sm}};
  subtype at_AxiR_ms    is {{x_pm.type.x_tpart_r.identifier_ms}};
  subtype at_AxiR_sm    is {{x_pm.type.x_tpart_r.identifier_sm}};
  subtype at_AxiR_v_ms  is {{x_pm.type.x_tpart_r.identifier_v_ms}};
  subtype at_AxiR_v_sm  is {{x_pm.type.x_tpart_r.identifier_v_sm}};

  alias ac_AxiARNull_ms is {{x_pm.type.x_tpart_ar.x_cnull.identifier_ms}};
  alias ac_AxiARNull_sm is {{x_pm.type.x_tpart_ar.x_cnull.identifier_sm}};
  alias ac_AxiRNull_ms  is {{x_pm.type.x_tpart_r.x_cnull.identifier_ms}};
  alias ac_AxiRNull_sm  is {{x_pm.type.x_tpart_r.x_cnull.identifier_sm}};


  subtype t_PortVector  is unsigned (ag_Count-1 downto 0);
  subtype t_PortNumber  is unsigned (f_clog2(ag_Count)-1 downto 0);

  -- Separate AR and R Channels:
  signal s_masterAR_ms  : at_AxiAR_ms;
  signal s_masterAR_sm  : at_AxiAR_sm;
  signal s_masterR_ms   : at_AxiR_ms;
  signal s_masterR_sm   : at_AxiR_sm;

  signal s_slavesAR_od  : t_NativeAxiAR_v_ms(ag_Count-1 downto 0);
  signal s_slavesAR_do  : t_NativeAxiAR_v_sm(ag_Count-1 downto 0);
  signal s_slavesR_do   : t_NativeAxiR_v_ms(ag_Count-1 downto 0);
  signal s_slavesR_od   : t_NativeAxiR_v_sm(ag_Count-1 downto 0);

  -- Shortcut Signals
  signal s_arValid : std_logic;
  signal s_arReady : std_logic;
  signal s_rLast   : std_logic;
  signal s_rValid  : std_logic;
  signal s_rReady  : std_logic;

  signal s_arValidReq : t_PortVector;

  -- Address Channel Arbiter and Switch:
  signal s_arbitRequest  : t_PortVector;
  signal s_arbitPort     : t_PortNumber;
  signal s_arbitValid   : std_logic;
  signal s_arbitReady     : std_logic;

  signal s_barDone       : unsigned(1 downto 0);
  alias a_barDoneA is s_barDone(0);
  alias a_barDoneR is s_barDone(1);
  signal s_barMask       : unsigned(1 downto 0);
  alias a_barMaskA is s_barMask(0);
  alias a_barMaskR is s_barMask(1);
  signal s_barContinue   : std_logic;

  signal s_switchAEnable : std_logic;
  signal s_switchASelect : t_PortNumber;
  signal s_slavesAValid  : t_PortVector;

  -- Read Channel FIFO and Switch:
  signal s_fifoRInReady  : std_logic;
  signal s_fifoRInValid  : std_logic;

  signal s_fifoROutPort  : t_PortNumber;
  signal s_fifoROutReady : std_logic;
  signal s_fifoROutValid : std_logic;

  signal s_switchREnable : std_logic;
  signal s_switchRSelect : t_PortNumber;

begin

  -- Separate AR and R Channels:
  i_join : entity work.{{x_ejoin}}
    port map(
      {{x_ejoin.x_psys.identifier}} => {{x_psys.identifier}},
      {{x_ejoin.x_psar.identifier_ms}} => s_masterAW_ms,
      {{x_ejoin.x_psar.identifier_sm}} => s_masterAW_sm,
      {{x_ejoin.x_psr.identifier_ms}} => s_masterW_ms,
      {{x_ejoin.x_psr.identifier_sm}} => s_masterW_sm,
      {{x_ejoin.x_pmrd.identifier_ms}} => {{x_pm.identifier_ms}},
      {{x_ejoin.x_pmrd.identifier_sm}} => {{x_pm.identifier_sm}});
  s_arValid <= s_masterAR_ms.arvalid;
  s_arReady <= s_masterAR_sm.arready;
{{?x_pm.type.x_tlast}}
  s_rLast   <= s_masterR_sm.rlast;
{{|x_pm.type.x_tlast}}
  s_rLast   <= '1';
{{/x_pm.type.x_tlast}}
  s_rValid  <= s_masterR_sm.rvalid;
  s_rReady  <= s_masterR_ms.rready;

  i_splits : for v_idx in 0 to ag_Count-1 generate
    i_split : entity work.{{x_esplit}}
      port map(
        {{x_esplit.x_psys.identifier}} => {{x_psys.identifier}},
        {{x_esplit.x_psrd.identifier_ms}} => {{x_psv.identifier_ms}}({{x_psv.identifier_ms}}'low + v_idx),
        {{x_esplit.x_psrd.identifier_sm}} => {{x_psv.identifier_sm}}({{x_psv.identifier_sm}}'low + v_idx),
        {{x_esplit.x_pmar.identifier_ms}} => s_slavesAR_ms(v_idx),
        {{x_esplit.x_pmar.identifier_sm}} => s_slavesAR_sm(v_idx),
        {{x_esplit.x_pmr.identifier_ms}} => s_slavesR_ms(v_idx),
        {{x_esplit.x_pmr.identifier_sm}} => s_slavesR_sm(v_idx));
    s_arValidReq(v_idx) <= s_slavesAR_ms(v_idx).arvalid;
  end i_splits;


  -- Address Channel Arbiter:
  s_arbitRequest <= s_arValidReq;
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
      g_Count => 2)
    port map (
      pi_clk => ai_clk,
      pi_rst_n => ai_rst_n,
      pi_signal => s_barDone,
      po_mask => s_barMask,
      po_continue => s_barContinue);


  -- Address Channel Switch:
  s_switchAEnable <= s_arbitValid and not a_barMaskA;
  s_switchASelect <= s_arbitPort;
  a_barDoneA <= s_arValid and s_arReady;
  process (s_switchAEnable, s_switchASelect, s_slavesAR_ms, si_masterAR_sm)
  begin
    s_masterAR_ms <= ac_AxiARNull_ms;
    for v_idx in 0 to ag_Count-1 loop
      s_slavesAR_sm(v_idx) <= ac_AxiARNull_sm;
      if s_switchAEnable = '1' and v_idx = to_integer(s_switchASelect) then
        s_masterAR_ms <= s_slavesAR_ms(v_idx);
        s_slavesAR_sm(v_idx) <= s_masterAR_sm;
      end if;
    end loop;
  end process;

  -- Read Channel FIFO:
  s_fifoRInValid <= s_arbitValid and not a_barMaskR;
  a_barDoneR <= s_fifoRInValid and s_fifoRInReady;
  i_fifoR : entity work.{{x_efifo.identifier}}
    generic map (
      g_DataWidth => c_PortNumberWidth,
      g_LogDepth  => g_FIFOLogDepth)
    port map (
      pi_clk      => ai_sys.clk,
      pi_rst_n    => ai_sys.rst_n,
      pi_inData   => s_arbitPort,
      pi_inValid  => s_fifoRInValid,
      po_inReady  => s_fifoRInReady,
      po_outData  => s_fifoROutPort,
      po_outValid => s_fifoROutValid,
      pi_outReady => s_fifoROutReady);

  -- Read Channel Switch:
  s_switchREnable <= s_fifoROutValid;
  s_switchRSelect <= s_fifoROutPort;
  s_fifoROutReady <= s_rLast and s_rValid and s_rReady;
  process (s_switchREnable, s_switchRSelect, s_slavesR_ms, s_masterR_sm)
  begin
    s_masterR_ms <= ac_AxiRNull_ms;
    for v_idx in 0 to ag_Count-1 loop
      s_slavesR_sm(v_idx) <= ac_AxiRNull_sm;
      if s_switchREnable = '1' and v_idx = to_integer(s_switchRSelect) then
        s_masterR_ms <= s_slavesR_ms(v_idx);
        s_slavesR_sm(v_idx) <= s_masterR_sm;
      end if;
    end loop;
  end process;

end RdMuxNoId;
