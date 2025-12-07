vlw = rawget(_G, "vlw") or {}
_G.vlw = vlw
vlw.inventory = vlw.inventory or {}

function vlw.inventory.add(inv, name, count)
  if not name or name == "" then return end
  local c = count or 1
  inv[name] = (inv[name] or 0) + c
end

function vlw.inventory.take(inv, name, count)
  local have = inv[name] or 0
  local want = count or 1
  local take = math.min(have, want)
  inv[name] = have - take
  if inv[name] <= 0 then
    inv[name] = nil
  end
  return take
end

function vlw.inventory.count(inv, name)
  return inv[name] or 0
end

function vlw.inventory.has(inv, name, count)
  return (inv[name] or 0) >= (count or 1)
end
