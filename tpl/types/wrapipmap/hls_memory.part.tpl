{{?.is_ms_input}}
{{.x_wrapname}}_address0 => std_logic_vector({{.identifier_ms}}.addr),
{{? .type.x_has_wr}}
{{.x_wrapname}}_we0 => {{.identifier_ms}}.write,
{{.x_wrapname}}_d0 => std_logic_vector({{.identifier_ms}}.wdata),
{{/ .type.x_has_wr}}
{{.x_wrapname}}_ce0 => {{.identifier_ms}}.strobe{{?.type.x_has_rd}},{{?.type.x_has_rd}}
{{|.is_ms_input}}
{{.type.x_taddr.qualified}}({{.x_wrapname}}_address0) => {{.identifier_ms}}.addr,
{{? .type.x_has_wr}}
{{.x_wrapname}}_we0 => {{.identifier_ms}}.write,
{{.type.x_tdata.qualified}}({{.x_wrapname}}_d0) => {{.identifier_ms}}.wdata,
{{/ .type.x_has_wr}}
{{.x_wrapname}}_ce0 => {{.identifier_ms}}.strobe{{?.type.x_has_rd}},{{?.type.x_has_rd}}
{{/.is_ms_input}}
{{?.is_sm_input}}
{{? .type.x_has_rd}}
{{.x_wrapname}}_q0 => std_logic_vector({{.identifier_sm}}.data)
{{/ .type.x_has_rd}}
{{|.is_sm_input}}
{{? .type.x_has_rd}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}_q0) => {{.identifier_sm}}.data
{{/ .type.x_has_rd}}
{{/.is_sm_input}}
