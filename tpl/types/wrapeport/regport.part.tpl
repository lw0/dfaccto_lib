{{.x_wrapname}}_addr    : {{.mode_ms}} std_logic_vector({{.type.x_tRegAddr.x_width}}-1 downto 0);
{{.x_wrapname}}_wrdata  : {{.mode_ms}} std_logic_vector({{.type.x_tRegData.x_width}}-1 downto 0);
{{.x_wrapname}}_wrstrb  : {{.mode_ms}} std_logic_vector({{.type.x_tRegStrb.x_width}}-1 downto 0);
{{.x_wrapname}}_wrnotrd : {{.mode_ms}} std_logic;
{{.x_wrapname}}_valid   : {{.mode_ms}} std_logic;
{{.x_wrapname}}_ctx     : {{.mode_sm}} std_logic_vector({{.type.x_tRegData.x_width}}-1 downto 0);
{{.x_wrapname}}_ready   : {{.mode_sm}} std_logic
