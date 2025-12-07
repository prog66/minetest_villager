vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.idle = {}

function vlw.jobs.idle.step(ent)
  -- Idle workers just wander around
  -- The default wander behavior in init.lua will handle this
  return
end
