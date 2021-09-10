{{?is_assigned}}
{{? is_complex}}
{{#  assignments}}
{{..identifier_ms}}({{._idx}}) => {{>vhdl/putvalue_ms.part.tpl}},
{{/  assignments}}
{{#  assignments}}
{{..identifier_sm}}({{._idx}}) => {{>vhdl/putvalue_sm.part.tpl}}{{^_last}},{{/_last}}
{{/  assignments}}
{{#  assignment}}
{{..identifier_ms}} => {{>vhdl/putvalue_ms.part.tpl}},
{{..identifier_sm}} => {{>vhdl/putvalue_sm.part.tpl}}
{{/  assignment}}
{{?  assignempty}}
{{?   .is_ms_input}}
{{.identifier_ms}} => (others => {{.type.x_cnull.qualified_ms}}),
{{|   .is_ms_input}}
{{.identifier_ms}} => open,
{{/   .is_ms_input}}
{{?   .is_sm_input}}
{{.identifier_sm}} => (others => {{.type.x_cnull.qualified_sm}})
{{|   .is_sm_input}}
{{.identifier_sm}} => open
{{/   .is_sm_input}}
{{/  assignempty}}
{{| is_complex}}
{{#  assignments}}
{{..identifier}}({{._idx}}) => {{>vhdl/putvalue.part.tpl}}{{^_last}},{{/_last}}
{{/  assignments}}
{{#  assignment}}
{{..identifier}} => {{>vhdl/putvalue.part.tpl}}
{{/  assignment}}
{{?  assignempty}}
{{?   .is_input}}
{{.identifier}} => (others => {{.type.x_cnull.qualified}})
{{|   .is_input}}
{{.identifier}} => open
{{/   .is_input}}
{{/  assignempty}}
{{/ is_complex}}
{{|is_assigned}}
{{? is_complex}}
{{identifier_ms}} => open,
{{identifier_sm}} => open
{{| is_complex}}
{{identifier}} => open
{{/ is_complex}}
{{/is_assigned}}
