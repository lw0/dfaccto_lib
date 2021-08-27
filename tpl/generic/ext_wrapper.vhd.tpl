{{>vhdl/dependencies.part.tpl}}


entity {{identifier}} is
  {{>vhdl/defgenerics.part.tpl}}
{{?ports}}
  port (
{{# ports}}
    -- {{name}}:
    {{*.type.x_wrapeport}}{{?._last}}){{/._last}};
{{/ ports}}
{{/ports}}
end {{identifier}};

architecture ExtWrapper of {{identifier}} is

  -- Internal Ports:

{{#ports}}
{{? .is_scalar}}
  -- {{name}}
  {{>vhdl/defsignal.part.tpl}}
{{| .is_scalar}}
  report "ExternalWrapper can not wrap vector port {{name}}" severity failure;
{{/ .is_scalar}}
{{/ports}}

  -- Signals:

{{#signals}}
  {{>vhdl/defsignal.part.tpl}}
{{/signals}}

begin

  -- Instantiations:

{{#instances}}
  {{>vhdl/instance.part.tpl}}

{{/instances}}

  -- Port Mapping:

{{#ports}}
  -- {{name}}
  {{*.type.x_wrapeconv}}
{{/ports}}

end ExtWrapper;
