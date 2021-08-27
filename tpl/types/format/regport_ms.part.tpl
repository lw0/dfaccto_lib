(addr => {{=..x_taddr}}{{=..addr}}{{*..x_format}}{{|..addr}}{{.x_cnull.qualified}}{{/..addr}}{{/..x_taddr}},
 wrdata => {{=..x_tdata}}{{=..wrdata}}{{*..x_format}}{{|..wrdata}}{{.x_cnull.qualified}}{{/..wrdata}}{{/..x_tdata}},
 wrstrb => {{=..x_tstrb}}{{=..wrstrb}}{{*..x_format}}{{|..wrstrb}}{{.x_cnull.qualified}}{{/..wrstrb}}{{/..x_tstrb}},
 wrnotrd => {{=..x_tlogic}}{{=..wrnotrd}}{{*..x_format}}{{|..wrnotrd}}{{.x_cnull.qualified}}{{/..wrnotrd}}{{/..x_tlogic}},
 valid => {{=..x_tlogic}}{{=..valid}}{{*..x_format}}{{|..valid}}{{.x_cnull.qualified}}{{/..valid}}{{/..x_tlogic}})
