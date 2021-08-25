{{>vhdl/dependencies.part.tpl}}


package {{identifier}} is

{{#declarations}}
{{? is_a_type}}
  {{*x_definition}}
{{/ is_a_type}}
{{? is_a_constant}}
  {{>vhdl/constant.part.tpl}}
{{/ is_a_constant}}

{{/declarations}}
end {{identifier}};
