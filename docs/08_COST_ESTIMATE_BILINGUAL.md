# LMS — Full System Cost Estimate (Cloud vs On-Premise)
# تقدير تكلفة نظام إدارة التعلم الكامل (سحابي مقابل محلي)

**Target size / الحجم المستهدف:** ~50 active users (طالب/مدرس) — أكاديمية صغيرة
**Currency / العملة:** Egyptian Pound (EGP / جنيه مصري)
**Assumed FX rate / سعر الصرف المفترض:** 1 USD ≈ 50 EGP (2026 estimate)
**Last updated / آخر تحديث:** 2026-06-03

> Prices are realistic 2026 market estimates for Egypt. Actual quotes vary by vendor, hardware availability, and USD rate. All software-subscription prices are converted from USD at 50 EGP/USD.
>
> الأسعار تقديرات سوقية واقعية لعام 2026 في مصر. الأسعار الفعلية تختلف حسب المورّد وتوافر العتاد وسعر الدولار. كل أسعار الاشتراكات محوّلة من الدولار بسعر 50 جنيه/دولار.

---

# PART 1 — ENGLISH

## 1. Required features (client request)

| # | Feature | Status in current app | Notes |
|---|---------|----------------------|-------|
| 1 | Register & Login (role-based) | ✅ Built | Admin / Instructor / Student |
| 2 | Lecturers (instructors) management | ✅ Built | Roles, profiles |
| 3 | Lectures & sessions (courses/modules/lessons) | ✅ Built | Full course editor |
| 4 | Students management | ✅ Built | Enrollment, roster |
| 5 | Materials (videos, PDFs, audio) with access control | ✅ Built | RLS-protected storage |
| 6 | Tasks / assignments | ⏳ Phase 2 | Not yet built |
| 7 | Exams / quizzes | ⏳ Phase 2 | Not yet built |
| 8 | Online payments | ⏳ Phase 2 | Needs Paymob/Fawry/Stripe |
| 9 | Online course booking | 🟡 Partial | Enrollment exists; paid booking = Phase 2 |
| 10 | Live online sessions (streaming) | 🟡 Link-only | Meeting URL works; embedded live = Phase 2 |

**Conclusion:** Core LMS (1–5) is already built. Items 6–10 are the remaining work that affects both cost and programmer effort.

---

## 2. The two infrastructure options

### Option A — Cloud (recommended for 50 users)
You rent managed services. No hardware to buy or maintain. Pay monthly. Scales instantly.

### Option B — On-Premise (own server in a data center / office)
You buy a physical server + disks, host it yourself, pay for internet, electricity, and maintenance.

> **Key fact about LIVE streaming:** Streaming live video to ~50 concurrent viewers requires high, stable **upload** bandwidth (≈ 5–15 Mbps per HD stream sent out, multiplied by viewers unless you use an SFU/CDN). In Egypt, business upload bandwidth is the main bottleneck for on-premise. For live, a specialized service (Zoom / Google Meet / 100ms / LiveKit Cloud / Agora) is almost always cheaper and more reliable than self-hosting.

---

## 3. OPTION A — Cloud minimum cost (50 users)

### 3.1 Monthly recurring (software & services)

| Service | What it does | Plan | USD/mo | EGP/mo |
|---------|-------------|------|-------:|-------:|
| Supabase | Database + Auth + Storage + API | Free tier (ok for 50) | $0 | 0 |
| Supabase (when you grow) | Same, higher limits | Pro | $25 | 1,250 |
| Web hosting | Host the web app | Vercel / Cloudflare Pages (Free) | $0 | 0 |
| Domain name | yoursite.com | annual ÷ 12 | ~$1 | ~50 |
| Email (transactional) | Verify, reset, alerts | Resend / Brevo free tier | $0 | 0 |
| **Live sessions** | Live classes | Zoom Pro **or** Google Workspace Starter | $13–15 | 650–750 |
| Video storage/streaming | Recorded lessons | Bunny.net Stream (~50 GB + delivery) | $5–10 | 250–500 |
| Payment gateway | Collect fees | Paymob / Fawry (per-transaction) | ~2.5–3% per payment | per payment |

