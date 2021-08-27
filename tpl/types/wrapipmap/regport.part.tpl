{{?.is_ms_input}}
{{.x_wrapname}}_addr    => std_logic_vector({{.identifier_ms}}.addr),
{{.x_wrapname}}_wrdata  => std_logic_vector({{.identifier_ms}}.wrdata),
{{.x_wrapname}}_wrstrb  => std_logic_vector({{.identifier_ms}}.wrstrb),
{{.x_wrapname}}_wrnotrd => {{.identifier_ms}}.wrnotrd,
{{.x_wrapname}}_valid   => {{.identifier_ms}}.valid,
{{|.is_ms_input}}
{{.x_taddr.qualified}}({{.x_wrapname}}_addr)    => {{.identifier_ms}}.addr,
{{.x_tdata.qualified}}({{.x_wrapname}}_wrdata)  => {{.identifier_ms}}.wrdata,
{{.x_tstrb.qualified}}({{.x_wrapname}}_wrstrb)  => {{.identifier_ms}}.wrstrb,
{{.x_wrapname}}_wrnotrd => {{.identifier_ms}}.wrnotrd,
{{.x_wrapname}}_valid   => {{.identifier_ms}}.valid,
{{/.is_ms_input}}
{{?.is_sm_input}}
{{.x_wrapname}}_rddata  => std_logic_vector({{.identifier_sm}}.rddata),
{{.x_wrapname}}_ready   => {{.identifier_sm}}.ready
{{|.is_sm_input}}
{{.x_tdata.qualified}}({{.x_wrapname}}_rddata)  => {{.identifier_sm}}.rddata,
{{.x_wrapname}}_ready   => {{.identifier_sm}}.ready
{{/.is_sm_input}}
