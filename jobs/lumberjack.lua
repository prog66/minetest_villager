vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.lumberjack = {}

-- Placeholder for lumberjack job
-- TODO: Implement tree detection, pathfinding to trees, chopping, and replanting

local TREE_NODES = {
  "mcl_core:tree",
  "mcl_core:sprucetree",
  "mcl_core:birchtree",
  "mcl_core:darktree",
  "mcl_core:jungletree",
}

local function find_tree(pos)
  local nodes = vlw.perception.find_nodes_around(pos, TREE_NODES, 16)
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

function vlw.jobs.lumberjack.step(ent)
  local pos = ent.object:get_pos()
  if not pos then return end

  -- Check if current target still exists
  if ent._.job_data.target then
    local n = minetest.get_node_or_nil(ent._.job_data.target)
    if not n or n.name == "air" then
      ent._.job_data.target = nil
    end
  end

  -- Find a new tree if no target
  if not ent._.job_data.target then
    ent._.job_data.target = find_tree(pos)
    if not ent._.job_data.target then
      -- No trees found, wander
      local wander = vector.add(pos, {x = math.random(-8, 8), y = 0, z = math.random(-8, 8)})
      vlw.nav.pathfind_to(ent, wander)
      return
    end
  end

  -- Navigate to tree
  local tgt = ent._.job_data.target
  if vector.distance(pos, tgt) > 2.0 then
    vlw.nav.pathfind_to(ent, tgt)
    return
  end

  -- Chop the tree
  local ok, name = vlw.world.dig_node_safe(tgt)
  if ok then
    -- Add wood to inventory
    if name:find("tree") then
      vlw.inventory.add(ent._.inv, name, 1)
    end
    ent._.job_data.target = nil
  else
    ent._.job_data.target = nil
  end

  -- Occasionally deposit items in chest
  if math.random() < 0.05 then
    vlw.world.push_to_nearest_chest(pos, ent._.inv, 24)
  end
end
