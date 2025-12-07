vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.skins = vlw.skins or {}

local has_skins = minetest.get_modpath("mcl_skins") ~= nil and mcl_skins ~= nil

function vlw.skins.pick()
  if has_skins and mcl_skins.get_skin_list then
    local list = mcl_skins.get_skin_list()
    if type(list) == "table" and #list > 0 then
      return list[1]
    end
  end
  return "character.png"
end

function vlw.skins.pick_random()
  if has_skins and mcl_skins.get_skin_list then
    local list = mcl_skins.get_skin_list()
    if type(list) == "table" and #list > 0 then
      local i = math.random(1, #list)
      return list[i]
    end
  end
  return "character.png"
end

function vlw.skins.apply(obj, texture)
  local tex = texture or vlw.skins.pick()
  obj:set_properties({
    textures = {tex},
  })
end

function vlw.skins.init_entity_visual(obj, texture)
  local tex = texture or vlw.skins.pick()
  obj:set_properties({
    visual = "mesh",
    mesh = "character.b3d",
    visual_size = {x = 1, y = 1},
    textures = {tex},
  })
end
