{{?.is_ms_input}}
{{? .type.x_tsdata}}
{{.x_wrapname}}_sdata => std_logic_vector({{.identifier_ms}}.sdata),
{{/ .type.x_tsdata}}
{{.x_wrapname}}_stb => {{.identifier_ms}}.stb,
{{|.is_ms_input}}
{{? .type.x_tsdata}}
{{.type.x_tsdata.qualified}}({{.x_wrapname}}_sdata) => {{.identifier_ms}}.sdata,
{{/ .type.x_tsdata}}
{{.x_wrapname}}_stb => {{.identifier_ms}}.stb,
{{/.is_ms_input}}
{{?.is_sm_input}}
{{? .type.x_tadata}}
{{.x_wrapname}}_adata => std_logic_vector({{.identifier_ms}}.adata),
{{/ .type.x_tadata}}
{{.x_wrapname}}_ack => {{.identifier_sm}}.ack
{{|.is_sm_input}}
{{? .type.x_tadata}}
{{.type.x_tadata.qualified}}({{.x_wrapname}}_adata) => {{.identifier_ms}}.adata,
{{/ .type.x_tadata}}
{{.x_wrapname}}_ack => {{.identifier_sm}}.ack
{{/.is_sm_input}}
