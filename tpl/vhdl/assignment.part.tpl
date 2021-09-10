{{=assignment}}
{{>vhdl/putvalue.part.tpl}}
{{/assignment}}
{{?assignments}}
({{#assignments}}{{>vhdl/putvalue.part.tpl}}{{^_last}}, {{/_last}}{{/assignments}})
{{/assignments}}
{{?assignempty}}
(others => {{.type.x_cnull.qualified}})
{{/assignempty}}
