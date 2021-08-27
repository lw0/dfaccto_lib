{{>vhdl/dependencies.part.tpl}}


{{>vhdl/defentity.part.tpl}}


architecture IntWrapper of {{identifier}} is

{{#ports}}
{{^ .is_scalar}}
  report "InternalWrapper can not wrap vector port {{name}}" severity failure;
{{/ .is_scalar}}
{{/ports}}

begin

  -- Instantiation:

  i_wrapped : entity work.{{x_wrapname}}
{{?x_genports}}
    generic map (
{{# x_genports}}
      -- {{name}}
      {{*.type.x_wrapigmap}}{{?._last}}){{|._last}},{{/._last}}
{{/ x_genports}}
{{/x_genports}}
    port map (
{{#ports}}
      -- {{name}}
      {{*.type.x_wrapipmap}}{{?._last}});{{|._last}},{{/._last}}
{{/ports}}

end IntWrapper;
