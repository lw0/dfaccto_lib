{{?is_assigned}}
{{? is_complex}}
constant {{identifier_ms}} : {{>vhdl/puttype_ms.part.tpl}}
          := {{>vhdl/assignment_ms.part.tpl}};
constant {{identifier_sm}} : {{>vhdl/puttype_sm.part.tpl}}
          := {{>vhdl/assignment_sm.part.tpl}};
{{| is_complex}}
constant {{identifier}} : {{>vhdl/puttype.part.tpl}}
          := {{>vhdl/assignment.part.tpl}};
{{/ is_complex}}
{{|is_assigned}}
{{? is_complex}}
-- constant {{identifier_ms}} : {{>vhdl/puttype_ms.part.tpl}} := <undefined>;
-- constant {{identifier_sm}} : {{>vhdl/puttype_sm.part.tpl}} := <undefined>;
{{| is_complex}}
-- constant {{identifier}} : {{>vhdl/puttype.part.tpl}} := <undefined>;
{{/ is_complex}}
{{/is_assigned}}
