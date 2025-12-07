vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.blueprints = vlw.blueprints or {}

local bp = {}
bp.order = {}

local function add(dx, dy, dz, name, param2)
  table.insert(bp.order, {dx = dx, dy = dy, dz = dz, name = name, param2 = param2 or 0})
end

for x = -2, 2 do
  for z = -2, 2 do
    add(x, 0, z, "mcl_core:cobble")
  end
end

for y = 1, 3 do
  for x = -2, 2 do
    add(x, y, -2, "mcl_core:wood")
    add(x, y,  2, "mcl_core:wood")
  end
  for z = -1, 1 do
    add(-2, y, z, "mcl_core:wood")
    add( 2, y, z, "mcl_core:wood")
  end
end

add(0, 1, -2, "mcl_doors:door_wood", 0)

for x = -2, 2 do
  add(x, 4, -2, "mcl_stairs:stair_cobble", 0)
  add(x, 4,  2, "mcl_stairs:stair_cobble", 2)
end

vlw.blueprints.hut = bp
