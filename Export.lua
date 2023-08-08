dofile(lfs.writedir()..[[Scripts\matrica10cII.lua]])
BIOS = {}; BIOS.LuaScriptDir = [[C:\Program Files\DCS-BIOS\dcs-lua\]]; BIOS.PluginDir = [[C:\Users\parab\AppData\Roaming/DCS-BIOS/Plugins\]]; if lfs.attributes(BIOS.LuaScriptDir..[[BIOS.lua]]) ~= nil then dofile(BIOS.LuaScriptDir..[[BIOS.lua]]) end --[[DCS-BIOS Automatic Setup]]
