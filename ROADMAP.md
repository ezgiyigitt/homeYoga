# Home Yoga — Yol Haritası

Bu doküman, projenin şu anki gerçek durumunu (kodu okuyarak çıkardığım) ve buradan
ileriye mantıklı, sıralı bir şekilde nasıl ilerlenmesi gerektiğini özetliyor.
Amaç, "bir hata çık, onu yama, başka hata çıkar" döngüsüne girmek yerine,
katman katman ve sırasıyla ilerlemek.

## 1. Şu an neyin nasıl çalıştığını anlamak

Projede aslında **iki ayrı sistem** var ve birbirinden bağımsız çalışıyorlar.
Ekranda "Generate Plan" yokken "Level 2 — Build" ve "1 Day Streak" görünmesinin
sebebi bir hata değil, bu iki sistemin bağımsız olması:

- **İlerleme / Gamification sistemi** (`ProgressRepositoryImpl`, `local_storage.dart`,
  `CompleteWorkoutUseCase`): XP, seviye, streak gibi değerler tamamen bir
  antrenmanı **tamamlamaktan** (`Explore` sekmesinden bir egzersiz bitirmekten)
  gelir. Haftalık AI planı üretilmiş olsun ya da olmasın, kullanıcı Explore'dan
  bir video tamamlarsa XP kazanır, seviye atlar, streak ilerler.
- **Haftalık AI Plan sistemi** (`GeneratePlanUseCase`, `PlanRepositoryImpl`,
  `PlanViewModel`): Gemini API'sini çağırıp 7 günlük bir program üretir ve
  cihazda (SharedPreferences) saklar. Bu, ilerleme sisteminden tamamen ayrı bir
  veri.

Yani "Test" kullanıcısı muhtemelen daha önce Explore'dan bir antrenman tamamlamış
(XP/seviye/streak oradan geliyor), ama henüz AI planı hiç üretilmemiş ya da
üretimi hata verdiği için kaydedilememiş. İkisi teknik olarak bağlı değil — bu
tasarım gereği. Bağlamak istenirse (örn. "önce plan üretilmeden antrenman
tamamlanamaz" ya da "seviye sadece plandaki günler tamamlanınca artsın") bu
ayrı bir ürün kararı ve aşağıdaki yol haritasında ayrı bir adım olarak yer alıyor.

## 2. Az önce yapılan düzeltme

`generate_plan_usecase.dart` içinde iki farklı hata sırayla çıktı:

1. `models/gemini-1.5-flash-latest is not found` → Google bu model adını emekliye
   ayırmış. `gemini-flash-latest` (her zaman güncel kalan resmi takma ad) ile
   değiştirildi.
2. `Server Error 503 — model is currently experiencing high demand` → Bu,
   Google tarafında geçici bir yoğunluk hatası (kodla ilgisi yok, ücretsiz
   kotalarda sık görülür). Kod artık:
   - Denemeler arasında daha uzun bekliyor (503/429 hatalarında 4, 8, 12 saniye),
   - Her denemede sırayla `gemini-flash-latest → gemini-2.5-flash → gemini-2.0-flash`
     modellerini deniyor, böylece tek bir modelin o an yoğun olması tüm özelliği
     durdurmuyor.

Bu, ilerideki benzer "model bulunamadı / model yoğun" hatalarına karşı da
dayanıklılık sağlıyor.

## 3. Önerilen sıralı yol haritası

Şu an dağınık görünmesinin sebebi, özelliklerin birbirinden bağımsız, ayrı
zamanlarda eklenmiş olması. Aşağıdaki sıra, kullanıcının gerçek akışını temel
alıyor (kayıt ol → profilini oluştur → plan al → antrenman yap → ilerlemeni gör):

1. **Onboarding → Profil** (zaten var): Kullanıcı bilgileri (seviye, hedefler,
   sıklık, ekipman) doğru kaydediliyor mu, tek noktadan doğrula.
2. **AI Plan üretimi** (az önce düzeltildi): Artık güvenilir çalışmalı. Bir
   sonraki adım: plan üretilirken kullanıcıya "üretiliyor / yeniden deneniyor"
   gibi ara durum göstermek (şu an sadece başarılı/başarısız var), böylece 503
   gibi geçici bir gecikmede kullanıcı "bozuk" sanmıyor.
3. **Plan ile Antrenman bağlantısı**: `PlanScreen`'deki bir günü tamamlamak
   (`toggleDayCompletion`) şu an sadece günün `isCompleted` bayrağını değiştiriyor;
   `CompleteWorkoutUseCase`'i (XP/streak) tetiklemiyor. Karar verilmesi gereken
   nokta: plan üzerinden bir gün tamamlamak da XP/streak vermeli mi? (Muhtemelen
   evet — şu an bu bağlantı eksik, "sırasız" hissinin asıl teknik kaynağı bu.)
4. **İlerleme ekranı tutarlılığı**: Home ve Progress ekranlarındaki
   seviye/streak/XP tek bir kaynaktan (ProgressRepository) geliyor — bu doğru.
   Sadece yukarıdaki adım 3 tamamlanınca "plan var ama seviye ilerlemiyor" ya da
   tam tersi kafa karışıklığı ortadan kalkar.
5. **Coach (sohbet) özelliği**: Bu da ayrı bir Gemini entegrasyonu
   (`coach_viewmodel.dart`) — plan üretimiyle aynı model/anahtar sorunlarını
   yaşayabilir, aynı model listesi/backoff mantığı oraya da taşınmalı.
6. **Supabase / bulut senkronizasyonu**: Kod, `SupabaseConfig.isConfigured`
   değilse otomatik olarak yerel depolamaya (SharedPreferences) düşüyor. Şu an
   muhtemelen sadece yerelde çalışıyor — bulut senkronizasyonu ne zaman aktif
   edilecek, ayrı bir karar.
7. **API anahtarı güvenliği**: `lib/core/constants/api_keys.dart` içinde anahtar
   açık duruyor. Repo public olacaksa veya paylaşılacaksa `--dart-define` ya da
   `.env` + `.gitignore` ile taşınmalı.

## 4. Şimdi ne yapmalı?

Önerim: Önce 2. maddedeki düzeltmeyi test et (uygulamayı yeniden başlatıp
"Generate Plan" dene). Çalışırsa, sırada **3. madde** var — yani plandaki bir
günü tamamlamanın gerçekten XP/streak vermesini bağlamak. Bunu ister misin,
yoksa önce başka bir maddeyi mi önceliklendirmek istersin?
