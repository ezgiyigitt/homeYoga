# Home Yoga — "Bitmeyen Uygulama" Dönüşüm Planı

**Karar:** 7 seviyelik bitişli "Eğitim Yolculuğu" ana omurga olmaktan çıkıyor.
Yerine **Günlük Pratik + Sezonlar** modeli geliyor: her gün taze bir pratik,
arka planda 4 haftalık sezonlar, ve hiç dolmayan bir "ustalık" ekseni.
İçerik varsayımı: video kütüphanesi 9'dan 30+'a çıkacak.

---

## 1. Neden level sistemi tıkanıyor

Şu anki kod (`app_constants.dart`) seviyeyi iki şeye birden bağlamış:

- `levelThresholds` → XP eşikleri (2800 XP'de tavan var, sonra `levelEndXp = xp + 1` diye kaçamak yapılıyor)
- `levelCurriculum` → her seviyede **sabit 3 antrenman**

Yani toplam içerik 21 antrenmanla kilitli. Kullanıcı Level 7'yi bitirdiğinde
uygulamanın söyleyecek sözü kalmıyor. Ayrıca `UserProgressEntity.levelName`
seviye dizisinin sonunda `clamp` ile takılı kalıyor — yani sistem zaten
"bitişi" tasarım borcu olarak taşıyor.

Sonsuz bir uygulamada **ilerleme, tüketilen içerikten değil, tekrar eden
davranıştan** gelmeli. Değişimin özü bu tek cümle.

---

## 2. Yeni model: üç katman

```
┌─────────────────────────────────────────────┐
│  KATMAN 3 — USTALIK (hiç bitmez)            │
│  Beceri bazlı: Esneklik, Güç, Denge, Nefes  │
│  Her pratik ilgili becerilere puan yazar    │
├─────────────────────────────────────────────┤
│  KATMAN 2 — SEZON (28 günlük döngü)         │
│  Tema + hedef + sezon rozeti; biter, yenisi │
│  otomatik başlar. Anlatı ve yenilik burada  │
├─────────────────────────────────────────────┤
│  KATMAN 1 — BUGÜN (günlük)                  │
│  Tek kart: "Bugünün Pratiği". Kullanıcının  │
│  gördüğü ekranın %80'i burası               │
└─────────────────────────────────────────────┘
```

**Katman 1 — Bugünün Pratiği.** Ana ekran artık "Level 2 — Build" değil,
tek bir büyük kart: bugünün pratiği, süresi, teması, "Başla" butonu.
Kullanıcı seçim yorgunluğu yaşamaz; isterse "Başka bir şey öner" ile
kartı değiştirebilir (günde 2 hakkı — sonsuz zaplama alışkanlığı bozuyor).

**Katman 2 — Sezonlar.** 28 günlük temalı bloklar: *"Sabah Uyanışı"*,
*"Omurga Sağlığı"*, *"Güç Ayı"*, *"Yavaş Akış"*. Sezon başında kullanıcı
hedefini seçer (haftada 3 gün / 4 gün...), sezon sonunda özet ekranı +
rozet + otomatik bir sonraki sezon. Bitiş hissi verir ama uygulama bitmez.
Level sisteminin duygusal işlevini (hedef, kapanış, kutlama) sezonlar devralır.

**Katman 3 — Ustalık.** 4 beceri ekseni: **Esneklik, Güç, Denge, Nefes/Sakinlik**.
Her egzersizin bu eksenlere katkı ağırlığı olur (`exercise.skill_weights`).
Her eksen kendi içinde tavan olmadan ilerler; kullanıcı Level yerine
"Esneklik 3. kuşak" gibi bir kimlik kazanır. Radar grafik olarak gösterilir —
bu tek görsel, sonsuzluğu somutlaştıran şey olacak.

---

## 3. Neyin yerine ne geçiyor (kod eşlemesi)

| Şu an | Yeni | Dosya |
|---|---|---|
| `levelThresholds` (7 eşik, tavanlı) | Formülsel eşik: `xpNeeded(n) = 150 + 50*n` — sonsuz | `app_constants.dart` |
| `levelNames` (7 isim) | Sezon temaları listesi + döngüsel isimlendirme | yeni `season_constants.dart` |
| `levelCurriculum` (21 sabit antrenman) | Katalogdan kural bazlı seçim | `daily_practice_usecase.dart` (yeni) |
| `LevelJourneyCard` | `TodayPracticeCard` | `home/widgets/` |
| `LevelWorkoutsBottomSheet` | `SeasonProgressSheet` | `home/widgets/` |
| `GeneratePlanUseCase` (7 günü tek seferde üretir) | Aynı motor, ama **günlük** çalışır ve geçmişi dikkate alır | `generate_plan_usecase.dart` |
| `UserProgressEntity.level` | `totalPractices`, `seasonNumber`, `skillPoints{}` | `user_progress_entity.dart` |

**Seviye tamamen silinmiyor:** XP ve seviye rozeti kalabilir, ama artık
"içeriğin kilidi" değil, sadece bir sayaç. Formülsel eşikle sonsuza gider.
Bu, mevcut ekranları kırmadan geçiş yapmayı sağlar.

---

## 4. Günlük pratik nasıl üretilir (içerik kıtlığına karşı asıl çözüm)

30 video bile tek başına sonsuz değildir. Sonsuzluk **kombinasyondan** gelir.
`DailyPracticeUseCase` şu girdilerle seçim yapar:

1. **Sezon teması** → hangi kategoriler ağırlıklı (örn. "Omurga Ayı" → Stretching + Yoga)
2. **Haftanın günü** → hafta içi kısa (10–15 dk), hafta sonu uzun (20–30 dk)
3. **Son 14 günün geçmişi** → yakın zamanda yapılan egzersiz tekrar gelmez (cooldown)
4. **Beceri dengesi** → en zayıf beceri ekseni %40 ağırlıkla seçilir (kullanıcı "eksiğini kapatıyorum" hisseder)
5. **Enerji durumu (opsiyonel)** → "Bugün nasılsın?" 3 seçenek: yorgun / normal / enerjik → süre ve yoğunluk ayarı

Aynı 30 video, bu 5 boyutla birleşince pratik olarak tekrarsız bir akış verir.
Ek olarak **varyasyon katmanları** içerik üretmeden çeşitlilik yaratır:
tutuş süresi, tekrar sayısı, sıra değişimi, "nefes odaklı" / "güç odaklı" mod.

> Kritik kural: bir egzersiz için **cooldown** ve **çeşitlilik** mantığı en baştan
> yazılmalı. Kütüphane 30'a çıkınca değil, 9'ken. Yoksa tekrar hissi ilk haftada
> uygulamayı öldürür.

---

## 5. Sürekliliği besleyen mekanikler

| Mekanik | Ne yapar | Not |
|---|---|---|
| **Streak (mevcut)** | Ana metrik olur | **Streak Freeze** ekle: haftada 1 kaçırma seriyi bozmasın. Katı streak, kaybedince kullanıcıyı tamamen kaybettiriyor |
| **Haftalık hedef** | "Bu hafta 3/4" halkası | Günlük değil haftalık hedef, esneklik verir; gerçek hayata uyar |
| **Sezon rozeti** | 28 gün sonunda kalıcı ödül | Profilde koleksiyon olarak birikir — geriye dönük "ne kadar yol aldım" hissi |
| **Milestone'lar** | 10., 50., 100., 365. pratik | Sonsuz sistemde ara kutlama şart |
| **Yıllık takvim ısı haritası** | GitHub tarzı nokta grid | Sonsuzluğun en güçlü görsel kanıtı; ucuz ama etkili |
| **Nazik hatırlatma** | Tercih edilen saatte tek bildirim | `preferredTimes` zaten onboarding'de toplanıyor, kullanılmıyor |

---

## 6. Uygulama sırası (önerilen)

### Faz 0 — Temizlik (önce bu)
- ROADMAP'teki **3. madde** hâlâ açık: plandan gün tamamlamak XP/streak vermiyor.
  Sonsuz sistem tek bir ilerleme kaynağı üzerine kurulacak — bu bağ önce kurulmalı.
- `api_keys.dart` içindeki anahtarı `--dart-define`'a taşı.

### Faz 1 — Veri modeli (kullanıcıya görünmez, hepsinin temeli)
- `UserProgressEntity`'ye: `totalPractices`, `seasonNumber`, `seasonDay`,
  `skillPoints: Map<String,int>`, `practiceHistory: List<{exerciseId, date}>`
- `ExerciseEntity`'ye: `skillWeights: Map<String,double>`, `intensity: int`
- Supabase tarafında `practice_log` tablosu (şu an her şey SharedPreferences'ta —
  geçmişe dayalı seçim yapacaksan bu veri kalıcı olmalı)
- `levelThresholds` listesini formüle çevir

### Faz 2 — Günlük pratik motoru
- `DailyPracticeUseCase`: yukarıdaki 5 girdiyle seçim + cooldown
- `TodayPracticeCard` ile `LevelJourneyCard`'ı değiştir
- "Başka bir şey öner" (günde 2 hak)

### Faz 3 — Sezonlar
- `season_constants.dart` + 6–8 tema (döngüsel kullanılır, biter gibi görünmez)
- Sezon başlangıç ekranı (hedef seç) ve bitiş özeti + rozet
- Otomatik sezon geçişi

### Faz 4 — Ustalık ve görselleştirme
- Beceri radar grafiği (Progress ekranı)
- Yıllık ısı haritası takvimi
- Rozet koleksiyonu (Profil)

### Faz 5 — Alışkanlık cilası
- Streak Freeze
- Bildirimler
- Milestone kutlama animasyonları

---

## 7. Geçiş (mevcut kullanıcılar)

Mevcut kullanıcının Level 2 / X XP'si silinmemeli:
- `level` → `seasonNumber` başlangıcı olarak eşlenir (Lv2 → Sezon 2)
- `xp` aynen korunur, formülsel eşiğe geçilir
- Tamamlanan 9 videonun kaydı → `practiceHistory`'ye seed edilir (cooldown çalışsın diye)
- Uygulama ilk açılışta tek seferlik bir "Yeni bir şey denedik" ekranı gösterir

---

## 8. İçerik planı (30+ video çekilecekse)

Sonsuz motorun düzgün çalışması için kütüphanenin **dengeli** olması lazım,
çok olması değil. Hedef dağılım:

| Eksen | Kısa (5–10 dk) | Orta (15–20 dk) | Uzun (25–30 dk) |
|---|---|---|---|
| Esneklik | 3 | 3 | 2 |
| Güç | 3 | 3 | 2 |
| Denge | 2 | 3 | 1 |
| Nefes/Sakinlik | 3 | 2 | 1 |

≈ 28 video. Her eksende her süre bandında en az 2 seçenek olması, cooldown
mantığının tıkanmadan çalışması için kritik. Çekim sırasını da buna göre
planlamak, "5 tane uzun esneklik videosu var ama kısa güç videosu yok" gibi
kör noktaları önler.

---

## 9. Riskler

- **Amaçsızlık hissi:** Sonsuz sistemlerin en büyük tehlikesi. Panzehir sezonlar —
  her 28 günde net bir başlangıç ve bitiş.
- **Tekrar:** Cooldown + varyasyon katmanları en baştan yazılmalı.
- **Streak baskısı:** Yoga uygulamasında suçluluk hissi ters teper. Streak Freeze
  ve haftalık hedef (günlük değil) bunun için var.
- **Kapsam kayması:** Faz 1–2 tek başına uygulamayı "bitmeyen" yapar. Faz 3–5
  olmadan da yayınlanabilir. Önce oraya kadar götürmek en sağlıklısı.
