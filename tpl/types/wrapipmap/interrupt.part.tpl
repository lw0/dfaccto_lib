{{?.is_ms_input}}
{{.x_wrapname}}     => {{.identifier_ms}}.stb,
{{.x_wrapname}}_src => std_logic_vector({{.identifier_ms}}.src),
{{.x_wrapname}}_ctx => std_logic_vector({{.identifier_ms}}.ctx),
{{|.is_ms_input}}
{{.x_wrapname}} => {{.identifier_ms}}.stb,
{{.type.x_tsrc.qualified}}({{.x_wrapname}}_src) => {{.identifier_ms}}.src,
{{.type.x_tsrc.qualified}}({{.x_wrapname}}_ctx) => {{.identifier_ms}}.ctx,
{{/.is_ms_input}}
{{?.is_sm_input}}
{{.x_wrapname}}_ack => {{.identifier_sm}}.ack
{{|.is_sm_input}}
{{.x_wrapname}}_ack => {{.identifier_sm}}.ack
{{/.is_sm_input}}
