vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.soldier = {}

local function nearest_hostile(pos, r)
  local objs = minetest.get_objects_inside_radius(pos, r or 12)
  local best, bestd
  for _, obj in ipairs(objs) do
    if not obj:is_player() then
      local le = obj:get_luaentity()
      if le and le.name and le.name ~= vlw.modname .. ":worker" then
        local d = vector.distance(pos, obj:get_pos())
        if not best or d < bestd then
          best = obj
          bestd = d
        end
      end
    end
  end
  return best
end

function vlw.jobs.soldier.step(ent)
  local pos = ent.object:get_pos()
  if not pos then return end

  local hostile = nearest_hostile(pos, 14)
  if hostile then
    vlw.nav.pathfind_to(ent, hostile:get_pos())
    if vector.distance(pos, hostile:get_pos()) < 2.2 then
      hostile:punch(ent.object, 0.5, {
        full_punch_interval = 0.8,
        damage_groups = {fleshy = 4},
      }, nil)
    end
  else
    if (not ent._.job_data.goal) or vector.distance(pos, ent._.job_data.goal) < 1.0 then
      ent._.job_data.goal = vector.add(pos, {x = math.random(-8, 8), y = 0, z = math.random(-8, 8)})
    end
    vlw.nav.pathfind_to(ent, ent._.job_data.goal)
  end
end
