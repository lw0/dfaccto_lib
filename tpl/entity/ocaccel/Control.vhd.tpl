{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture ActionControl of {{identifier}} is

  constant c_RegCount : natural := 8;
  -- Register Map: (3bit / 8Regs)
  --  R0: Control (start, ready, ...)
  --      31..4 0-: Reserved | 3 R-: Ready | 2 R-: Idle | 1 R-: Done | 0 RW: Start
  --  R1: Interrupt Enable
  --      31..1 RW: Enable Ext Intr 30..0 | 0 RW: Enable Ready Intr
  --  R3: Interrupt Handle Index
  --      31..5 0-: Reserved | 4..0: RW Interrupt Handle Index (controls R6:R5 access)
  --  R3: Cycle Counter
  --      31..0 R-: Running Cycles (counting from start to ready)
  --  R4: Action Type
  --      31..0 R-: Action Type
  --  R5: Action Version
  --      31..0 R-: Action Version
  --  R6: Interrupt Handle Buffer Low
  --      31..0 RW: Interrupt Handle [index R3] Bits 31..0
  --  R7: Interrupt Handle High
  --      31..0 RW: Interrupt Handle [index R3] Bits 63..32

  subtype at_RegData is {{x_preg.type.x_tdata.qualified}};
  subtype at_RegData_v is {{x_preg.type.x_tdata.qualified_v}};

  constant c_StartCount : natural := {{x_gscount.identifier}};
  subtype t_StartVector is unsigned (c_StartCount  -1 downto 0);

  constant c_IrqCount : natural := {{x_gicount.identifier}} + 1;
  -- assert c_IrqCount <= at_RegData'length
  --   report "Can not handle more interrupts than there are bits in a register"
  --   severity error;
  subtype t_IrqVector  is unsigned (c_IrqCount-1 downto 0);
  subtype t_IrqIndex   is unsigned (f_clog2(c_IrqCount)-1 downto 0);
  subtype t_IrqHandle  is {{x_pintr.type.x_tsdata.qualified}};
  type    t_IrqHandles is array (2**f_clog2(c_irqCount)-1 downto 0) of {{x_pintr.type.x_tsdata.qualified}};

  constant c_ActionType : at_RegData := to_unsigned({{x_gactyp.identifier}}, at_RegData'length);
  constant c_ActionVersion : at_RegData := to_unsigned({{x_gacver.identifier}}, at_RegData'length);

  alias ai_sys        is {{x_psys.identifier}};
  alias ai_clk        is {{x_psys.identifier}}.clk;
  alias ai_rst_n      is {{x_psys.identifier}}.rst_n;
  alias ai_reg_ms     is {{x_preg.identifier_ms}};
  alias ao_reg_sm     is {{x_preg.identifier_sm}};
  alias ao_intrStb    is {{x_pintr.identifier_ms}}.stb;
  alias ao_intrHandle is {{x_pintr.identifier_ms}}.sdata;
  alias ai_intrAck    is {{x_pintr.identifier_sm}}.ack;
  -- alias ao_start_v    is {{x_pstart.identifier_ms}}.stb;
  -- alias ai_ready_v    is {{x_pstart.identifier_sm}}.ack;
  -- alias ai_irq_v      is {{x_pirq.identifier_ms}}.stb;
  -- alias ao_iack_v     is {{x_pirq.identifier_sm}}.ack;
  alias ao_start_ms   is {{x_pstart.identifier_ms}};
  alias ai_start_sm   is {{x_pstart.identifier_sm}};
  alias ai_irq_ms     is {{x_pirq.identifier_ms}};
  alias ao_irq_sm     is {{x_pirq.identifier_sm}};


  -- Action Logic
  signal s_ready_v : t_StartVector;
  signal s_startMask_v : t_StartVector;
  signal s_start          : std_logic;
  signal s_ready          : std_logic;
  type t_ActState is (Idle, Started, ReadyIrq, Ready);
  signal s_actState          : t_ActState;
  signal s_irqDone        : std_logic;

  -- Interrupt Logic
  signal s_irq            : t_IrqVector;
  signal s_irqLatch       : t_IrqVector;
  signal s_irqMasked      : t_IrqVector;
  signal s_iack           : t_IrqVector;

  signal s_irqActive      : std_logic;
  signal s_irqActiveIdx   : t_IrqIndex;
  signal s_irqRegIdx      : t_IrqIndex;
  signal s_irqHandles     : t_IrqHandles;

  type t_IrqState is (Idle, IrqStrobe, IackWait);
  signal s_irqState : t_IrqState;

  -- Control Registers
  signal s_rdValues    : at_RegData_v (c_RegCount-1 downto 0);
  signal s_wrValues    : at_RegData_v (c_RegCount-1 downto 0);
  signal s_rdEvents    : unsigned (c_RegCount-1 downto 0);
  signal s_wrEvents    : unsigned (c_RegCount-1 downto 0);
  signal s_regC        : at_RegData; -- R  Control
  signal s_regIE       : at_RegData; --    Interrupt Enable
  signal s_regII       : at_RegData; --    Interrupt Handle Index
  signal s_regT        : at_RegData; -- RO Running Cycle Counter
  signal s_regIHL      : at_RegData; -- R  Interrupt Handle Low
  signal s_regIHH      : at_RegData; -- R  Interrupt Handle High
  signal s_regC_wr     : at_RegData; -- W  Control
  signal s_regIHL_wr   : at_RegData; -- W  Interrupt Handle Low
  signal s_regIHH_wr   : at_RegData; -- W  Interrupt Handle High
  signal s_regC_rdev   : std_logic;
  signal s_regC_wrev   : std_logic;
  signal s_regIHL_wrev : std_logic;
  signal s_regIHH_wrev : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Action Handshake Logic

  i_startBarrier : entity work.{{x_ebarrier.identifier}}
    generic map (
      g_count => c_StartCount)
    port map (
      pi_clk => ai_clk,
      pi_rst_n => ai_rst_n,
      pi_signal => s_ready_v,
      po_mask => s_startMask_v,
      po_continue => s_ready);
  -- ao_start_v(v_idx) <= s_startMask_v and (c_StartCount-1 downto 0 => s_start);
  i_startMask : for v_idx in 0 to c_StartCount-1 generate
    s_ready_v(v_idx) <= ai_start_sm(v_idx).ack;
    ao_start_ms(v_idx).stb <= s_start and not s_startMask_v(v_idx);
  end generate;

  -- ready,    idle,     done,     start
  with s_actState select s_regC <=
    (3 => '0', 2 => '1', 1 => '0', 0 => '0', others => '0') when Idle,
    (3 => '0', 2 => '0', 1 => '0', 0 => '1', others => '0') when Started,
    (3 => '1', 2 => '1', 1 => '1', 0 => '0', others => '0') when ReadyIrq,
    (3 => '1', 2 => '1', 1 => '1', 0 => '0', others => '0') when Ready;
  with s_actState select s_irqDone <=
    '1' when ReadyIrq,
    '0' when others;

  process (ai_clk)
  begin
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_actState <= Idle;
        s_regT <= (others => '0');
      else
        case s_actState is
          when Idle =>
            if s_regC_wrev = '1' and s_regC_wr(0) = '1' then
              s_actState <= Started;
              s_regT <= (others => '0');
            end if;
          when Started =>
            if s_ready = '1' then
              s_actState <= ReadyIrq;
              s_regT <= s_regT + to_unsigned(1, s_regT'length);
            end if;
          when ReadyIrq =>
            if s_regC_rdev = '1' then
              s_actState <= Idle;
            else
              s_actState <= Ready;
            end if;
          when Ready =>
            if s_regC_rdev = '1' then
              s_actState <= Idle;
            end if;
        end case;
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Interrupt Logic

  i_irqPortLogic : for v_idx in 0 to c_IrqCount-1 generate
    i_irqPortLogicInt : if v_idx = 0 generate
      s_irq(v_idx) <= s_irqDone;
      -- Ignore s_iack(0), as done interrupt acknowledge is never waited for
    end generate;
    i_irqPortLogicExt : if v_idx /= 0 generate
      s_irq(v_idx) <= ai_irq_ms(v_idx - 1).stb;
      ao_irq_sm(v_idx-1).ack <= s_iack(v_idx);
    end generate;
  end generate;

  process (ai_clk)
  begin
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_irqLatch <= (others => '0');
      else
        s_irqLatch <= (s_irqLatch or s_irq) and not s_iack;
      end if;
    end if;
  end process;
  s_irqMasked <= s_irqLatch and f_resize(s_regIE, t_IrqVector'length);

  i_arbiter : entity work.{{x_earbiter.identifier}}
    generic map (
      g_PortCount => c_IrqCount)
    port map (
      pi_clk      => ai_clk,
      pi_rst_n    => ai_rst_n,
      pi_request  => s_irqMasked,
      po_port     => s_irqActiveIdx,
      po_valid    => s_irqActive,
      pi_ready    => ai_intrAck);

  ao_intrHandle <= s_irqHandles(to_integer(s_irqActiveIdx));
  with s_irqState select ao_intrStb <=
    '1' when IrqStrobe,
    '0' when others;

  i_iackDemux : for v_idx in 0 to c_IrqCount-1 generate
    s_iack(v_idx) <= ai_intrAck when s_irqActive = '1' and to_integer(s_irqActiveIdx) = v_idx else '0';
  end generate;

  process (ai_clk)
  begin
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_irqState <= Idle;
      else
        case s_irqState is
          when Idle =>
            if s_irqActive = '1' then
              s_irqState <= IrqStrobe;
            end if;
          when IrqStrobe =>
            s_irqState <= IackWait;
          when IackWait =>
            if ai_intrAck = '1' then
              s_irqState <= Idle;
            end if;
        end case;
      end if;
    end if;
  end process;

  s_irqRegIdx <= f_resize(s_regII, t_IrqIndex'length);
  process (ai_clk)
  begin
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_irqHandles <= (others => (others => '0'));
      else
        if s_regIHH_wrev = '1' then
          s_irqHandles(to_integer(s_irqRegIdx))(2*at_RegData'length-1 downto at_RegData'length) <= s_regIHH_wr;
        elsif s_regIHL_wrev = '1' then
          s_irqHandles(to_integer(s_irqRegIdx))(at_RegData'length-1 downto 0) <= s_regIHL_wr;
        end if;
      end if;
    end if;
  end process;

  -- Control Register Access Logic

  s_rdValues(0) <= s_regC;
  s_rdValues(1) <= s_regIE;
  s_rdValues(2) <= s_regII;
  s_rdValues(3) <= s_regT;
  s_rdValues(4) <= c_ActionType;
  s_rdValues(5) <= c_ActionVersion;
  s_rdValues(6) <= s_regIHL;
  s_rdValues(7) <= s_regIHH;
  s_regC_wr <= s_wrValues(0);
  s_regIE <= s_wrValues(1);
  s_regII <= s_wrValues(2);
  s_regIHL_wr <= s_wrValues(6);
  s_regIHH_wr <= s_wrValues(7);
  s_regC_rdev <= s_rdEvents(0);
  s_regC_wrev <= s_wrEvents(0);
  s_regIHL_wrev <= s_wrEvents(6);
  s_regIHH_wrev <= s_wrEvents(7);

  i_regFile : entity work.{{x_eregfile.identifier}}
    generic map (
      g_RegCount => c_RegCount)
    port map (
      pi_sys => ai_sys,
      pi_reg_ms => ai_reg_ms,
      po_reg_sm => ao_reg_sm,
      pi_rdValues => s_rdValues,
      po_wrValues => s_wrValues,
      po_rdEvents => s_rdEvents,
      po_wrEvents => s_wrEvents);

end ActionControl;
