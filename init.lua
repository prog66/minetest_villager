local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw

vlw.modname = modname
vlw.modpath = modpath
vlw.jobs = vlw.jobs or {}
vlw.blueprints = vlw.blueprints or {}

vlw.SETTINGS = {
  think_hz_near = 5,
  think_hz_far  = 1,
  near_dist     = 32,
  walk_speed    = 2.8,
  run_speed     = 3.6,
  path_searchdistance = 64,
  path_jump     = 1,
  path_drop     = 2,
  allow_prefix = {"mcl_", "vl_"},
}

dofile(modpath .. "/core/util.lua")
dofile(modpath .. "/core/perception.lua")
dofile(modpath .. "/core/nav.lua")
dofile(modpath .. "/core/world.lua")
dofile(modpath .. "/core/inventory.lua")
dofile(modpath .. "/core/scheduler.lua")
dofile(modpath .. "/core/storage.lua")
dofile(modpath .. "/core/skins.lua")

dofile(modpath .. "/blueprints/hut.lua")
dofile(modpath .. "/blueprints/farm_9x9.lua")

dofile(modpath .. "/jobs/builder.lua")
dofile(modpath .. "/jobs/farmer.lua")
dofile(modpath .. "/jobs/miner.lua")
dofile(modpath .. "/jobs/soldier.lua")
dofile(modpath .. "/jobs/carrier.lua")
dofile(modpath .. "/jobs/foreman.lua")

dofile(modpath .. "/ui.lua")

local WORKER = modname .. ":worker"

local function default_state()
  return {
    job = "idle",
    job_data = {},
    inv = {},
    target = nil,
    blueprint = nil,
    last_pos = nil,
    path = nil,
    path_i = 2,
    think_interval = 1 / (vlw.SETTINGS.think_hz_near or 5),
  }
end

minetest.register_entity(WORKER, {
  initial_properties = {
    physical = true,
    collide_with_objects = true,
    collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
    visual = "mesh",
    mesh = "character.b3d",
    textures = {"character.png"},
    visual_size = {x = 1, y = 1},
    hp_max = 20,
  },

  on_activate = function(self, staticdata, dtime_s)
    self._ = default_state()
    local restored = vlw.storage.restore_static(staticdata)
    if restored then
      for k, v in pairs(restored) do
        self._[k] = v
      end
    end
    self.object:set_acceleration({x = 0, y = -9.81, z = 0})
    if vlw.skins and vlw.skins.init_entity_visual then
      vlw.skins.init_entity_visual(self.object)
    end
  end,

  get_staticdata = function(self)
    return vlw.storage.dump_static({
      job = self._.job,
      job_data = self._.job_data,
      inv = self._.inv,
      blueprint = self._.blueprint,
    })
  end,

  _set_job = function(self, jobname, data)
    self._.job = jobname
    self._.job_data = data or {}
  end,

  _near_player = function(self)
    local pos = self.object:get_pos()
    local players = minetest.get_connected_players()
    local best, bestd
    for _, p in ipairs(players) do
      local d = vector.distance(pos, p:get_pos())
      if not best or d < bestd then
        best = p
        bestd = d
      end
    end
    return best, bestd or 9999
  end,

  on_step = function(self, dtime)
    local player, dist = self:_near_player()
    local hz = vlw.SETTINGS.think_hz_far or 1
    if dist <= (vlw.SETTINGS.near_dist or 32) then
      hz = vlw.SETTINGS.think_hz_near or 5
    end
    self._.think_interval = 1 / hz
    self._.next_think = (self._.next_think or 0) - dtime
    if self._.next_think > 0 then
      return
    end
    self._.next_think = self._.think_interval

    if vlw.nav.follow_path(self, dtime) then
      return
    end

    local job = vlw.jobs[self._.job]
    if job and job.step then
      job.step(self)
      return
    end

    if (not self._.wander_goal) or (vector.distance(self.object:get_pos(), self._.wander_goal) < 1.0) then
      local p = self.object:get_pos()
      self._.wander_goal = vector.round(vector.add(p, {
        x = math.random(-8, 8),
        y = 0,
        z = math.random(-8, 8),
      }))
      vlw.nav.pathfind_to(self, self._.wander_goal)
    end
  end,
})

function vlw.set_job(objref, jobname, data)
  if not objref then return end
  local ent = objref:get_luaentity()
  if not ent or not ent._set_job then
    return
  end
  ent:_set_job(jobname, data)
end

minetest.register_chatcommand("vlw_spawn", {
  params = "",
  description = "Spawn un worker VoxeLibre",
  privs = {interact = true},
  func = function(name, param)
    local pl = minetest.get_player_by_name(name)
    if not pl then
      return false, "Joueur introuvable"
    end
    local pos = vector.add(pl:get_pos(), {x = 1, y = 0, z = 1})
    minetest.add_entity(pos, WORKER)
    return true, "Worker spawné."
  end,
})

minetest.register_chatcommand("vlw_job", {
  params = "<builder|farmer|miner|soldier|carrier|foreman|idle>",
  description = "Assigner un job au worker pointé",
  privs = {interact = true},
  func = function(name, param)
    local player = minetest.get_player_by_name(name)
    if not player then
      return false, "Joueur introuvable"
    end
    local obj = vlw.util.look_at_entity(player, 6.0, WORKER)
    if not obj then
      return false, "Vise un worker à moins de 6 blocs."
    end
    param = vlw.util.trim(param or "")
    if param == "" then
      return false, "Précise un job."
    end
    if not vlw.jobs[param] then
      return false, "Job inconnu: " .. param
    end
    vlw.set_job(obj, param, {})
    return true, "Job défini: " .. param
  end,
})
