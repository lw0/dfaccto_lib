{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


entity {{identifier}} is
  generic (
    g_WordAddrWidth    : positive;
    g_BurstCountWidth  : positive;
    g_BurstLengthWidth : positive;
    g_Boundary         : natural;
    g_FIFOLogDepth     : natural);
  port (
    pi_clk             : in  std_logic;
    pi_rst_n           : in  std_logic;

    -- operation is started when both start and ready are asserted
    pi_start           : in  std_logic;
    po_ready           : out std_logic;
    -- while asserted, no new burst will be started
    pi_hold            : in  std_logic := '0';
    -- if asserted, no new burst will be inserted into the queue
    pi_abort           : in  std_logic := '0';

    pi_address         : in  unsigned (g_WordAddrWidth-1 downto 0);
    pi_count           : in  unsigned (g_BurstCountWidth-1 downto 0);
    pi_maxLen          : in  unsigned (g_BurstLengthWidth-1 downto 0);

    po_axiAAddr        : out unsigned (g_WordAddrWidth-1 downto 0);
    po_axiALen         : out unsigned (g_BurstLengthWidth-1 downto 0);
    po_axiAValid       : out std_logic;
    pi_axiAReady       : in  std_logic;

    po_queueBurstCount : out unsigned (g_BurstLengthWidth-1 downto 0);
    po_queueBurstLast  : out std_logic;
    po_queueValid      : out std_logic;
    pi_queueReady      : in  std_logic;

    po_status          : out unsigned(7 downto 0));
end {{identifier}};


architecture AddrMachine of {{identifier}} is

  -- TODO-lw consider and adapt to cases where BurstLength is wider than BurstCount or WordAddr

  subtype t_WordAddr is unsigned (g_WordAddrWidth-1 downto 0);
  subtype t_BurstCount is unsigned (g_BurstCountWidth-1 downto 0);
  subtype t_BurstLength is unsigned (g_BurstLengthWidth-1 downto 0);

  function f_bitsSetAbove(v_vector : unsigned; v_width : natural) return boolean is
  begin
    if v_width < v_vector'length then
      return f_bool(f_or(f_resize(v_vector, v_vector'length - v_width, v_width)));
    else
      return false;
    end if;
  end f_bitsSetAbove;

  type t_BurstParam is record
    length : t_BurstLength;
    last : std_logic;
  end record;

  subtype t_BurstParamPacked is unsigned((t_BurstLength'length + 1)-1 downto 0);

  function f_packBurstParam(unpacked : t_BurstParam) return t_BurstParamPacked is
    variable v_result : t_BurstParamPacked;
  begin
    v_result(t_BurstLength'length) := unpacked.last;
    v_result(t_BurstLength'length-1 downto 0) := unpacked.length;
    return v_result;
  end f_packBurstParam;

  function f_unpackBurstParam(packed : t_BurstParamPacked) return t_BurstParam is
    variable v_result : t_BurstParam;
  begin
    v_result.last := packed(t_BurstLength'length);
    v_result.length := packed(t_BurstLength'length-1 downto 0);
    return v_result;
  end f_unpackBurstParam;

  function f_calcBurstParam(v_count : t_BurstCount; v_addr : t_WordAddr; v_maxBurst : t_BurstLength) return t_BurstParam is
    constant c_BoundMask : t_WordAddr := to_unsigned(2**g_Boundary-1, t_WordAddr'length);--(g_Boundary-1 downto 0 => '1', others => '0');
    variable v_maxBound_raw : t_WordAddr;
    variable v_maxBound : t_BurstLength;
    variable v_maxCount_raw : t_BurstCount;
    variable v_maxCount : t_BurstLength;
    variable v_countExceeds : boolean;
    variable v_curLength : t_BurstLength;
  begin
    -- Maximum burstlength (wordcount - 1) before crossing the boundary
    --  calculated as ones-complement of the address bits within boundary
    v_maxBound_raw := not v_addr and c_BoundMask;
    if f_bitsSetAbove(v_maxBound_raw, t_BurstLength'length) then
      v_maxBound := (others => '1');
    else
      v_maxBound := f_resize(v_maxBound_raw, t_BurstLength'length);
    end if;

    -- Maximum burstlength (wordcount - 1) before exceeding v_count
    v_maxCount_raw := v_count - 1;
    v_countExceeds := f_bitsSetAbove(v_maxCount_raw, t_BurstLength'length);
    if v_countExceeds then
      v_maxCount := (others => '1');
    else
      v_maxCount := f_resize(v_maxCount_raw, t_BurstLength'length);
    end if;

    -- Calculate minimum static limit
    if v_maxBound >= v_maxBurst then
      v_curLength := v_maxBurst;
    else
      v_curLength := v_maxBound;
    end if;

    -- Compare dynamic limit and return minimum
    if v_curLength >= v_maxCount then
      return (length => v_maxCount,
              last => not f_logic(v_countExceeds));
    else
      return (length => v_curLength,
              last => '0');
    end if;
  end f_calcBurstParam;

  signal so_ready         : std_logic;

  signal s_nextBurst : t_BurstParam;
--  signal s_nextBurstCount : t_BurstLength;
--  signal s_nextBurstLast  : std_logic;
--  signal s_nextBurstParam : t_BurstParamPacked;
  signal s_nextAddress    : t_WordAddr;
  signal s_nextCount      : t_BurstCount;
  signal s_nextBurstReq   : std_logic;

  -- Address State Machine
  type t_State is (Idle, ReqInit, Init, WaitBurst, ReqWaitAWaitF, WaitAWaitF, DoneAWaitF, WaitADoneF, WaitAWaitFLast, DoneAWaitFLast, WaitADoneFLast);
  signal s_state          : t_State;
  signal s_address        : t_WordAddr;
  signal s_count          : t_BurstCount;
  signal s_maxLen         : t_BurstLength; -- maximum burst length - 1 (range 1 to 64)

  -- Burst Length Queue
  signal s_qWrBurstParam     : t_BurstParam;
  signal s_qWrBurstParamPacked     : t_BurstParamPacked;
  signal s_qWrValid          : std_logic;
  signal s_qWrReady          : std_logic;
  signal s_qRdBurstParamPacked     : t_BurstParamPacked;
  signal s_qRdValid          : std_logic;
  signal s_qRdReady          : std_logic;

  -- Status Output
  signal s_stateEnc : unsigned (3 downto 0);

begin

  so_ready <= f_logic(s_state = Idle);
  po_ready <= so_ready;

  -----------------------------------------------------------------------------
  -- Next Burst Parameter Generator
  -----------------------------------------------------------------------------
--  process (pi_clk)
--    constant c_MaxBurstLen : t_BurstLength := (others => '1');
--    variable v_addrFill : t_BurstLength;
--    variable v_countDec : t_BurstCount;
--    variable v_countFill : t_BurstLength;
--    variable v_nextBurstCount : t_BurstLength;
--    variable v_nextBurstLast : std_logic;
--  begin
--    if pi_clk'event and pi_clk = '1' then
--      if s_nextBurstReq = '1' then
--        v_nextBurstCount := s_maxLen;
--        v_nextBurstLast := pi_abort;
--
--        -- inversion of address bits within boundary range
--        -- equals remaining words but one until boundary would be crossed
--        v_addrFill := f_resize(not s_address, v_addrFill'length);
--        if v_nextBurstCount > v_addrFill then
--          v_nextBurstCount := v_addrFill;
--        end if;
--
--        v_countDec := s_count - to_unsigned(1, v_countDec'length);
--        v_countFill := f_resize(v_countDec, v_countFill'length);
--        if v_countDec <= c_MaxBurstLen and v_nextBurstCount >= v_countFill then
--          v_nextBurstCount := v_countFill;
--          v_nextBurstLast := '1';
--        end if;
--
--        s_nextBurst.length <= v_nextBurstCount;
--        s_nextBurst.last <= v_nextBurstLast;
--      end if;
--    end if;
--  end process;
--  s_nextBurstParam <= s_nextBurst.last & s_nextBurst.length;

  process (pi_clk)
  begin
    if pi_clk'event and pi_clk = '1' then
      if s_nextBurstReq = '1' then
        s_nextBurst <= f_calcBurstParam(s_count, s_address, s_maxLen);
      end if;
    end if;
  end process;
  s_nextAddress <= s_address + f_resize(s_nextBurst.length, s_address'length) +
                    to_unsigned(1, s_address'length);
  s_nextCount <= s_count - f_resize(s_nextBurst.length, s_nextCount'length) -
                    to_unsigned(1, s_nextCount'length);

  -----------------------------------------------------------------------------
  -- Address State Machine
  -----------------------------------------------------------------------------
  with s_state select s_nextBurstReq <=
    '1' when ReqInit,
    '1' when ReqWaitAWaitF,
    '0' when others;

  process (pi_clk)
    variable v_strt : boolean; -- Start Condition
    variable v_hold : boolean; -- Hold Signal
    variable v_ardy : boolean; -- Write Address Channel Ready
    variable v_qrdy : boolean; -- Burst Length Queue Ready
    variable v_last : boolean; -- Next is the last Burst
  begin
    if pi_clk'event and pi_clk = '1' then
      v_strt := pi_start = '1' and so_ready = '1';
      v_hold := pi_hold = '1';
      v_ardy := pi_axiAReady = '1';
      v_qrdy := s_qWrReady = '1';
      v_last := s_nextBurst.last = '1';

      if pi_rst_n = '0' then
        po_axiAAddr       <= (others => '0');
        po_axiALen        <= (others => '0');
        po_axiAValid      <= '0';
        s_qWrBurstParam   <= (last => '0', length => (others => '0'));
        s_qWrValid        <= '0';
        s_address         <= (others => '0');
        s_count           <= (others => '0');
        s_maxLen          <= (others => '0');
        s_state           <= Idle;
      else
        case s_state is

          when Idle =>
            if v_strt then
              s_maxLen  <= pi_maxLen;
              s_address <= pi_address;
              s_count   <= pi_count;
              s_state   <= ReqInit;
            end if;

          when ReqInit =>
            if s_count = to_unsigned(0, s_count'length) then
              s_state   <= Idle;
            else
              s_state   <= Init;
            end if;

          when Init =>
            if v_hold then
              s_state         <= WaitBurst;
            else
              po_axiAAddr     <= f_resizeLeft(s_address, po_axiAAddr'length);
              po_axiALen      <= f_resize(s_nextBurst.length, po_axiALen'length);
              po_axiAValid    <= '1';

              s_qWrBurstParam <= s_nextBurst;
              s_qWrValid      <= '1';

              s_address       <= s_nextAddress;
              s_count         <= s_nextCount;
              if v_last then
                s_state       <= WaitAWaitFLast;
              else
                s_state       <= ReqWaitAWaitF;
              end if;
            end if;

          when WaitBurst =>
            if not v_hold then
              po_axiAAddr     <= f_resizeLeft(s_address, po_axiAAddr'length);
              po_axiALen      <= f_resize(s_nextBurst.length, po_axiALen'length);
              po_axiAValid    <= '1';

              s_qWrBurstParam <= s_nextBurst;
              s_qWrValid      <= '1';

              s_address       <= s_nextAddress;
              s_count         <= s_nextCount;
              if v_last then
                s_state       <= WaitAWaitFLast;
              else
                s_state       <= ReqWaitAWaitF;
              end if;
            end if;

          when ReqWaitAWaitF =>
            if v_ardy and v_qrdy then
              po_axiAValid      <= '0';
              s_qWrValid        <= '0';
              s_state <= WaitBurst;
            elsif v_ardy then
              po_axiAValid      <= '0';
              s_state           <= DoneAWaitF;
            elsif v_qrdy then
              s_qWrValid        <= '0';
              s_state           <= WaitADoneF;
            else
              s_state           <= WaitAWaitF;
            end if;

          when WaitAWaitF =>
            if v_ardy and v_qrdy then
              po_axiAValid      <= '0';
              s_qWrValid        <= '0';
              if v_hold then
                s_state         <= WaitBurst;
              else
                po_axiAAddr     <= f_resizeLeft(s_address, po_axiAAddr'length);
                po_axiALen      <= f_resize(s_nextBurst.length, po_axiALen'length);
                po_axiAValid    <= '1';

                s_qWrBurstParam <= s_nextBurst;
                s_qWrValid      <= '1';

                s_address       <= s_nextAddress;
                s_count         <= s_nextCount;
                if v_last then
                  s_state       <= WaitAWaitFLast;
                else
                  s_state       <= ReqWaitAWaitF;
                end if;
              end if;
            elsif v_ardy then
              po_axiAValid      <= '0';
              s_state           <= DoneAWaitF;
            elsif v_qrdy then
              s_qWrValid        <= '0';
              s_state           <= WaitADoneF;
            end if;

          when WaitADoneF =>
            if v_ardy then
              po_axiAValid      <= '0';
              if v_hold then
                s_state         <= WaitBurst;
              else
                po_axiAAddr     <= f_resizeLeft(s_address, po_axiAAddr'length);
                po_axiALen      <= f_resize(s_nextBurst.length, po_axiALen'length);
                po_axiAValid    <= '1';

                s_qWrBurstParam <= s_nextBurst;
                s_qWrValid      <= '1';

                s_address       <= s_nextAddress;
                s_count         <= s_nextCount;
                if v_last then
                  s_state       <= WaitAWaitFLast;
                else
                  s_state       <= ReqWaitAWaitF;
                end if;
              end if;
            end if;

          when DoneAWaitF =>
            if v_qrdy then
              s_qWrValid        <= '0';
              if v_hold then
                s_state         <= WaitBurst;
              else
                po_axiAAddr     <= f_resizeLeft(s_address, po_axiAAddr'length);
                po_axiALen      <= f_resize(s_nextBurst.length, po_axiALen'length);
                po_axiAValid    <= '1';

                s_qWrBurstParam <= s_nextBurst;
                s_qWrValid      <= '1';

                s_address       <= s_nextAddress;
                s_count         <= s_nextCount;
                if v_last then
                  s_state       <= WaitAWaitFLast;
                else
                  s_state       <= ReqWaitAWaitF;
                end if;
              end if;
            end if;

          when WaitAWaitFLast =>
            if v_ardy and v_qrdy then
              po_axiAValid      <= '0';
              s_qWrValid        <= '0';
              s_state           <= Idle;
            elsif v_ardy then
              po_axiAValid      <= '0';
              s_state           <= DoneAWaitFLast;
            elsif v_qrdy then
              s_qWrValid        <= '0';
              s_state           <= WaitADoneFLast;
            end if;

          when WaitADoneFLast =>
            if v_ardy then
              po_axiAValid      <= '0';
              s_state           <= Idle;
            end if;

          when DoneAWaitFLast =>
            if v_qrdy then
              s_qWrValid        <= '0';
              s_state           <= Idle;
            end if;

        end case;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Burst Length Queue
  -----------------------------------------------------------------------------
  s_qWrBurstParamPacked <= f_packBurstParam(s_qWrBurstParam);
  i_blenFIFO : entity work.{{x_efifo.identifier}}
    generic map (
      g_DataWidth => t_BurstParamPacked'length,
      g_LogDepth => g_FIFOLogDepth)
    port map (
      pi_clk => pi_clk,
      pi_rst_n => pi_rst_n,
      pi_inData => s_qWrBurstParamPacked,
      pi_inValid => s_qWrValid,
      po_inReady => s_qWrReady,
      po_outData => s_qRdBurstParamPacked,
      po_outValid => s_qRdValid,
      pi_outReady => s_qRdReady);
  po_queueBurstCount <= f_unpackBurstParam(s_qRdBurstParamPacked).length;
  po_queueBurstLast  <= f_unpackBurstParam(s_qRdBurstParamPacked).last;
  po_queueValid <= s_qRdValid;
  s_qRdReady <= pi_queueReady;

  -----------------------------------------------------------------------------
  -- Status Output
  -----------------------------------------------------------------------------
  with s_state select s_stateEnc <=
    "0000" when Idle,
    "0101" when ReqInit,
    "0001" when Init,
    "0010" when WaitBurst,
    "0111" when ReqWaitAWaitF,
    "1011" when WaitAWaitF,
    "1010" when DoneAWaitF,
    "1001" when WaitADoneF,
    "1111" when WaitAWaitFLast,
    "1110" when DoneAWaitFLast,
    "1101" when WaitADoneFLast;
  po_status <= s_qRdValid & s_qRdReady & s_qWrValid & s_qWrReady & s_stateEnc;

end AddrMachine;
