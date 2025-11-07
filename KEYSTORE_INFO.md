# TBCare Keystore Information

## 🔐 Release Signing Key Details

**PENTING: File ini TIDAK boleh di-commit ke Git!**

### Keystore File
- **Lokasi**: `android/app/tbcare-keystore.jks`
- **Alias**: `tbcare-upload`
- **Algorithm**: RSA
- **Key Size**: 2048 bit
- **Validity**: 10,000 days (~27 tahun)
- **Created**: 7 November 2025

### Distinguished Name (DN)
```
CN=TBCare
OU=Health
O=TBCare
L=Surabaya
ST=Jawa Timur
C=ID
```

### Passwords
**Store Password**: `tbcare2024`
**Key Password**: `tbcare2024`

---

## ⚠️ KEAMANAN & BACKUP

### Backup Keystore
**SANGAT PENTING!** Backup file keystore ke lokasi aman:

1. **Cloud Storage** (private, encrypted):
   - Google Drive (folder private)
   - Dropbox (encrypted folder)
   - OneDrive (private folder)

2. **External Storage**:
   - USB Drive (encrypted)
   - External HDD
   - Network storage

3. **Password Manager**:
   - Simpan passwords di password manager (1Password, Bitwarden, dll)

### ⛔ JANGAN:
- ❌ Upload keystore ke GitHub/public repo
- ❌ Share keystore via email/chat
- ❌ Store passwords in plain text di repo
- ❌ Kehilangan keystore (tidak bisa update app di Play Store!)

### ✅ HARUS:
- ✅ Backup keystore ke minimal 2 lokasi berbeda
- ✅ Store passwords secara aman
- ✅ Dokumentasikan lokasi backup
- ✅ Test keystore sebelum publish pertama kali

---

## 📝 Cara Menggunakan Keystore

### Build Release AAB
```bash
cd D:\PROJECT\PKM\apk\pkm
flutter build appbundle --release
```

### Build Release APK
```bash
flutter build apk --release
```

### Verify Signing
```bash
# Check AAB signature
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Check APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔄 Jika Keystore Hilang

**Konsekuensi:**
- ❌ Tidak bisa update aplikasi yang sudah di Play Store
- ❌ Harus publish sebagai aplikasi baru dengan package name berbeda
- ❌ User lama harus uninstall dan install ulang
- ❌ Kehilangan semua rating dan reviews

**Solusi:**
Tidak ada solusi! Makanya backup sangat penting!

---

## 📱 Google Play App Signing

Setelah upload AAB pertama kali ke Play Console:

1. Google Play akan generate **App Signing Key** (managed by Google)
2. Keystore kita (`tbcare-keystore.jks`) menjadi **Upload Key**
3. Google akan re-sign APK dengan App Signing Key mereka

**Manfaat:**
- ✅ Google backup App Signing Key
- ✅ Bisa reset Upload Key jika hilang (contact Google)
- ✅ Lebih aman

**Upload Key bisa direset, App Signing Key tidak bisa!**

---

## 📞 Emergency Contact

Jika ada masalah dengan keystore:
1. Check backup locations
2. Contact team members
3. Google Play Console → Setup → App signing (untuk reset upload key)

---

**Last Updated**: 7 November 2025
**Keystore Version**: 1.0
**Status**: Active - Production Use
