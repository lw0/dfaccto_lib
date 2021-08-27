{{?.is_input}}
{{.x_wrapname}} => std_logic_vector({{.identifier}})
{{|.is_input}}
{{.type.qualified}}({{.x_wrapname}}) => {{.identifier}}
{{/.is_input}}