**Minimum realistic cloud cost (using free tiers + paid live + video):**
- **Low (free Supabase + Google Meet free):** ≈ **300–800 EGP / month**
- **Comfortable (Supabase Pro + Zoom + Bunny):** ≈ **2,200–2,750 EGP / month**

**Per year:** ≈ **3,600 – 33,000 EGP / year** depending on tier.

### 3.2 One-time cloud costs

| Item | When needed | EGP (one-time) |
|------|-------------|---------------:|
| Google Play Console | If publishing Android app | ~1,250 (one-time) |
| Apple Developer Program | If publishing iOS app | ~5,000 / year |
| SSL certificate | Included free (Let's Encrypt / host) | 0 |

> If you only ship a **web app** (works on phone browsers too), you can skip the app-store fees entirely → **0 EGP one-time**.

### 3.3 Cloud — bottom line for 50 users

| Scenario | Setup (one-time) | Running (per month) | Running (per year) |
|----------|-----------------:|--------------------:|-------------------:|
| **Web only, lean** | ~0 EGP | ~300–800 EGP | ~3,600–9,600 EGP |
| **Web + mobile, comfortable** | ~6,250 EGP | ~2,200–2,750 EGP | ~26,000–33,000 EGP |

✅ **Recommended for 50 users.** Lowest entry cost, no maintenance, reliable live streaming.

---

## 4. OPTION B — On-Premise minimum cost (50 users)

### 4.1 One-time hardware

| Item | Spec (enough for 50 users) | EGP (one-time) |
|------|----------------------------|---------------:|
| Server (tower) | Xeon / Core i7, 32–64 GB RAM | 60,000–120,000 |
| or budget alternative | Mini-PC / refurbished workstation | 25,000–45,000 |
| SSD (system + database) | 1 TB NVMe | 4,000–7,000 |
| HDD (video/material storage) | 2 × 4 TB in RAID 1 (mirror) | 12,000–18,000 |
| UPS (power backup) | 1500 VA | 6,000–10,000 |
| Network gear | Router + managed switch | 3,000–8,000 |
| **Total hardware** | | **~85,000 – 163,000 EGP** |
| Budget build total | | **~50,000 – 80,000 EGP** |

### 4.2 Monthly recurring

| Item | Detail | EGP/mo |
|------|--------|-------:|
| Business internet | Static IP + high upload (critical) | 1,500–4,000 |
| Electricity | Server ~200–400 W running 24/7 | 500–1,200 |
| Offsite backup | Cloud backup of DB + files | 250–500 |
| Domain + SSL | annual ÷ 12 | ~50 |
| Cooling / maintenance | Room cooling, spare parts fund | 300–800 |
| **Live streaming** | Still recommend a paid service* | 650–750 |
| **Total monthly** | | **~3,250 – 7,300 EGP / month** |

\* Self-hosting live video (e.g. Jitsi) is "free" software but for ~50 concurrent viewers it needs very high upload bandwidth and a strong server, which usually costs more than a managed service and is less reliable.

### 4.3 On-premise — bottom line for 50 users

| | Setup (one-time) | Running (per month) | Running (per year) |
|-|-----------------:|--------------------:|-------------------:|
| **Budget build** | ~50,000–80,000 EGP | ~3,250 EGP | ~39,000 EGP |
| **Proper server** | ~85,000–163,000 EGP | ~5,000–7,300 EGP | ~60,000–88,000 EGP |

⚠️ Higher upfront cost, you handle maintenance/security/backups, and live streaming is harder. **Not recommended for only 50 users** unless you already own hardware or have a data-policy requirement to keep data on-site.

---

## 5. Cloud vs On-Premise — comparison

| Factor | Cloud (A) | On-Premise (B) |
|--------|-----------|----------------|
| Upfront cost | Almost 0 | 50,000–163,000 EGP |
| Monthly cost (50 users) | 300–2,750 EGP | 3,250–7,300 EGP |
| Setup time | Hours | Days–weeks |
| Maintenance | Vendor handles it | You handle it |
| Live streaming | Easy (managed) | Hard (bandwidth limited) |
| Scaling to 200+ users | Click to upgrade | Buy more hardware |
| Backups | Automatic | You configure |
| Best for | Small/medium academies | Large org with IT team / data residency law |

**Recommendation for 50 users: Cloud (Option A).** It is dramatically cheaper in year 1 and removes all hardware risk.

---

## 6. Programmer cost (separate, as requested)

The infrastructure costs above **do not include software development**. The core app already exists; the remaining Phase-2 features (tasks, exams, payments, paid booking, embedded live) need a developer.

### 6.1 To finish the remaining features (one-time project)

| Work package | Effort | EGP (freelance, Egypt) |
|--------------|--------|----------------------:|
| Tasks / assignments + grading | ~1–2 weeks | 15,000–35,000 |
| Exams / quizzes (auto-grade) | ~2 weeks | 20,000–40,000 |
| Online payments (Paymob/Fawry) | ~1–2 weeks | 15,000–35,000 |
| Paid course booking flow | ~1 week | 10,000–20,000 |
| Live streaming integration (100ms/Agora/Zoom SDK) | ~1–2 weeks | 20,000–45,000 |
| Testing + deploy (web + mobile) | ~1 week | 10,000–20,000 |
| **Total to complete full system** | ~6–9 weeks | **≈ 90,000 – 195,000 EGP** |

### 6.2 Ongoing developer support (optional retainer)

| Option | EGP/month |
|--------|----------:|
| Part-time maintenance & bug fixes | 5,000–15,000 |
| Full-time junior/mid Flutter dev (in-house) | 15,000–40,000 |

> Rates assume a freelance/junior-to-mid Flutter + Supabase developer in Egypt (2026). Agencies cost 2–4× more.

---

## 7. Recommended package for a 50-student academy

| Line item | Choice | Cost |
|-----------|--------|------|
| Infrastructure | **Cloud (Option A), web + mobile** | ~2,200–2,750 EGP / month |
| App-store fees | Android only (skip iOS at first) | ~1,250 EGP one-time |
| Finish full features | Freelance project | ~90,000–195,000 EGP one-time |
| Maintenance | Part-time retainer | ~5,000–10,000 EGP / month |

**Year-1 total (excluding dev): ~27,000–34,000 EGP**
**Year-1 total (including dev once + retainer): ~150,000–315,000 EGP**

---

# الجزء الثاني — العربية

## 1. المميزات المطلوبة (طلب العميل)

| # | الميزة | الحالة في التطبيق الحالي | ملاحظات |
|---|--------|--------------------------|---------|
| 1 | تسجيل ودخول حسب الدور | ✅ تم | مدير / مدرس / طالب |
| 2 | إدارة المحاضرين | ✅ تم | أدوار وملفات شخصية |
| 3 | المحاضرات والجلسات (دورات/وحدات/دروس) | ✅ تم | محرر دورات كامل |
| 4 | إدارة الطلاب | ✅ تم | تسجيل وقوائم |
| 5 | المواد (فيديو/PDF/صوت) مع تحكم بالوصول | ✅ تم | تخزين محمي بـ RLS |
| 6 | المهام / الواجبات | ⏳ المرحلة الثانية | لم تُبنَ بعد |
| 7 | الاختبارات / الكويزات | ⏳ المرحلة الثانية | لم تُبنَ بعد |
| 8 | الدفع الإلكتروني | ⏳ المرحلة الثانية | يحتاج Paymob/Fawry/Stripe |
| 9 | حجز الدورات أونلاين | 🟡 جزئي | التسجيل موجود؛ الحجز المدفوع لاحقًا |
| 10 | الجلسات المباشرة (بث حي) | 🟡 رابط فقط | رابط الاجتماع يعمل؛ البث المدمج لاحقًا |

**الخلاصة:** النواة الأساسية (1–5) مبنية بالفعل. البنود 6–10 هي العمل المتبقي الذي يؤثر على التكلفة وجهد المبرمج.

---

## 2. الخياران للبنية التحتية

### الخيار (أ) — السحابة (موصى به لـ 50 مستخدم)
تستأجر خدمات مُدارة. لا عتاد تشتريه أو تصونه. دفع شهري. يتوسّع فورًا.

### الخيار (ب) — محلي (سيرفر خاص في داتا سنتر / مكتب)
تشتري سيرفرًا فعليًا + أقراص، وتستضيفه بنفسك، وتدفع للإنترنت والكهرباء والصيانة.

> **حقيقة مهمة عن البث المباشر:** بث فيديو حي لـ 50 مشاهدًا في نفس الوقت يتطلب سرعة **رفع (upload)** عالية وثابتة (حوالي 5–15 ميجابت/ث لكل بث HD مضروبة في عدد المشاهدين ما لم تستخدم SFU/CDN). في مصر، سرعة الرفع هي العائق الأساسي للحل المحلي. لذلك للبث المباشر تكون الخدمة المتخصصة (Zoom / Google Meet / 100ms / Agora) أرخص وأكثر استقرارًا من الاستضافة الذاتية.

---

## 3. الخيار (أ) — أقل تكلفة سحابية (50 مستخدم)

### 3.1 المصاريف الشهرية (برمجيات وخدمات)

| الخدمة | الوظيفة | الباقة | دولار/شهر | جنيه/شهر |
|--------|---------|--------|----------:|---------:|
| Supabase | قاعدة بيانات + مصادقة + تخزين + API | المجانية (تكفي لـ 50) | $0 | 0 |
| Supabase (عند النمو) | حدود أعلى | Pro | $25 | 1,250 |
| استضافة الويب | استضافة التطبيق | Vercel / Cloudflare (مجاني) | $0 | 0 |
| اسم النطاق | yoursite.com | سنوي ÷ 12 | ~$1 | ~50 |
| البريد الإلكتروني | تفعيل/استعادة/تنبيهات | Resend / Brevo مجاني | $0 | 0 |
| **الجلسات المباشرة** | الحصص الحية | Zoom Pro أو Google Workspace | $13–15 | 650–750 |
| تخزين/بث الفيديو | الدروس المسجلة | Bunny.net (~50 جيجا + توصيل) | $5–10 | 250–500 |
| بوابة الدفع | تحصيل الرسوم | Paymob / Fawry (لكل عملية) | ~2.5–3% لكل دفعة | لكل دفعة |

**أقل تكلفة واقعية (باقات مجانية + بث مدفوع + فيديو):**
- **الحد الأدنى (Supabase مجاني + Google Meet مجاني):** ≈ **300–800 جنيه/شهر**
- **المريح (Supabase Pro + Zoom + Bunny):** ≈ **2,200–2,750 جنيه/شهر**

**سنويًا:** ≈ **3,600 – 33,000 جنيه/سنة** حسب الباقة.

### 3.2 تكاليف لمرة واحدة (سحابة)

| البند | متى يلزم | جنيه (مرة واحدة) |
|------|----------|-----------------:|
| Google Play Console | عند نشر تطبيق أندرويد | ~1,250 (مرة واحدة) |
| Apple Developer | عند نشر تطبيق iOS | ~5,000 / سنة |
| شهادة SSL | مجانية (Let's Encrypt) | 0 |

> إذا اكتفيت بـ **تطبيق ويب** (يعمل على متصفح الموبايل أيضًا)، يمكنك تجاوز رسوم المتاجر تمامًا → **0 جنيه لمرة واحدة**.

### 3.3 السحابة — الخلاصة لـ 50 مستخدم

| السيناريو | التأسيس (مرة) | التشغيل (شهريًا) | التشغيل (سنويًا) |
|-----------|--------------:|-----------------:|-----------------:|
| **ويب فقط، اقتصادي** | ~0 جنيه | ~300–800 جنيه | ~3,600–9,600 جنيه |
| **ويب + موبايل، مريح** | ~6,250 جنيه | ~2,200–2,750 جنيه | ~26,000–33,000 جنيه |

✅ **موصى به لـ 50 مستخدم.** أقل تكلفة بداية، بلا صيانة، بث مباشر موثوق.

---

## 4. الخيار (ب) — أقل تكلفة محلية (50 مستخدم)

### 4.1 العتاد لمرة واحدة

| البند | المواصفات (تكفي 50 مستخدم) | جنيه (مرة واحدة) |
|------|-----------------------------|-----------------:|
| سيرفر (برج) | Xeon / Core i7، 32–64 جيجا رام | 60,000–120,000 |
| أو بديل اقتصادي | ميني-PC / محطة عمل مجددة | 25,000–45,000 |
| SSD (نظام + قاعدة بيانات) | 1 تيرا NVMe | 4,000–7,000 |
| HDD (تخزين الفيديو/المواد) | 2 × 4 تيرا RAID 1 (نسخ مرآة) | 12,000–18,000 |
| UPS (طاقة احتياطية) | 1500 فولت أمبير | 6,000–10,000 |
| معدات شبكة | راوتر + سويتش مُدار | 3,000–8,000 |
| **إجمالي العتاد** | | **~85,000 – 163,000 جنيه** |
| إجمالي البناء الاقتصادي | | **~50,000 – 80,000 جنيه** |

### 4.2 المصاريف الشهرية

| البند | التفاصيل | جنيه/شهر |
|------|----------|---------:|
| إنترنت أعمال | IP ثابت + رفع عالٍ (حاسم) | 1,500–4,000 |
| كهرباء | سيرفر ~200–400 وات على مدار الساعة | 500–1,200 |
| نسخ احتياطي خارجي | نسخة سحابية للبيانات والملفات | 250–500 |
| نطاق + SSL | سنوي ÷ 12 | ~50 |
| تبريد / صيانة | تبريد الغرفة + قطع غيار | 300–800 |
| **البث المباشر** | يُفضّل خدمة مدفوعة* | 650–750 |
| **الإجمالي الشهري** | | **~3,250 – 7,300 جنيه/شهر** |

\* استضافة البث ذاتيًا (مثل Jitsi) برمجيات "مجانية"، لكن لـ 50 مشاهدًا متزامنًا تحتاج رفعًا عاليًا جدًا وسيرفرًا قويًا، وغالبًا تكلفتها أعلى من خدمة مُدارة وأقل استقرارًا.

### 4.3 المحلي — الخلاصة لـ 50 مستخدم

| | التأسيس (مرة) | التشغيل (شهريًا) | التشغيل (سنويًا) |
|-|--------------:|-----------------:|-----------------:|
| **بناء اقتصادي** | ~50,000–80,000 جنيه | ~3,250 جنيه | ~39,000 جنيه |
| **سيرفر مناسب** | ~85,000–163,000 جنيه | ~5,000–7,300 جنيه | ~60,000–88,000 جنيه |

⚠️ تكلفة بداية أعلى، وأنت تتحمّل الصيانة والأمان والنسخ الاحتياطي، والبث المباشر أصعب. **غير موصى به لـ 50 مستخدمًا فقط** إلا إذا كنت تملك العتاد مسبقًا أو لديك التزام قانوني بإبقاء البيانات محليًا.

---

## 5. مقارنة: سحابي مقابل محلي

| العامل | سحابي (أ) | محلي (ب) |
|--------|-----------|----------|
| التكلفة الأولية | شبه صفر | 50,000–163,000 جنيه |
| التكلفة الشهرية (50 مستخدم) | 300–2,750 جنيه | 3,250–7,300 جنيه |
| وقت التأسيس | ساعات | أيام–أسابيع |
| الصيانة | المورّد يتولاها | أنت تتولاها |
| البث المباشر | سهل (مُدار) | صعب (محدود بالرفع) |
| التوسّع لـ 200+ مستخدم | ترقية بضغطة | شراء عتاد إضافي |
| النسخ الاحتياطي | تلقائي | تُعِدّه بنفسك |
| الأنسب لـ | أكاديميات صغيرة/متوسطة | مؤسسات كبيرة بفريق IT / قوانين بيانات |

**التوصية لـ 50 مستخدم: السحابة (الخيار أ).** أرخص بكثير في السنة الأولى ويزيل كل مخاطر العتاد.

---

## 6. تكلفة المبرمج (منفصلة، كما طُلب)

تكاليف البنية التحتية أعلاه **لا تشمل تطوير البرمجيات**. النواة الأساسية موجودة بالفعل؛ ميزات المرحلة الثانية المتبقية (المهام، الاختبارات، الدفع، الحجز المدفوع، البث المدمج) تحتاج مطوّرًا.

### 6.1 لإنهاء الميزات المتبقية (مشروع لمرة واحدة)

| حزمة العمل | الجهد | جنيه (فريلانس، مصر) |
|------------|------|--------------------:|
| المهام / الواجبات + التصحيح | ~1–2 أسبوع | 15,000–35,000 |
| الاختبارات / الكويزات (تصحيح آلي) | ~2 أسبوع | 20,000–40,000 |
| الدفع الإلكتروني (Paymob/Fawry) | ~1–2 أسبوع | 15,000–35,000 |
| مسار حجز الدورات المدفوع | ~1 أسبوع | 10,000–20,000 |
| دمج البث المباشر (100ms/Agora/Zoom SDK) | ~1–2 أسبوع | 20,000–45,000 |
| الاختبار + النشر (ويب + موبايل) | ~1 أسبوع | 10,000–20,000 |
| **إجمالي إكمال النظام الكامل** | ~6–9 أسابيع | **≈ 90,000 – 195,000 جنيه** |

### 6.2 دعم مستمر للمطوّر (اختياري)

| الخيار | جنيه/شهر |
|--------|---------:|
| صيانة جزئية وإصلاح أخطاء | 5,000–15,000 |
| مطوّر Flutter متفرّغ (مبتدئ/متوسط) | 15,000–40,000 |

> الأسعار تفترض مطوّر Flutter + Supabase فريلانس (مبتدئ إلى متوسط) في مصر 2026. الشركات تكلّف 2–4 أضعاف.

---

## 7. الباقة الموصى بها لأكاديمية 50 طالبًا

| البند | الاختيار | التكلفة |
|-------|----------|---------|
| البنية التحتية | **سحابي (الخيار أ)، ويب + موبايل** | ~2,200–2,750 جنيه/شهر |
| رسوم المتاجر | أندرويد فقط (تأجيل iOS) | ~1,250 جنيه مرة واحدة |
| إكمال الميزات الكاملة | مشروع فريلانس | ~90,000–195,000 جنيه مرة واحدة |
| الصيانة | عقد جزئي | ~5,000–10,000 جنيه/شهر |

**إجمالي السنة الأولى (بدون التطوير): ~27,000–34,000 جنيه**
**إجمالي السنة الأولى (شامل التطوير مرة + الصيانة): ~150,000–315,000 جنيه**

---

## Notes / ملاحظات

- **Payment gateway fees / رسوم بوابة الدفع:** Paymob & Fawry charge per transaction (~2.5–3% + small fixed fee), not monthly. Deducted from each student payment. / تُخصم من كل دفعة طالب، وليست شهرية.
- **Free tier limits / حدود الباقة المجانية:** Supabase free tier (500 MB DB, 1 GB storage, 50k monthly active users) is enough to start with 50 users. Upgrade to Pro when storage/bandwidth grows. / تكفي للبداية، ثم ترقّي عند زيادة التخزين.
- **Video is the main cost driver / الفيديو هو المحرّك الأساسي للتكلفة:** Recorded lessons consume storage + bandwidth. Compress to 720p and consider Bunny.net Stream to keep costs low. / اضغط الفيديو إلى 720p لتقليل التكلفة.
- **FX risk / مخاطر سعر الصرف:** Cloud prices are USD-based; if the pound weakens, EGP cost rises. / أسعار السحابة بالدولار، فترتفع بالجنيه عند ضعف العملة.
