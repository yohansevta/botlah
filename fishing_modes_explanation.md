# Perbedaan Mode Fishing AI: Smart vs Secure

Berdasarkan analisis kode dari script original, berikut adalah perbedaan antara mode **Smart AI** dan **Secure** dalam sistem AutoFishing:

## 🧠 Smart AI Mode (Default)

### Karakteristik:
- **Mode default** dari script
- **Lebih canggih** dengan animation awareness
- **Timing yang realistis** dan bervariasi
- **Rod orientation fixing** yang intensif
- **Perfect cast chance**: 70% (dapat dikonfigurasi via `safeModeChance`)

### Fitur Khusus:
1. **Animation Monitoring**: 
   - Memantau animasi karakter secara real-time
   - Menyesuaikan timing berdasarkan fase animasi
   - Deteksi sukses fishing via animasi

2. **5 Fase Fishing Cycle**:
   ```
   1. Starting/Equip - Persiapan dan equip rod
   2. Charging - Charge rod dengan timing realistis  
   3. Casting - Mini-game simulation
   4. Waiting - Menunggu ikan (2-4 detik)
   5. Completing - Finalisasi dan reel
   ```

3. **Realistic Timing System**:
   ```lua
   charging: 0.8-1.5 detik
   casting: 0.2-0.4 detik  
   waiting: 2.0-4.0 detik
   reeling: 1.0-2.5 detik
   ```

4. **Rod Orientation Fixing**:
   - Continuous fixing selama charging phase
   - Fixing sebelum setiap fase penting
   - Frekuensi fixing: setiap 0.02 detik saat charging

5. **Perfect Cast Logic**:
   ```lua
   Perfect coordinates: x=-1.238, y=0.969
   Random coordinates: x=random(-1,1), y=random(0,1)
   Perfect timing: GetServerTime()
   Random timing: GetServerTime() + random(0-0.5)
   ```

## 🔒 Secure Mode

### Karakteristik:
- **Mode aman** untuk menghindari deteksi
- **Lebih sederhana** dan predictable
- **Timing yang konsisten**
- **Perfect cast chance**: 70% (sama dengan Smart)
- **Cooldown protection** built-in

### Fitur Khusus:
1. **Cooldown Protection**:
   - Cek cooldown sebelum setiap cycle
   - Mencegah spam actions yang mencurigakan

2. **Simplified 4 Fase**:
   ```
   1. Equip - Equip rod dengan error handling
   2. Charge - Standard timing (0.1 detik)
   3. Minigame - Same perfect/random logic
   4. Complete - Finish dengan error handling
   ```

3. **Fixed Timing**:
   ```lua
   Charge wait: 0.1 detik (fixed)
   Fishing wait: 1.3 detik (fixed)
   ```

4. **Error Handling**:
   - Setiap remote call dibungkus dengan pcall
   - Console logging untuk debugging
   - Graceful failure handling

5. **Perfect Cast Logic** (sama dengan Smart):
   ```lua
   Perfect: timestamp=9999999999, x=-1.238, y=0.969  
   Random: timestamp=tick()+random(), x=random(-1,1), y=random(0,1)
   ```

## ⚡ Perbandingan Performa

| Aspek | Smart AI | Secure |
|-------|----------|---------|
| **Kecepatan** | Lebih lambat (realistic timing) | Lebih cepat (fixed timing) |
| **Detektabilitas** | Rendah (human-like) | Sangat rendah (minimal) |
| **Success Rate** | Tinggi (animation aware) | Medium (standard) |
| **Resource Usage** | Tinggi (continuous monitoring) | Rendah (simple logic) |
| **Kompleksitas** | Tinggi (5 fase + monitoring) | Rendah (4 fase simple) |

## 🎯 Konfigurasi Penting

```lua
Config = {
    mode = "smart",           -- "smart" atau "secure"
    safeModeChance = 70,      -- Chance untuk perfect cast (%)
    enabled = false,          -- AutoFishing on/off
    autoRecastDelay = 0.4,    -- Delay antar cycle
}
```

## 📊 Rekomendasi Penggunaan

### Gunakan **Smart AI** jika:
- Ingin hasil fishing maksimal
- Tidak masalah dengan resource usage tinggi
- Ingin timing yang natural/human-like
- Server tidak terlalu strict dengan detection

### Gunakan **Secure** jika:
- Khawatir dengan anti-cheat detection
- Ingin resource usage minimal
- Lebih fokus ke safety daripada speed
- Server memiliki anti-cheat yang ketat

## 🔧 Tips Optimasi

1. **Smart Mode**: 
   - Turunkan `safeModeChance` ke 60-80% untuk lebih natural
   - Monitor console untuk animation feedback

2. **Secure Mode**:
   - Gunakan di server dengan player banyak
   - Kombinasikan dengan anti-AFK features

Kedua mode menggunakan sistem **location-based fish simulation** yang sama untuk fallback jika deteksi ikan gagal.
