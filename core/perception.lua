vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.perception = vlw.perception or {}

function vlw.perception.light_at(pos)
  return minetest.get_node_light(pos) or 0
end

function vlw.perception.find_nodes_around(pos, names, radius)
  local r = radius or 8
  local p1 = vector.subtract(pos, {x = r, y = r, z = r})
  local p2 = vector.add(pos, {x = r, y = r, z = r})
  return minetest.find_nodes_in_area(p1, p2, names or {"group:crumbly", "group:cracky"})
end

function vlw.perception.ground_below(pos, max_drop)
  local maxd = max_drop or 4
  local p = {x = pos.x, y = pos.y, z = pos.z}
  for _ = 1, maxd do
    local n = minetest.get_node_or_nil({x = p.x, y = p.y - 1, z = p.z})
    if n and n.name ~= "air" then
      return p
    end
    p.y = p.y - 1
  end
  return p
end

function vlw.perception.find_nearest_chest(pos, radius)
  local nodes = vlw.perception.find_nodes_around(
    pos,
    {"mcl_chests:chest", "mcl_chests:trapped_chest"},
    radius or 16
  )
  local best, bestd
  for _, p in ipairs(nodes) do
    local d = vector.distance(pos, p)
    if not best or d < bestd then
      best = p
      bestd = d
    end
  end
  return best, bestd
end
