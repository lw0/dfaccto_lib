{{?.is_ms_input}}
{{.identifier_ms}}.addr    <= {{.type.x_taddr.qualified}}({{.x_wrapname}}_addr);
{{.identifier_ms}}.wrdata  <= {{.type.x_tdata.qualified}}({{.x_wrapname}}_wrdata);
{{.identifier_ms}}.wrstrb  <= {{.type.x_tstrb.qualified}}({{.x_wrapname}}_wrstrb);
{{.identifier_ms}}.wrnotrd <= {{.x_wrapname}}_wrnotrd;
{{.identifier_ms}}.valid   <= {{.x_wrapname}}_valid;
{{|.is_ms_input}}
{{.x_wrapname}}_addr    <= std_logic_vector({{.identifier_ms}}.addr);
{{.x_wrapname}}_wrdata  <= std_logic_vector({{.identifier_ms}}.wrdata);
{{.x_wrapname}}_wrstrb  <= std_logic_vector({{.identifier_ms}}.ctx);
{{.x_wrapname}}_wrnotrd <= {{.identifier_ms}}.wrstrb;
{{.x_wrapname}}_valid   <= {{.identifier_ms}}.valid;
{{/.is_ms_input}}
{{?.is_sm_input}}
{{.identifier_sm}}.rddata <= {{.type.x_tdata}}({{.x_wrapname}}_rddata);
{{.identifier_sm}}.ready  <= {{.x_wrapname}}_ready;
{{|.is_sm_input}}
{{.x_wrapname}}_rddata <= std_logic_vector({{.identifier_sm}}.rddata);
{{.x_wrapname}}_ready  <= {{.identifier_sm}}.ready;
{{/.is_sm_input}}
