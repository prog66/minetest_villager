--[[
  modutil/portable.lua
  
  This file provides cross-platform compatibility utilities for the mod.
  It exists for backwards compatibility with older versions of the mod.
  
  Note: The current version (vl_workforce) does not require this file,
  but it's included to prevent errors if users have outdated references.
]]

-- Return an empty table or provide minimal utilities
-- This ensures the mod doesn't crash if this file is loaded by older code
return {}
