vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.storage = vlw.storage or {}

function vlw.storage.dump_static(tbl)
  return minetest.serialize(tbl or {})
end

function vlw.storage.restore_static(s)
  if not s or s == "" then
    return nil
  end
  local ok, data = pcall(minetest.deserialize, s)
  if not ok then
    return nil
  end
  return data
end
