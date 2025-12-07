vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw

local FORMS = {}

minetest.register_chatcommand("vlw_ui", {
  description = "Ouvre l'UI de gestion du worker visé",
  privs = {interact = true},
  func = function(name)
    local player = minetest.get_player_by_name(name)
    if not player then
      return false, "Joueur introuvable"
    end

    local worker_name = vlw.modname .. ":worker"
    local obj = vlw.util.look_at_entity(player, 6.0, worker_name)
    if not obj then
      return false, "Vise un worker à moins de 6 blocs."
    end
    local ent = obj:get_luaentity()
    if not ent or not ent._ then
      return false, "Entité invalide."
    end

    local fs = ""
    fs = fs .. "size[6,5]"
    fs = fs .. "label[0.3,0.3;vl_workforce - Gestion]"
    fs = fs .. "label[0.3,0.8;Job actuel: " .. minetest.formspec_escape(ent._.job or "idle") .. "]"
    fs = fs .. "button[0.3,1.4;2.5,0.8;job_builder;Builder]"
    fs = fs .. "button[3.2,1.4;2.5,0.8;job_farmer;Farmer]"
    fs = fs .. "button[0.3,2.4;2.5,0.8;job_miner;Miner]"
    fs = fs .. "button[3.2,2.4;2.5,0.8;job_soldier;Soldier]"
    fs = fs .. "button[0.3,3.4;2.5,0.8;job_carrier;Carrier]"
    fs = fs .. "button[3.2,3.4;2.5,0.8;job_idle;Idle]"

    local key = name .. "#vlw_ui"
    FORMS[key] = obj

    minetest.show_formspec(name, "vlw:ui", fs)
    return true, "UI ouverte."
  end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "vlw:ui" then
    return
  end
  local name = player:get_player_name()
  local key = name .. "#vlw_ui"
  local obj = FORMS[key]
  FORMS[key] = nil
  if not obj then
    return
  end
  for field, _ in pairs(fields) do
    if field:sub(1, 4) == "job_" then
      local job = field:sub(5)
      vlw.set_job(obj, job, {})
      minetest.chat_send_player(name, "[vlw] Job -> " .. job)
      break
    end
  end
end)
