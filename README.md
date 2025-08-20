# Botlah - Roblox Exploit Scripts

Repository ini berisi script untuk Roblox exploit dengan fitur troubleshooting.

## Files:

### Debug Script
Untuk troubleshooting UI yang tidak muncul:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/debug_script.lua"))()
```

### Safe Loader  
Untuk loading script dengan error handling:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/safe_loader.lua"))()
```

### Main AutoFish Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/main.lua"))()
```

## Troubleshooting
Jika UI tidak muncul:
1. Jalankan debug script terlebih dahulu
2. Cek console output untuk error messages  
3. Gunakan safe loader untuk loading dengan error handling
4. Pastikan executor mendukung semua API yang digunakan