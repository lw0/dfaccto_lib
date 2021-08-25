{{identifier}} : entity work.{{base.identifier}}{{^generics}}{{^ports}};{{/ports}}{{/generics}}
{{?generics}}
  generic map (
{{#generics}}
    {{>vhdl/interfacemap.part.tpl}}{{?._last}}){{^ports}};{{/ports}}{{|._last}},{{/._last}}
{{/ generics}}
{{/generics}}
{{?ports}}
  port map (
{{# ports}}
    {{>vhdl/interfacemap.part.tpl}}{{?._last}});{{|._last}},{{/._last}}
{{/ ports}}
{{/ports}}
