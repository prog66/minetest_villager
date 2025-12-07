vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.nav = vlw.nav or {}

local function set_velocity(self, dir)
  local s = vlw.SETTINGS.walk_speed or 2.5
  self.object:set_velocity({
    x = dir.x * s,
    y = dir.y * s,
    z = dir.z * s,
  })
end

function vlw.nav.pathfind_to(ent, goal)
  local pos = ent.object:get_pos()
  if not pos or not goal then return false end

  local path = minetest.find_path(
    vlw.util.round(pos),
    vlw.util.round(goal),
    vlw.SETTINGS.path_searchdistance or 64,
    vlw.SETTINGS.path_jump or 1,
    vlw.SETTINGS.path_drop or 2,
    "A*_noprefetch"
  )

  if path and #path >= 2 then
    ent._.path = path
    ent._.path_i = 2
    ent._.goal = goal
    return true
  else
    ent._.path = nil
    ent._.goal = nil
    return false
  end
end

function vlw.nav.follow_path(ent, dtime)
  local path = ent._.path
  if not path or not path[ent._.path_i or 2] then
    return false
  end

  local pos = ent.object:get_pos()
  if not pos then
    ent._.path = nil
    return false
  end

  local wp = path[ent._.path_i]
  local dir = vector.direction(pos, wp)
  if not dir then
    ent._.path = nil
    return false
  end

  local flat = {x = dir.x, y = 0, z = dir.z}
  local len = math.sqrt(flat.x * flat.x + flat.z * flat.z)
  if len < 1e-6 then
    ent._.path = nil
    return false
  end

  flat.x = flat.x / len
  flat.z = flat.z / len

  ent.object:set_yaw(minetest.dir_to_yaw(flat))
  set_velocity(ent, flat)

  if vector.distance(pos, wp) < 0.7 then
    ent._.path_i = ent._.path_i + 1
    if not path[ent._.path_i] then
      ent._.path = nil
      set_velocity(ent, {x = 0, y = 0, z = 0})
    end
  end

  return true
end
