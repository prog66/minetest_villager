vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.farmer = {}

local FARM_NODES = {
  soil = {"mcl_farming:soil", "mcl_farming:soil_wet"},
  stages = {
    base = "mcl_farming:wheat_0",
    mature = "mcl_farming:wheat_8",
  },
}

local function ensure_plot(ent)
  if ent._.job_data.plot_base then
    return
  end
  local pos = vlw.util.round(ent.object:get_pos())
  local base = vector.add(pos, {x = 4, y = 0, z = 0})
  ent._.job_data.plot_base = base
  ent._.job_data.phase = "prep"
  ent._.job_data.idx = 1
  ent._.job_data.bp = vlw.blueprints.farm_9x9
end

local function do_prepare(ent)
  local bp = ent._.job_data.bp
  local base = ent._.job_data.plot_base
  local idx = ent._.job_data.idx or 1
  if idx > #bp.prepare then
    return true
  end

  local step = bp.prepare[idx]
  local np = {
    x = base.x + step.dx,
    y = base.y + step.dy,
    z = base.z + step.dz,
  }

  if vector.distance(ent.object:get_pos(), np) > 2.0 then
    vlw.nav.pathfind_to(ent, np)
    return false
  end

  if step.name == "mcl_farming:soil" then
    local under = minetest.get_node_or_nil({x = np.x, y = np.y, z = np.z})
    if under and under.name ~= "mcl_farming:soil" then
      if not minetest.is_protected(np, "") then
        minetest.set_node(np, {name = "mcl_farming:soil"})
      end
    end
  elseif step.name == "mcl_core:water_source" then
    if not minetest.is_protected(np, "") then
      minetest.set_node(np, {name = "mcl_core:water_source"})
    end
  end

  ent._.job_data.idx = idx + 1
  return ent._.job_data.idx > #bp.prepare
end

local function do_plant(ent)
  local bp = ent._.job_data.bp
  local base = ent._.job_data.plot_base
  local idx = ent._.job_data.idx or 1
  if idx > #bp.plant then
    return true
  end

  local step = bp.plant[idx]
  local np = {
    x = base.x + step.dx,
    y = base.y + step.dy,
    z = base.z + step.dz,
  }

  if vector.distance(ent.object:get_pos(), np) > 2.0 then
    vlw.nav.pathfind_to(ent, np)
    return false
  end

  local n = minetest.get_node_or_nil(np)
  if n and (n.name == "air" or n.name:find("wheat_")) then
    if not minetest.is_protected(np, "") then
      minetest.set_node(np, {name = FARM_NODES.stages.base})
    end
  end

  ent._.job_data.idx = idx + 1
  return ent._.job_data.idx > #bp.plant
end

local function do_harvest(ent)
  local bp = ent._.job_data.bp
  local base = ent._.job_data.plot_base
  local idx = ent._.job_data.idx or 1
  if idx > #bp.plant then
    ent._.job_data.idx = 1
    return true
  end

  local step = bp.plant[idx]
  local np = {
    x = base.x + step.dx,
    y = base.y + step.dy,
    z = base.z + step.dz,
  }

  if vector.distance(ent.object:get_pos(), np) > 2.0 then
    vlw.nav.pathfind_to(ent, np)
    return false
  end

  local n = minetest.get_node_or_nil(np)
  if n and n.name == FARM_NODES.stages.mature then
    if not minetest.is_protected(np, "") then
      minetest.remove_node(np)
      vlw.inventory.add(ent._.inv, "mcl_farming:wheat", math.random(1, 3))
      vlw.inventory.add(ent._.inv, "mcl_farming:wheat_seeds", math.random(0, 2))
      minetest.set_node(np, {name = FARM_NODES.stages.base})
    end
  end

  ent._.job_data.idx = idx + 1
  return false
end

function vlw.jobs.farmer.step(ent)
  ensure_plot(ent)
  local phase = ent._.job_data.phase or "prep"

  if phase == "prep" then
    if do_prepare(ent) then
      ent._.job_data.phase = "plant"
      ent._.job_data.idx = 1
    end
    return
  end

  if phase == "plant" then
    if do_plant(ent) then
      ent._.job_data.phase = "cycle"
      ent._.job_data.idx = 1
    end
    return
  end

  do_harvest(ent)

  if math.random() < 0.1 then
    local pos = ent.object:get_pos()
    vlw.world.push_to_nearest_chest(pos, ent._.inv, 24)
  end
end
