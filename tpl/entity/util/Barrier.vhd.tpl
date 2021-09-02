{{>vhdl/dependencies.part.tpl}}

use work.{{x_util.identifier}}.all;


entity {{identifier}} is
  generic (
    g_Count : positive);
  port (
    pi_clk     : in  std_logic;
    pi_rst_n   : in  std_logic;

    pi_signal  : in  unsigned (g_Count-1 downto 0);
    po_mask    : out unsigned (g_Count-1 downto 0);

    po_continue : out std_logic);
end {{identifier}};

architecture Barrier of {{identifier}} is

  signal s_mask : unsigned (g_Count-1 downto 0);
  signal s_continue : std_logic;

begin

  s_continue <= f_and(s_mask or pi_signal);

  process (pi_clk)
  begin
    if pi_clk'event and pi_clk = '1' then
      if pi_rst_n = '0' or s_continue = '1' then
        s_mask <= (others => '0');
      else
        s_mask <= s_mask or pi_signal;
      end if;
    end if;
  end process;

  po_continue <= s_continue;
  po_mask <= s_mask;

end Barrier;
