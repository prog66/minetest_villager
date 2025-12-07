vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.world = vlw.world or {}

local function is_allowed_name(name)
  for _, prefix in ipairs(vlw.SETTINGS.allow_prefix or {"mcl_", "vl_"}) do
    if name:sub(1, #prefix) == prefix then
      return true
    end
  end
  return false
end

function vlw.world.place_node_safe(pos, nodename, param2)
  if not is_allowed_name(nodename) then
    return false
  end

  if minetest.is_protected(pos, "") then
    return false
  end

  local cn = minetest.get_node_or_nil(pos)
  if not cn or cn.name ~= "air" then
    return false
  end

  local under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
  if not under or under.name == "air" then
    return false
  end

  minetest.set_node(pos, {name = nodename, param2 = param2 or 0})
  return true
end

function vlw.world.dig_node_safe(pos)
  if minetest.is_protected(pos, "") then
    return false, nil
  end

  local n = minetest.get_node_or_nil(pos)
  if not n or n.name == "air" then
    return false, nil
  end

  if not is_allowed_name(n.name) then
    return false, nil
  end

  minetest.remove_node(pos)
  return true, n.name
end

function vlw.world.push_to_nearest_chest(pos, invtbl, radius)
  local chest_pos = vlw.perception.find_nearest_chest(pos, radius or 16)
  if not chest_pos then
    return false
  end

  local meta = minetest.get_meta(chest_pos)
  if not meta then return false end
  local inv = meta:get_inventory()
  if not inv then return false end

  for name, count in pairs(invtbl) do
    if count > 0 then
      local stack = ItemStack(name .. " " .. count)
      local leftover = inv:add_item("main", stack)
      invtbl[name] = leftover:get_count()
    end
  end

  return true
end
