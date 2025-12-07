vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.miner = {}

local TARGETS = {
  "mcl_core:stone_with_coal",
  "mcl_core:stone_with_iron",
  "mcl_core:stone",
}

local function find_target(pos)
  local nodes = vlw.perception.find_nodes_around(pos, TARGETS, 18)
  local best, bestd
  for _, p in ipairs(nodes) do
    local d = vector.distance(pos, p)
    if not best or d < bestd then
      best = p
      bestd = d
    end
  end
  return best
end

function vlw.jobs.miner.step(ent)
  local pos = ent.object:get_pos()
  if not pos then return end

  if ent._.job_data.target then
    local n = minetest.get_node_or_nil(ent._.job_data.target)
    if not n or n.name == "air" then
      ent._.job_data.target = nil
    end
  end

  if not ent._.job_data.target then
    ent._.job_data.target = find_target(pos)
    if not ent._.job_data.target then
      local wander = vector.add(pos, {x = math.random(-8, 8), y = 0, z = math.random(-8, 8)})
      vlw.nav.pathfind_to(ent, wander)
      return
    end
  end

  local tgt = ent._.job_data.target
  if vector.distance(pos, tgt) > 2.0 then
    vlw.nav.pathfind_to(ent, tgt)
    return
  end

  local ok, name = vlw.world.dig_node_safe(tgt)
  if ok then
    if name == "mcl_core:stone" then
      vlw.inventory.add(ent._.inv, "mcl_core:cobble", 1)
    else
      vlw.inventory.add(ent._.inv, name, 1)
    end
    ent._.job_data.target = nil
  else
    ent._.job_data.target = nil
  end

  if math.random() < 0.05 then
    vlw.world.push_to_nearest_chest(pos, ent._.inv, 24)
  end
end
