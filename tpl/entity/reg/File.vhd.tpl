{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


{{>vhdl/defentity.part.tpl}}

architecture RegFile of {{identifier}} is

  alias ag_Count    is {{x_gcount.identifier}};
  constant c_AddrBits : natural := f_clog2(ag_Count);
  constant c_AddrRange : natural := 2**c_AddrBits;

  alias ai_clk      is {{x_psys.identifier}}.clk;
  alias ai_rst_n    is {{x_psys.identifier}}.rst_n;

  alias ai_reg_ms   is {{x_preg.identifier_ms}};
  alias ao_reg_sm   is {{x_preg.identifier_sm}};

  alias ai_rdValues is {{x_prdval.identifier}};
  alias ao_wrValues is {{x_pwrval.identifier}};

  alias ao_rdEvent  is {{x_prdevt.identifier}};
  alias ao_wrEvent  is {{x_pwrevt.identifier}};
  alias ao_rdEvents is {{x_prdevts.identifier}};
  alias ao_wrEvents is {{x_pwrevts.identifier}};

  subtype at_RegData is {{x_preg.type.x_tdata.qualified}};
  subtype at_RegData_v is {{x_preg.type.x_tdata.qualified_v}};

  signal so_reg_sm_ready : std_logic;
  signal so_wrValues     : at_RegData_v (ag_Count-1 downto 0);

begin

  ao_reg_sm.ready <= so_reg_sm_ready;
  ao_wrValues <= so_wrValues;
  process (ai_clk)
    variable v_portAddr : integer range 0 to c_AddrRange-1;
  begin
    if ai_clk'event and ai_clk = '1' then
      v_portAddr := to_integer(f_resize(ai_reg_ms.addr, c_AddrBits));
      ao_rdEvent  <= '0';
      ao_wrEvent  <= '0';
      ao_rdEvents <= (others => '0');
      ao_wrEvents <= (others => '0');

      if ai_rst_n = '0' then
        ao_reg_sm.rddata <= (others => '0');
        so_reg_sm_ready <= '0';
        so_wrValues <= (others => (others => '0'));
      else
        if ai_reg_ms.valid = '1' and so_reg_sm_ready = '0' then
          if v_portAddr < g_RegCount then
            ao_reg_sm.rddata <= ai_rdValues(v_portAddr);
            if ai_reg_ms.wrnotrd = '1' then
              so_wrValues(v_portAddr) <= f_byteMux(ai_reg_ms.wrstrb, so_wrValues(v_portAddr), ai_reg_ms.wrdata);
              ao_wrEvents(v_portAddr) <= '1';
              ao_wrEvent <= '1';
            else
              ao_rdEvents(v_portAddr) <= '1';
              ao_rdEvent <= '1';
            end if;
          else
            ao_reg_sm.rddata <= (others => '0');
          end if;
          so_reg_sm_ready <= '1';
        else
          so_reg_sm_ready <= '0';
        end if;
      end if;
    end if;
  end process;

end RegFile;
