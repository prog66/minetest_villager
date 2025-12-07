vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.builder = {}

local function pick_blueprint(ent)
  if ent._.blueprint then
    return ent._.blueprint
  end
  ent._.blueprint = {
    name = "hut",
    data = vlw.blueprints.hut,
  }
  return ent._.blueprint
end

local function place_next(ent)
  local bp = pick_blueprint(ent).data
  if not ent._.job_data.idx then
    ent._.job_data.idx = 1
  end
  local idx = ent._.job_data.idx
  if idx > #bp.order then
    return true
  end

  local pos = ent.object:get_pos()
  if not ent._.job_data.base then
    ent._.job_data.base = vlw.util.round(pos)
  end
  local base = ent._.job_data.base

  local step = bp.order[idx]
  local np = {
    x = base.x + step.dx,
    y = base.y + step.dy,
    z = base.z + step.dz,
  }

  if vector.distance(pos, np) > 2.0 then
    vlw.nav.pathfind_to(ent, np)
    return false
  end

  if vlw.world.place_node_safe(np, step.name, step.param2) then
    vlw.inventory.take(ent._.inv, step.name, 1)
    ent._.job_data.idx = idx + 1
  else
    local ok = vlw.world.dig_node_safe(np)
    if not ok then
      ent._.job_data.idx = idx + 1
    end
  end

  return ent._.job_data.idx > #bp.order
end

function vlw.jobs.builder.step(ent)
  local done = place_next(ent)
  if done then
    ent:_set_job("idle", {})
  end
end
