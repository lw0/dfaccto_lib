{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}


architecture CtrlRegDemux of {{identifier}} is

  alias ag_Ports is {{x_gports.identifier}};

  alias ai_clk is {{x_psys.identifier}}.clk;
  alias ai_rst_n is {{x_psys.identifier}}.rst_n;

  alias ai_axiAwAddr  is {{x_paxi.identifier_ms}}.awaddr;
  alias ai_axiAwValid is {{x_paxi.identifier_ms}}.awvalid;
  alias ai_axiWData   is {{x_paxi.identifier_ms}}.wdata;
  alias ai_axiWStrb   is {{x_paxi.identifier_ms}}.wstrb;
  alias ai_axiWValid  is {{x_paxi.identifier_ms}}.wvalid;
  alias ai_axiBReady  is {{x_paxi.identifier_ms}}.bready;
  alias ai_axiArAddr  is {{x_paxi.identifier_ms}}.araddr;
  alias ai_axiArValid is {{x_paxi.identifier_ms}}.arvalid;
  alias ai_axiRReady  is {{x_paxi.identifier_ms}}.rready;
  alias ao_axiAwReady is {{x_paxi.identifier_sm}}.awready;
  alias ao_axiWReady  is {{x_paxi.identifier_sm}}.wready;
  alias ao_axiBResp   is {{x_paxi.identifier_sm}}.bresp;
  alias ao_axiBValid  is {{x_paxi.identifier_sm}}.bvalid;
  alias ao_axiArReady is {{x_paxi.identifier_sm}}.arready;
  alias ao_axiRData   is {{x_paxi.identifier_sm}}.rdata;
  alias ao_axiRResp   is {{x_paxi.identifier_sm}}.rresp;
  alias ao_axiRValid  is {{x_paxi.identifier_sm}}.rvalid;
  alias ac_AxiRespOk  is {{x_paxi.type.x_tresp.x_cokay.qualified}};

  alias ao_ports_ms is {{x_pports.identifier_ms}};
  alias ai_ports_sm is {{x_pports.identifier_sm}};

  subtype at_AxiAddr is {{x_paxi.type.x_taddr.qualified}};
  subtype at_RegAddr is {{x_pports.type.x_taddr.qualified}};
  subtype at_RegData is {{x_pports.type.x_tdata.qualified}};
  subtype at_RegStrb is {{x_pports.type.x_tstrb.qualified}};

  alias ac_RegAddrNull is {{x_pports.type.x_taddr.x_cnull.qualified}};
  alias ac_RegDataNull is {{x_pports.type.x_tdata.x_cnull.qualified}};
  alias ac_RegStrbNull is {{x_pports.type.x_tstrb.x_cnull.qualified}};

  subtype t_PortId is integer range ag_Ports'range;

  type t_DecodedAddr is record
    valid : boolean;
    id    : t_PortId;
    addr  : at_RegAddr;
  end record;
  constant c_DecodedAddrNull : t_DecodedAddr
            := (valid => false,
                id => 0,
                addr => ac_RegAddrNull);

  function f_decodeAddr(v_absAddr : at_AxiAddr) return t_DecodedAddr is
    -- variable v_idx : t_PortNumber;
    variable v_portOffset : at_AxiAddr;
    variable v_portCount : at_AxiAddr;
    variable v_portAddr  : at_AxiAddr;
    variable v_resPort   : t_PortId;
    variable v_resAddr   : at_RegAddr;
    variable v_guard : boolean;
  begin
    v_guard := false;
    v_resPort := 0;
    v_resAddr := ac_RegAddrNull;
    for v_idx in ag_Ports'range loop
      v_portOffset := to_unsigned(ag_Ports(v_idx).offset, at_AxiAddr'length);
      v_portCount := to_unsigned(ag_Ports(v_idx).count, at_AxiAddr'length);
      v_portAddr := v_absAddr - v_portOffset;
      if v_absAddr >= v_portOffset and v_portAddr < v_portCount and not v_guard then
        v_guard := true;
        v_resPort := v_idx;
        v_resAddr := f_resize(v_portAddr, at_RegAddr'length, f_clog2(at_RegData'length / 8));
      end if;
    end loop;
    return (valid => v_guard,
            id => v_resPort,
            addr => v_resAddr);
  end f_decodeAddr;

  type t_State is (Idle, WriteInit, WriteWait, WriteAck, ReadInit, ReadWait, ReadAck);
  signal s_state : t_State;

  signal s_regAddr : t_DecodedAddr;
  signal s_regWrData : at_RegData;
  signal s_regWrStrb : at_RegStrb;
  signal s_regWrNotRd : std_logic;
  signal s_regValid : std_logic;
  signal s_regRdData : at_RegData;
  signal s_regReady : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Axi to RegPort Conversion State Machine
  -----------------------------------------------------------------------------

  process (ai_clk)
  begin
    if ai_clk'event and ai_clk = '1' then
      if ai_rst_n = '0' then
        s_state <= Idle;
        s_regAddr <= c_DecodedAddrNull;
        s_regWrData <= ac_RegDataNull;
        s_regWrStrb <= ac_RegStrbNull;
        ao_axiRData <= (others => '0'); -- TODO-lw
      else
        case s_state is

          when Idle =>
            if ai_axiAwValid = '1' and ai_axiWValid = '1' then
              s_regAddr <= f_decodeAddr(ai_axiAwAddr);
              s_regWrData <= ai_axiWData;
              s_regWrStrb <= ai_axiWStrb;
              s_state <= WriteInit;
            elsif ai_axiArValid = '1' then
              s_regAddr <= f_decodeAddr(ai_axiArAddr);
              s_state <= ReadInit;
            end if;

          when WriteInit =>
            if s_regReady = '1' then
              s_state <= WriteAck;
            else
              s_state <= WriteWait;
            end if;

          when WriteWait =>
            if s_regReady = '1' then
              s_state <= WriteAck;
            end if;

          when WriteAck =>
            if ai_axiBReady = '1' then
              if ai_axiArValid = '1' then
                s_regAddr <= f_decodeAddr(ai_axiArAddr);
                s_state <= ReadInit;
              elsif ai_axiAwValid = '1' and ai_axiWValid = '1' then
                s_regAddr <= f_decodeAddr(ai_axiAwAddr);
                s_regWrData <= ai_axiWData;
                s_regWrStrb <= ai_axiWStrb;
                s_state <= WriteInit;
              else
                s_state <= Idle;
              end if;
            end if;

          when ReadInit =>
            if s_regReady = '1' then
              ao_axiRData <= s_regRdData;
              s_state <= WriteAck;
            else
              s_state <= WriteWait;
            end if;

          when ReadWait =>
            if s_regReady = '1' then
              ao_axiRData <= s_regRdData;
              s_state <= WriteAck;
            end if;

          when ReadAck =>
            if ai_axiRReady = '1' then
              if ai_axiAwValid = '1' and ai_axiWValid = '1' then
                s_regAddr <= f_decodeAddr(ai_axiAwAddr);
                s_regWrData <= ai_axiWData;
                s_regWrStrb <= ai_axiWStrb;
                s_state <= WriteInit;
              elsif ai_axiArValid = '1' then
                s_regAddr <= f_decodeAddr(ai_axiArAddr);
                s_state <= ReadInit;
              else
                s_state <= Idle;
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;

  with s_state select ao_axiAwReady <=
    '1' when WriteInit,
    '0' when others;
  with s_state select ao_axiWReady <=
    '1' when WriteInit,
    '0' when others;
  with s_state select ao_axiBValid <=
    '1' when WriteAck,
    '0' when others;
  with s_state select ao_axiArReady <=
    '1' when ReadInit,
    '0' when others;
  with s_state select ao_axiRValid <=
    '1' when ReadAck,
    '0' when others;
  ao_axiBResp    <= ac_AxiRespOk;
  ao_axiRResp    <= ac_AxiRespOk;

  with s_state select s_regWrNotRd <=
    '1' when WriteInit,
    '1' when WriteWait,
    '0' when others;
  with s_state select s_regValid <=
    '1' when WriteInit,
    '1' when WriteWait,
    '1' when ReadInit,
    '1' when ReadWait,
    '0' when others;


  -----------------------------------------------------------------------------
  -- Port Demultiplexer
  -----------------------------------------------------------------------------

  i_PortDemux : for v_idx in ag_Ports'range generate
    ao_ports_ms(v_idx).addr <= s_regAddr.addr;
    ao_ports_ms(v_idx).wrdata <= s_regWrData;
    ao_ports_ms(v_idx).wrstrb <= s_regWrStrb;
    ao_ports_ms(v_idx).wrnotrd <= s_regWrNotRd;
    ao_ports_ms(v_idx).valid <= s_regValid when s_regAddr.valid and s_regAddr.id = v_idx else '0';
  end generate;
  -- absent registers always read as zero and ignore writes
  s_regRdData <= ai_ports_sm(s_regAddr.id).rddata when s_regAddr.valid else ac_RegDataNull;
  s_regReady <= ai_ports_sm(s_regAddr.id).ready when s_regAddr.valid else '1';

end CtrlRegDemux;
