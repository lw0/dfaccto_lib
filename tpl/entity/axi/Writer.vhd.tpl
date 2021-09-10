{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture Writer of {{identifier}} is

  -- Config port (4 registers):
  --  Reg0: Start address low word
  --  Reg1: Start address high word
  --  Reg2: Transfer count
  --  Reg3: Maximum Burst length

  alias ag_FifoLogDepth is {{x_gdepth.identifier}};

  -- Map internal signals on templated signals
  alias ai_clk    is {{x_psys.identifier}}.clk;
  alias ai_rst_n  is {{x_psys.identifier}}.rst_n;
  alias ai_start  is {{x_pstart.identifier_ms}}.stb;
  alias ao_ready  is {{x_pstart.identifier_sm}}.ack;
  alias ai_hold   is {{x_phold.identifier}};
  alias ao_axi_ms is {{x_paxi.identifier_ms}};
  alias ai_axi_sm is {{x_paxi.identifier_sm}};
  alias ai_stm_ms is {{x_pstm.identifier_ms}};
  alias ao_stm_sm is {{x_pstm.identifier_sm}};
  alias ai_reg_ms is {{x_preg.identifier_ms}};
  alias ao_reg_sm is {{x_preg.identifier_sm}};

  subtype at_AxiAddr is {{x_paxi.type.x_taddr.qualified}};
  subtype at_AxiWordAddr is {{x_paxi.type.x_twaddr.qualified}};
  subtype at_AxiLen is {{x_paxi.type.x_tlen.qualified}};

  alias ac_AxiBurstIncr is {{x_paxi.type.x_tburst.x_cincr.qualified}};
  alias ac_AxiSizeFull is {{x_paxi.type.x_csize.qualified}};
  alias ac_AxiWordBound is {{x_paxi.type.x_cwbound.qualified}};

  subtype at_RegData is {{x_preg.type.x_tdata.qualified}};

  signal so_ready              : std_logic;
  signal s_addrStart           : std_logic;
  signal s_addrReady           : std_logic;

  -- Address State Machine
  signal s_cfgAddr             : at_AxiWordAddr;
  signal s_cfgCount            : at_RegData;
  signal s_cfgMaxLen           : at_AxiLen;

  signal s_awAddr          : at_AxiWordAddr;
  signal s_awLen               : at_AxiLen;
  signal s_awValid             : std_logic;
  signal s_awReady             : std_logic;

  -- Burst Count Queue
  signal s_queueBurstCount     : at_AxiLen;
  signal s_queueBurstLast      : std_logic;
  signal s_queueValid          : std_logic;
  signal s_queueReady          : std_logic;

  -- Data State Machine
  type t_DataState is (Idle, ThruConsume, Thru, ThruWait, FillConsume, Fill, FillWait);
  signal s_state               : t_DataState;
  signal s_burstCount          : at_AxiLen;
  signal s_burstLast           : std_logic;

  signal s_abort               : std_logic;

  signal so_axi_ms_wvalid      : std_logic;
  signal so_stm_sm_tready      : std_logic;

  -- Control Registers
  signal so_reg_sm_ready       : std_logic;
  signal s_regAdr              : unsigned (2*at_RegData'length-1 downto 0);
  alias  a_regALo              is s_regAdr(  at_RegData'length-1 downto 0);
  alias  a_regAHi              is s_regAdr(2*at_RegData'length-1 downto at_RegData'length);
  signal s_regCnt              : at_RegData;
  signal s_regBst              : at_RegData;

  -- Status Output
  signal s_status              : unsigned (19 downto 0);
  signal s_addrStatus          : unsigned (7 downto 0);
  signal s_stateEnc            : unsigned (2 downto 0);

begin

  s_addrStart <= so_ready and ai_start;
  so_ready <= s_addrReady and f_logic(s_state = Idle);
  ao_ready <= so_ready;

  -----------------------------------------------------------------------------
  -- Address State Machine
  -----------------------------------------------------------------------------
  ao_axi_ms.awaddr <= f_resizeLeft(s_awAddr, ao_axi_ms.awaddr'length); -- convert word to byte address
  ao_axi_ms.awlen <= s_awLen;
  ao_axi_ms.awsize <= ac_AxiSizeFull;
  ao_axi_ms.awburst <= ac_AxiBurstIncr;
  ao_axi_ms.awvalid <= s_awValid;
  s_awReady <= ai_axi_sm.awready;

  s_cfgAddr <= f_resizeLeft(s_regAdr, s_cfgAddr'length); -- convert byte to word addr
  s_cfgCount   <= s_regCnt;
  s_cfgMaxLen  <= f_resize(s_regBst, s_cfgMaxLen'length);
  i_addrMachine : entity work.{{x_eamach.identifier}}
    generic map (
      g_WordAddrWidth => at_AxiWordAddr'length,
      g_BurstLengthWidth => at_AxiLen'length,
      g_BurstCountWidth => at_RegData'length,
      g_Boundary => ac_AxiWordBound,
      g_FifoLogDepth => ag_FifoLogDepth)
    port map (
      pi_clk             => ai_clk,
      pi_rst_n           => ai_rst_n,
      pi_start           => s_addrStart,
      po_ready           => s_addrReady,
      pi_hold            => ai_hold,
      pi_abort           => s_abort,
      pi_address         => s_cfgAddr,
      pi_count           => s_cfgCount,
      pi_maxLen          => s_cfgMaxLen,
      po_axiAAddr        => s_awAddr,
      po_axiALen         => s_awLen,
      po_axiAValid       => s_awValid,
      pi_axiAReady       => s_awReady,
      po_queueBurstCount => s_queueBurstCount,
      po_queueBurstLast  => s_queueBurstLast,
      po_queueValid      => s_queueValid,
      pi_queueReady      => s_queueReady,
      po_status          => s_addrStatus);

  -----------------------------------------------------------------------------
  -- Data State Machine
  -----------------------------------------------------------------------------
  ao_axi_ms.wdata <= ai_stm_ms.tdata;
  with s_state select ao_axi_ms.wstrb <=
    ai_stm_ms.tkeep     when Thru,
    ai_stm_ms.tkeep     when ThruConsume,
    (others => '0')     when Fill,
    (others => '0')     when FillConsume,
    (others => '0')     when others;
  ao_axi_ms.wlast <= f_logic(s_burstCount = 0);
  with s_state select so_axi_ms_wvalid <=
    ai_stm_ms.tvalid    when Thru,
    ai_stm_ms.tvalid    when ThruConsume,
    '1'                 when Fill,
    '1'                 when FillConsume,
    '0'                 when others;
  ao_axi_ms.wvalid <= so_axi_ms_wvalid;
  with s_state select so_stm_sm_tready <=
    ai_axi_sm.wready    when Thru,
    ai_axi_sm.wready    when ThruConsume,
    '0'                 when others;
  ao_stm_sm.tready <= so_stm_sm_tready;
  with s_state select s_abort <=
    '1'                 when Fill,
    '1'                 when FillConsume,
    '1'                 when FillWait,
    '0'                 when others;
  -- always accept and ignore responses (TODO-lw: handle bresp /= OKAY)
  ao_axi_ms.bready <= '1';

  with s_state select s_queueReady <=
    '1' when ThruConsume,
    '1' when FillConsume,
    '0' when others;

  process (ai_clk)
    variable v_beat : boolean; -- Data Channel Handshake
    variable v_bend : boolean; -- Last Data Channel Handshake in Burst
    variable v_blst : boolean; -- Last Burst
    variable v_send : boolean; -- Stream End
    variable v_qval : boolean; -- Queue Valid
  begin
    if ai_clk'event and ai_clk = '1' then
      v_beat := so_axi_ms_wvalid = '1' and
                ai_axi_sm.wready = '1';
      v_bend := (s_burstCount = to_unsigned(0, s_burstCount'length)) and
                so_axi_ms_wvalid = '1' and
                ai_axi_sm.wready = '1';
      v_blst := s_burstLast = '1';
      v_send := ai_stm_ms.tlast = '1' and
                ai_stm_ms.tvalid = '1' and
                so_stm_sm_tready = '1';
      v_qval := s_queueValid = '1';

      if ai_rst_n = '0' then
        s_burstCount <= (others => '0');
        s_burstLast <= '0';
        s_state <= Idle;
      else
        case s_state is

          when Idle =>
            if v_qval then
              s_burstCount <= s_queueBurstCount;
              s_burstLast <= s_queueBurstLast;
              s_state <= ThruConsume;
            end if;

          when ThruConsume =>
            if v_beat then
              s_burstCount <= s_burstCount - to_unsigned(1, s_burstCount'length);
            end if;
            if v_bend then
              if v_blst then
                -- TODO-lw add unfinished Stream Signaling or consume until v_send
                s_state <= Idle;
              elsif v_send then
                s_state <= FillWait;
              else
                s_state <= ThruWait;
              end if;
            elsif v_send then
              s_state <= Fill;
            else
              s_state <= Thru;
            end if;

          when Thru =>
            if v_beat then
              s_burstCount <= s_burstCount - to_unsigned(1, s_burstCount'length);
            end if;
            if v_bend then
              if v_blst then
                -- TODO-lw add unfinished Stream Signaling or consume until v_send
                s_state <= Idle;
              elsif v_qval then
                s_burstCount <= s_queueBurstCount;
                s_burstLast <= s_queueBurstLast;
                if v_send then
                  s_state <= FillConsume;
                else
                  s_state <= ThruConsume;
                end if;
              elsif v_send then
                s_state <= FillWait;
              else
                s_state <= ThruWait;
              end if;
            elsif v_send then
              s_state <= Fill;
            end if;

          when ThruWait =>
            if v_qval then
              s_burstCount <= s_queueBurstCount;
              s_burstLast <= s_queueBurstLast;
              s_state <= ThruConsume;
            end if;

          when FillConsume =>
            if v_beat then
              s_burstCount <= s_burstCount - to_unsigned(1, s_burstCount'length);
            end if;
            if v_bend then
              if v_blst then
                s_state <= Idle;
              else
                s_state <= FillWait;
              end if;
            else
                s_state <= Fill;
            end if;

          when Fill =>
            if v_beat then
              s_burstCount <= s_burstCount - to_unsigned(1, s_burstCount'length);
            end if;
            if v_bend then
              if v_blst then
                s_state <= Idle;
              elsif v_qval then
                s_burstCount <= s_queueBurstCount;
                s_burstLast <= s_queueBurstLast;
                s_state <= FillConsume;
              else
                s_state <= FillWait;
              end if;
            end if;

          when FillWait =>
            if v_qval then
              s_burstCount <= s_queueBurstCount;
              s_burstLast <= s_queueBurstLast;
              s_state <= FillConsume;
            end if;

        end case;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Register Access
  -----------------------------------------------------------------------------
  ao_reg_sm.ready <= so_reg_sm_ready;
  process (ai_clk)
    -- variable v_portAddr : integer range 0 to 2**ai_reg_ms.addr'length-1;
    variable v_portAddr : integer range 0 to 3;
  begin
    if ai_clk'event and ai_clk = '1' then
      v_portAddr := to_integer(f_resize(ai_reg_ms.addr, 2));

      if ai_rst_n = '0' then
        ao_reg_sm.rddata <= (others => '0');
        so_reg_sm_ready <= '0';
        s_regAdr <= (others => '0');
        s_regCnt <= (others => '0');
        s_regBst <= (others => '0');
      else
        if ai_reg_ms.valid = '1' and so_reg_sm_ready = '0' then
          so_reg_sm_ready <= '1';
          case v_portAddr is
            when 0 =>
              ao_reg_sm.rddata <= a_regALo;
              if ai_reg_ms.wrnotrd = '1' then
                a_regALo <= f_byteMux(ai_reg_ms.wrstrb, a_regALo, ai_reg_ms.wrdata);
              end if;
            when 1 =>
              ao_reg_sm.rddata <= a_regAHi;
              if ai_reg_ms.wrnotrd = '1' then
                a_regAHi <= f_byteMux(ai_reg_ms.wrstrb, a_regAHi, ai_reg_ms.wrdata);
              end if;
            when 2 =>
              ao_reg_sm.rddata <= s_regCnt;
              if ai_reg_ms.wrnotrd = '1' then
                s_regCnt <= f_byteMux(ai_reg_ms.wrstrb, s_regCnt, ai_reg_ms.wrdata);
              end if;
            when 3 =>
              ao_reg_sm.rddata <= s_regBst;
              if ai_reg_ms.wrnotrd = '1' then
                s_regBst <= f_byteMux(ai_reg_ms.wrstrb, s_regBst, ai_reg_ms.wrdata);
              end if;
            when others =>
              ao_reg_sm.rddata <= (others => '0');
          end case;
        else
          so_reg_sm_ready <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Status Output
  -----------------------------------------------------------------------------
  with s_state select s_stateEnc <=
    "000" when Idle,
    "001" when Thru,
    "011" when ThruConsume,
    "010" when ThruWait,
    "101" when Fill,
    "111" when FillConsume,
    "110" when FillWait;
  s_status <= s_burstLast & s_stateEnc & f_resize(s_burstCount, 8) & s_addrStatus;

end Writer;
