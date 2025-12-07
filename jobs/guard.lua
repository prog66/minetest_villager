vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.guard = {}

-- Guard job: patrols a guard post and defends against hostile mobs

local function nearest_hostile(pos, r)
  local objs = minetest.get_objects_inside_radius(pos, r or 16)
  local best, bestd
  for _, obj in ipairs(objs) do
    if not obj:is_player() then
      local le = obj:get_luaentity()
      if le and le.name and le.name ~= vlw.modname .. ":worker" then
        -- Check if it's a hostile mob (has type = "monster" or attack_type)
        if le.type == "monster" or le.attack_type or 
           (le.name and (le.name:find("zombie") or le.name:find("skeleton") or 
                         le.name:find("spider") or le.name:find("creeper"))) then
          local d = vector.distance(pos, obj:get_pos())
          if not best or d < bestd then
            best = obj
            bestd = d
          end
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
      -- Track last punch time
      local now = minetest.get_gametime()
      local last_punch = ent._.job_data.last_punch or 0
      if now - last_punch >= 0.8 then
        hostile:punch(ent.object, 1.0, {
          full_punch_interval = 0.8,
          damage_groups = {fleshy = 4},
        }, nil)
        ent._.job_data.last_punch = now
      end
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
