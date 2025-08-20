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

### Fixed Loader (RECOMMENDED)
Versi yang diperbaiki dengan error handling komprehensif:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/fixed_loader.lua"))()
```

### Improved Main Script
Versi yang diperbaiki dari main script:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/improved_main.lua"))()
```

### Original Main AutoFish Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/main.lua"))()
```

## Troubleshooting
Jika UI tidak muncul:
1. Gunakan **fixed_loader.lua** (RECOMMENDED) - ini akan mencoba load script original dengan error handling yang baik
2. Jika masih gagal, jalankan debug script terlebih dahulu
3. Cek console output untuk error messages  
4. Gunakan safe loader untuk loading dengan error handling
5. Pastikan executor mendukung semua API yang digunakan

## Status
✅ Safe loader berhasil menampilkan UI  
✅ Fixed loader dibuat untuk mengatasi masalah script original  
✅ Improved main script dengan error handling yang lebih baik