{{=assignment}}
{{>vhdl/putvalue_sm.part.tpl}}
{{/assignment}}
{{?assignments}}
({{#assignments}}{{>vhdl/putvalue_sm.part.tpl}}{{^_last}}, {{/_last}}{{/assignments}})
{{/assignments}}
