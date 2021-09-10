{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture Reader of {{identifier}} is

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
  alias ao_stm_ms is {{x_pstm.identifier_ms}};
  alias ai_stm_sm is {{x_pstm.identifier_sm}};
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

  signal s_arAddr              : at_AxiWordAddr;
  signal s_arLen               : at_AxiLen;
  signal s_arValid             : std_logic;
  signal s_arReady             : std_logic;

  -- Burst Count Queue
  signal s_queueBurstCount     : at_AxiLen;
  signal s_queueBurstLast      : std_logic;
  signal s_queueValid          : std_logic;
  signal s_queueReady          : std_logic;

  -- Data State Machine
  type t_State is (Idle, ThruConsume, Thru, ThruWait);
  signal s_state               : t_State;
  signal s_burstCount          : at_AxiLen;
  signal s_burstLast           : std_logic;
  signal so_axi_ms_rready      : std_logic;

  -- Control Registers
  signal so_reg_sm_ready       : std_logic;
  signal s_regAdr              : unsigned(2*at_RegData'length-1 downto 0);
  alias  a_regALo is s_regAdr(at_RegData'length-1 downto 0);
  alias  a_regAHi is s_regAdr(2*at_RegData'length-1 downto at_RegData'length);
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
  ao_axi_ms.araddr <= f_resizeLeft(s_arAddr, ao_axi_ms.araddr'length); -- word to byte address
  ao_axi_ms.arlen <= s_arLen;
  ao_axi_ms.arsize <= ac_AxiSizeFull;
  ao_axi_ms.arburst <= ac_AxiBurstIncr;
  ao_axi_ms.arvalid <= s_arValid;
  s_arReady <= ai_axi_sm.arready;

  s_cfgAddr  <= f_resizeLeft(s_regAdr, s_cfgAddr'length); -- byte to word address
  s_cfgCount <= s_regCnt;
  s_cfgMaxLen   <= f_resize(s_regBst, s_cfgMaxLen'length);
  i_addrMachine : entity work.{{x_eamach.identifier}}
    generic map (
      g_WordAddrWidth => at_AxiWordAddr'length,
      g_BurstLengthWidth => at_AxiLen'length,
      g_BurstCountWidth => at_RegData'length,
      g_Boundary => ac_AxiWordBound,
      g_FIFOLogDepth => ag_FifoLogDepth)
    port map (
      pi_clk             => ai_clk,
      pi_rst_n           => ai_rst_n,
      pi_start           => s_addrStart,
      po_ready           => s_addrReady,
      pi_hold            => ai_hold,
      pi_address         => s_cfgAddr,
      pi_count           => s_cfgCount,
      pi_maxLen          => s_cfgMaxLen,
      po_axiAAddr        => s_arAddr,
      po_axiALen         => s_arLen,
      po_axiAValid       => s_arValid,
      pi_axiAReady       => s_arReady,
      po_queueBurstCount => s_queueBurstCount,
      po_queueBurstLast  => s_queueBurstLast,
      po_queueValid      => s_queueValid,
      pi_queueReady      => s_queueReady,
      po_status          => s_addrStatus);

  -----------------------------------------------------------------------------
  -- Data State Machine
  -----------------------------------------------------------------------------

  ao_stm_ms.tdata <= ai_axi_sm.rdata;
  with s_state select ao_stm_ms.tkeep <=
    (others => '1')     when Thru,
    (others => '1')     when ThruConsume,
    (others => '0')     when others;
  ao_stm_ms.tlast <= f_logic(s_burstCount = to_unsigned(0, s_burstCount'length) and s_burstLast = '1');
  with s_state select ao_stm_ms.tvalid <=
    ai_axi_sm.rvalid    when Thru,
    ai_axi_sm.rvalid    when ThruConsume,
    '0'                 when others;
  with s_state select so_axi_ms_rready <=
    ai_stm_sm.tready when Thru,
    ai_stm_sm.tready when ThruConsume,
    '0'                 when others;
  ao_axi_ms.rready <= so_axi_ms_rready;
  -- TODO-lw: handle rresp /= OKAY

  with s_state select s_queueReady <=
    '1' when ThruConsume,
    '0' when others;

  process (ai_clk)
    variable v_beat : boolean; -- Data Channel Handshake
    variable v_bend : boolean; -- Last Data Channel Handshake in Burst
    variable v_blst : boolean; -- Last Burst
    variable v_qval : boolean; -- Queue Valid
  begin
    if ai_clk'event and ai_clk = '1' then
      v_beat := ai_axi_sm.rvalid = '1' and
                so_axi_ms_rready = '1';
      v_bend := (s_burstCount = to_unsigned(0, s_burstCount'length)) and
                ai_axi_sm.rvalid = '1' and
                so_axi_ms_rready = '1';
      v_blst := s_burstLast = '1';
      v_qval := s_queueValid = '1';

      if ai_rst_n = '0' then
        s_burstCount <= (others => '0');
        s_burstLast <= '0';
        s_state  <= Idle;
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
                s_state <= Idle;
              else
                s_state <= ThruWait;
              end if;
            else
                s_state <= Thru;
            end if;

          when Thru =>
            if v_beat then
              s_burstCount <= s_burstCount - to_unsigned(1, s_burstCount'length);
            end if;
            if v_bend then
              if v_blst then
                s_state <= Idle;
              elsif v_qval then
                s_burstCount <= s_queueBurstCount;
                s_burstLast <= s_queueBurstLast;
                s_state <= ThruConsume;
              else
                s_state <= ThruWait;
              end if;
            end if;

          when ThruWait =>
            if v_qval then
              s_burstCount <= s_queueBurstCount;
              s_burstLast <= s_queueBurstLast;
              s_state <= ThruConsume;
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
    variable v_portAddr : integer range 0 to 4;
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
    "010" when ThruWait;
  s_status <= s_burstLast & s_stateEnc & f_resize(s_burstCount, 8) & s_addrStatus;

end Reader;
