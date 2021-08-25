{{?ports}}
port (
{{# ports}}
  {{>vhdl/defport.part.tpl}}{{?_last}}){{/_last}};
{{/ ports}}
{{/ports}}
