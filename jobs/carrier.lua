vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.carrier = {}

function vlw.jobs.carrier.step(ent)
  local pos = ent.object:get_pos()
  if not pos then return end
  vlw.world.push_to_nearest_chest(pos, ent._.inv, 24)
  ent:_set_job("idle", {})
end
