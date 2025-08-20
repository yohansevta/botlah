
-- Bootstrap: Load all modules
local modules = {
    'autosell',
    'dashboard',
    'enhancement',
    'fishing',
    'movement',
    'utils',
    'weather',
}

for _, mod in ipairs(modules) do
    local ok, loaded = pcall(require, 'modules.' .. mod)
    if ok and type(loaded) == 'table' and type(loaded.init) == 'function' then
        loaded.init()
    end
end

print('Bootstrap selesai. Semua modul dimuat.')

