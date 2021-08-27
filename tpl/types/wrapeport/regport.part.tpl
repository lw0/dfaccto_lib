{{.x_wrapname}}_addr    : {{.mode_ms}} std_logic_vector({{.type.x_taddr.x_width}}-1 downto 0);
{{.x_wrapname}}_wrdata  : {{.mode_ms}} std_logic_vector({{.type.x_tdata.x_width}}-1 downto 0);
{{.x_wrapname}}_wrstrb  : {{.mode_ms}} std_logic_vector({{.type.x_tstrb.x_width}}-1 downto 0);
{{.x_wrapname}}_wrnotrd : {{.mode_ms}} std_logic;
{{.x_wrapname}}_valid   : {{.mode_ms}} std_logic;
{{.x_wrapname}}_rddata  : {{.mode_sm}} std_logic_vector({{.type.x_tdata.x_width}}-1 downto 0);
{{.x_wrapname}}_ready   : {{.mode_sm}} std_logic
