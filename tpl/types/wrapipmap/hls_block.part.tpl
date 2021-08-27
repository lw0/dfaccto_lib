{{?.is_ms_input}}
{{.x_wrapname}}_start    => {{.identifier_ms}}.start,
{{? .type.x_has_continue}}
{{.x_wrapname}}_continue => {{.identifier_ms}}.continue,
{{/ .type.x_has_continue}}
{{|.is_ms_input}}
{{.x_wrapname}}_start => {{.identifier_ms}}.start,
{{? .type.x_has_continue}}
{{.x_wrapname}}_continue => {{.identifier_ms}}.continue,
{{/ .type.x_has_continue}}
{{/.is_ms_input}}
{{?.is_sm_input}}
{{.x_wrapname}}_idle     => {{.identifier_sm}}.idle,
{{.x_wrapname}}_ready    => {{.identifier_sm}}.ready,
{{?.type.x_tdata}}
{{.x_wrapname}}_return   => std_logic_vector({{.identifier_sm}}.data),
{{/.type.x_tdata}}
{{.x_wrapname}}_done     => {{.identifier_sm}}.done
{{|.is_sm_input}}
{{.x_wrapname}}_idle => {{.identifier_sm}}.idle,
{{.x_wrapname}}_ready => {{.identifier_sm}}.ready,
{{?.type.x_tdata}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}_return) => {{.identifier_sm}}.data,
{{/.type.x_tdata}}
{{.x_wrapname}}_done => {{.identifier_sm}}.done
{{/.is_sm_input}}
