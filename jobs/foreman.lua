vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.jobs = vlw.jobs or {}
vlw.jobs.foreman = {}

local POOL = {"farmer", "miner", "builder"}

function vlw.jobs.foreman.step(ent)
  if not ent._.job_data.next_switch then
    ent._.job_data.next_switch = minetest.get_gametime() + 30
  end

  if minetest.get_gametime() >= ent._.job_data.next_switch then
    local new_job = POOL[math.random(1, #POOL)]
    ent:_set_job(new_job, {})
    ent._.job_data.next_switch = minetest.get_gametime() + 60
  end
end
