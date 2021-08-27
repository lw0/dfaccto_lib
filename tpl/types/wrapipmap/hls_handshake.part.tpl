{{?.is_ms_input}}
{{? .type.x_has_iack}}
{{.x_wrapname}}{{.type.x_iprefix}}_ap_ack => {{.identifier_ms}}.iack,
{{/ .type.x_has_iack}}
{{? .type.x_is_output}}
{{?  .type.x_has_ovld}}
{{.x_wrapname}}{{.type.x_oprefix}}_ap_vld => {{.identifier_ms}}.ovld,
{{/  .type.x_has_ovld}}
{{.x_wrapname}}{{.type.x_oprefix}} => std_logic_vector({{.identifier_ms}}.odata){{?.type.x_has_input}},{{/.type.x_has_input}}
{{/ .type.x_is_output}}
{{|.is_ms_input}}
{{? .type.x_has_iack}}
{{.x_wrapname}}{{.type.x_iprefix}}_ap_ack => {{.identifier_ms}}.iack,
{{/ .type.x_has_iack}}
{{? .type.x_is_output}}
{{?  .type.x_has_ovld}}
{{.x_wrapname}}{{.type.x_oprefix}}_ap_vld => {{.identifier_ms}}.ovld,
{{/  .type.x_has_ovld}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}{{.type.x_oprefix}}) => {{.identifier_ms}}.odata{{?.type.x_has_input}},{{/.type.x_has_input}}
{{/ .type.x_is_output}}
{{/.is_ms_input}}
{{?.is_sm_input}}
{{? .type.x_is_input}}
{{?  .type.x_has_ivld}}
{{.x_wrapname}}{{.type.x_iprefix}}_ap_vld => {{.identifier_sm}}.ivld,
{{/  .type.x_has_ivld}}
{{.x_wrapname}}{{.type.x_iprefix}} => std_logic_vector({{.identifier_sm}}.idata){{?.type.x_has_oack}},{{/.type.x_has_oack}}
{{/ .type.x_is_input}}
{{? .type.x_has_oack}}
{{.x_wrapname}}{{.type.x_oprefix}}_ap_ack => {{.identifier_sm}}.oack
{{/ .type.x_has_oack}}
{{|.is_sm_input}}
{{? .type.x_is_input}}
{{?  .type.x_has_ivld}}
{{.x_wrapname}}{{.type.x_iprefix}}_ap_vld => {{.identifier_sm}}.ivld,
{{/  .type.x_has_ivld}}
{{.type.x_tdata.qualified}}({{.x_wrapname}}{{.type.x_iprefix}}) => {{.identifier_sm}}.idata{{?.type.x_has_oack}},{{/.type.x_has_oack}}
{{/ .type.x_is_input}}
{{? .type.x_has_oack}}
{{.x_wrapname}}{{.type.x_oprefix}}_ap_ack => {{.identifier_sm}}.oack
{{/ .type.x_has_oack}}
{{/.is_sm_input}}
