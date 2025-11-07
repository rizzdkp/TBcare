# Panduan Upload TBCare ke Google Play Console

## 📦 File untuk Upload

**Lokasi APK:**
```
D:\PROJECT\PKM\apk\pkm\build\app\outputs\flutter-apk\app-release.apk
```

**Ukuran:** 23.7 MB  
**Tanggal Build:** 7 November 2025

---

## 📋 Langkah Upload Internal Testing

### 1. Buka Google Play Console
- Login ke: https://play.google.com/console
- Pilih aplikasi **TBCare**

### 2. Navigasi ke Internal Testing
- Sidebar: **Testing** → **Internal testing**
- Klik **Create new release**

### 3. Upload APK
- Di bagian **App bundles and APKs**
- Drag & drop file `app-release.apk` atau klik **Upload**
- Tunggu proses upload selesai

### 4. Isi Detail Rilis

**Nama rilis (Release name):**
```
TBCare v1.0 - Internal Testing
```

**Catatan rilis (Release notes):**

Untuk Bahasa Indonesia (`<id>`):
```xml
<id>
Versi pertama TBCare untuk pengujian internal:

✨ Fitur Utama:
• Sistem deteksi TBC berbasis AI
• Fitur anamnesis pasien lengkap
• Riwayat pemeriksaan dengan detail
• Artikel berita kesehatan terkini
• Auto-sync data dari server
• UI/UX modern dengan logo baru TBCare

🔧 Perbaikan:
• Background splash screen #1FBABF
• Logo aplikasi yang konsisten
• Pengambilan data otomatis saat login
• Optimasi performa aplikasi

📱 Untuk Testing:
Silakan test semua fitur dan berikan feedback melalui channel internal testing.
</id>
```

### 5. Review dan Publish
- Scroll ke bawah
- Klik **Review release**
- Periksa semua detail
- Klik **Start rollout to Internal testing**

---

## ⚠️ Catatan Penting

### Warning yang Mungkin Muncul:
```
⚠️ APK ditandatangani dalam mode debug
```

**Status:** **BOLEH DIABAIKAN** untuk Internal Testing  
**Alasan:** Google Play menerima debug-signed APK untuk internal testing  
**Aksi:** Tidak perlu perbaikan untuk fase testing ini

### Untuk Production Release (Nanti):
- Perlu proper release signing dengan keystore production
- Wajib menggunakan Android App Bundle (.aab)
- Akan disetup setelah internal testing selesai

---

## 👥 Menambahkan Internal Testers

1. Di halaman **Internal testing**
2. Scroll ke **Testers**
3. Klik **Create email list** atau pilih list yang ada
4. Tambahkan email tester
5. Save dan share link testing ke tester

---

## 📊 Monitoring Testing

### Track Feedback:
- **Crashes & ANRs**: Monitor di Console → Quality
- **User feedback**: Lihat di Testing tab
- **Install stats**: Cek di Release dashboard

### Link Testing:
Setelah publish, dapatkan link testing dari:
- Internal testing page → **Testers** → **Copy link**
- Share link ini ke internal testers

---

## 🐛 Known Issues

### Build Issues (Sudah Resolved):
- ✅ Kotlin cache error (tidak menghentikan build)
- ✅ Username dengan spasi (workaround diterapkan)
- ✅ AAB build gagal (menggunakan APK untuk internal testing)

### Untuk Dicek saat Testing:
- [ ] Auto-fetch data saat login
- [ ] Auto-fetch data saat app startup
- [ ] Splash screen dengan logo dan warna baru
- [ ] Icon aplikasi sesuai logo
- [ ] Semua fitur anamnesis
- [ ] Riwayat pemeriksaan
- [ ] News feed

---

## 📝 Version Info

**Version Code:** Auto-generated dari pubspec.yaml  
**Version Name:** 1.0.0  
**Build Date:** 7 November 2025  
**Build Type:** Debug-signed (acceptable for internal testing)  
**Target SDK:** 34 (Android 14)  
**Min SDK:** 21 (Android 5.0)

---

## 🔄 Next Steps After Internal Testing

1. **Collect Feedback** dari internal testers
2. **Fix Bugs** yang ditemukan
3. **Setup Production Signing** (keystore production)
4. **Build AAB** untuk production
5. **Closed Testing** (alpha/beta)
6. **Production Release**

---

## 📞 Support

Jika ada masalah saat upload:
1. Screenshot error message
2. Check Google Play Console help center
3. Verify APK dengan: `aapt dump badging app-release.apk`

---

**Good luck with the internal testing! 🚀**
