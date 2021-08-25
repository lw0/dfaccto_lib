{{>vhdl/dependencies.part.tpl}}


{{>vhdl/defentity.part.tpl}}


architecture Structure of {{identifier}} is

{{#signals}}
  {{>vhdl/defsignal.part.tpl}}
{{/signals}}

begin

{{#instances}}
  {{>vhdl/instance.part.tpl}}

{{/instances}}
end Structure;
