vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.util = vlw.util or {}

function vlw.util.trim(s)
  if not s then return "" end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function vlw.util.round(p)
  return {
    x = math.floor(p.x + 0.5),
    y = math.floor(p.y + 0.5),
    z = math.floor(p.z + 0.5),
  }
end

function vlw.util.copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      r[k] = vlw.util.copy(v)
    else
      r[k] = v
    end
  end
  return r
end

function vlw.util.look_at_entity(player, range, name_exact)
  local props = player:get_properties() or {}
  local eye_height = props.eye_height or 1.4
  local eye = vector.add(player:get_pos(), {x = 0, y = eye_height, z = 0})
  local dir = player:get_look_dir()
  local step = 0.5
  local steps = math.floor((range or 6) / step)

  for i = 1, steps do
    local p = vector.add(eye, vector.multiply(dir, i * step))
    local objs = minetest.get_objects_inside_radius(p, 1.0)
    for _, obj in ipairs(objs) do
      if not obj:is_player() then
        local le = obj:get_luaentity()
        if le then
          local ename = obj:get_entity_name()
          if (not name_exact) or (ename == name_exact) then
            return obj
          end
        end
      end
    end
  end

  return nil
end
