{{?is_assigned}}
{{? is_complex}}
{{#  assignments}}
{{..identifier_ms}}({{._idx}}) => {{>vhdl/putvalue_ms.part.tpl}},
{{..identifier_sm}}({{._idx}}) => {{>vhdl/putvalue_sm.part.tpl}}{{^_last}},{{/_last}}
{{/  assignments}}
{{#  assignment}}
{{..identifier_ms}} => {{>vhdl/putvalue_ms.part.tpl}},
{{..identifier_sm}} => {{>vhdl/putvalue_sm.part.tpl}}
{{/  assignment}}
{{| is_complex}}
{{#  assignments}}
{{..identifier}}({{._idx}}) => {{>vhdl/putvalue.part.tpl}}{{^_last}},{{/_last}}
{{/  assignments}}
{{#  assignment}}
{{..identifier}} => {{>vhdl/putvalue.part.tpl}}
{{/  assignment}}
{{/ is_complex}}
{{|is_assigned}}
{{? is_complex}}
{{identifier_ms}} => open,
{{identifier_sm}} => open
{{| is_complex}}
{{identifier}} => open
{{/ is_complex}}
{{/is_assigned}}
