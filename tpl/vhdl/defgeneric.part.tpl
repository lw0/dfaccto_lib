{{#is_complex}}
{{identifier_ms}} : {{>vhdl/puttype_unconstrained_ms.part.tpl}}{{?has_default}} := {{=default}}{{>vhdl/putvalue_ms.part.tpl}}{{/default}}{{/has_default}};
{{identifier_sm}} : {{>vhdl/puttype_unconstrained_sm.part.tpl}}{{?has_default}} := {{=default}}{{>vhdl/putvalue_sm.part.tpl}}{{/default}}{{/has_default}}
{{|is_complex}}
{{identifier}} : {{>vhdl/puttype_unconstrained.part.tpl}}{{?has_default}} := {{=default}}{{>vhdl/putvalue.part.tpl}}{{/default}}{{/has_default}}
{{/is_complex}}
