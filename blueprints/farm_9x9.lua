vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.blueprints = vlw.blueprints or {}

local bp = {
  prepare = {},
  plant = {},
}

local function add_prep(dx, dy, dz, name)
  table.insert(bp.prepare, {dx = dx, dy = dy, dz = dz, name = name})
end

local function add_plant(dx, dy, dz)
  table.insert(bp.plant, {dx = dx, dy = dy, dz = dz})
end

add_prep(0, 0, 0, "mcl_core:water_source")

for x = -4, 4 do
  for z = -4, 4 do
    if not (x == 0 and z == 0) then
      add_prep(x, 0, z, "mcl_farming:soil")
      add_plant(x, 1, z)
    end
  end
end

vlw.blueprints.farm_9x9 = bp
