{{=assignment}}
{{>vhdl/putvalue_ms.part.tpl}}
{{/assignment}}
{{?assignments}}
({{#assignments}}{{>vhdl/putvalue_ms.part.tpl}}{{^_last}}, {{/_last}}{{/assignments}})
{{/assignments}}
{{?assignempty}}
(others => {{.type.x_cnull.qualified_ms}})
{{/assignempty}}
