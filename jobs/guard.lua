vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.guard = {}

-- Placeholder for guard job
-- Similar to soldier but guards a specific position

local function nearest_hostile(pos, r)
  local objs = minetest.get_objects_inside_radius(pos, r or 16)
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

function vlw.jobs.guard.step(ent)
  local pos = ent.object:get_pos()
  if not pos then return end

  -- Set guard post if not set
  if not ent._.job_data.guard_post then
    ent._.job_data.guard_post = vlw.util.round(pos)
  end

  local guard_post = ent._.job_data.guard_post

  -- Look for hostiles near guard post
  local hostile = nearest_hostile(guard_post, 16)
  if hostile then
    -- Chase and attack hostile
    vlw.nav.pathfind_to(ent, hostile:get_pos())
    if vector.distance(pos, hostile:get_pos()) < 2.2 then
      hostile:punch(ent.object, 0.5, {
        full_punch_interval = 0.8,
        damage_groups = {fleshy = 4},
      }, nil)
    end
  else
    -- Return to guard post if too far
    if vector.distance(pos, guard_post) > 4.0 then
      vlw.nav.pathfind_to(ent, guard_post)
    else
      -- Patrol around guard post
      if (not ent._.job_data.patrol_goal) or vector.distance(pos, ent._.job_data.patrol_goal) < 1.0 then
        ent._.job_data.patrol_goal = vector.add(guard_post, {
          x = math.random(-4, 4),
          y = 0,
          z = math.random(-4, 4),
        })
      end
      vlw.nav.pathfind_to(ent, ent._.job_data.patrol_goal)
    end
  end
end
