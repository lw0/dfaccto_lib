type {{.identifier_ms}} is record
  addr : {{.x_taddr.qualified}};
  wrdata : {{.x_tdata.qualified}};
  wrstrb : {{.x_tstrb.qualified}};
  wrnotrd : {{.x_tlogic.qualified}};
  valid : {{.x_tlogic.qualified}};
end record;
type {{identifier_sm}} is record
  rddata : {{.x_tdata.qualified}};
  ready : {{.x_tlogic.qualified}};
end record;
type {{.identifier_v_ms}} is array (integer range <>) of {{.qualified_ms}};
type {{.identifier_v_sm}} is array (integer range <>) of {{.qualified_sm}};
