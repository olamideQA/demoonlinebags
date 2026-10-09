# DEMO ONLINE BAGS — Luxury Handbag House & Atelier

[![Deploy to Firebase Hosting](https://github.com/olamideQA/demoonlinebags/actions/workflows/firebase-deploy.yml/badge.svg)](https://github.com/olamideQA/demoonlinebags/actions/workflows/firebase-deploy.yml)

An ultra-high-end ecommerce web application and mobile application designed strictly for **luxury ladies' handbags, structured totes, 90s croc baguettes, quilted crossbodies, and jeweled evening minaudières** with complementary footwear pairings.

---

## 🌐 Live Storefront & Deployment
* **Primary Live Web Storefront**: [https://demoonlinebags.web.app](https://demoonlinebags.web.app)
* **Secondary Domain**: [https://demoonlinebags.firebaseapp.com](https://demoonlinebags.firebaseapp.com)
* **Back-Office Management**: [https://demoonlinebags.web.app/admin](https://demoonlinebags.web.app/admin)
* **GitHub Repository**: [https://github.com/olamideQA/demoonlinebags](https://github.com/olamideQA/demoonlinebags)

---

## 💎 Maison Features & Luxury UX
* **Strict Leathercraft Focus**: Dedicated exclusively to ladies' handbags and leather goods with zero generic clothing apparel.
* **Curated Silhouettes**:
  * *Structured Executive Totes* (fits up to 14" MacBook Pro)
  * *Flap & Quilted Crossbody Bags* (sliding gourmette chains)
  * *90s Baguette & Shoulder Bags* (gloss croc-embossed calfskin)
  * *Jeweled Evening Clutches & Minaudières* (over 1,200 hand-set crystals)
  * *Woven Nappa & Bucket Bags*
  * *Petite Vanity Top-Handle Cases*
* **Complete The Look (Pairing Engine)**: Harmonious pairings of handbags with sculpted heels and mules, offering automated 10-15% bundle privileges with one-click "Add Both to Bag".
* **Interactive Footwear Sizing & Fit Modal**: Complete conversion chart (EU 36-41 / UK / US / CM) with true-to-size recommendations.
* **Full-Fidelity Specifications**: Dedicated accordion breakdown for bag dimensions, strap drop, closure mechanism, compartments, leather provenance, and care instructions.
* **Complimentary Shipping Progress Meter**: Dynamic live progress bar encouraging order upsells toward the ₦150,000 complimentary insured courier threshold.
* **Frictionless VIP Checkout**: Multi-step checkout supporting direct Bank Transfer/USSD, Card processing, and White-Glove delivery with instant order generation (`DOB-XXXXX`).

---

## 🛠 Tech Stack
* **Frontend**: Flutter 3.44+ (CanvasKit / Web + Mobile responsive)
* **State Management**: Flutter Riverpod 3.x (`NotifierProvider`)
* **Routing**: GoRouter (deep linking & browser history handling)
* **Backend Database**: Supabase PostgreSQL + Row Level Security (RLS)
* **Hosting & CDN**: Firebase Hosting (Global Edge Network)
* **CI/CD**: GitHub Actions automated pipeline

---

## 🚀 Supabase Database Setup

To initialize the live PostgreSQL tables, Row Level Security policies, and seed data:
1. Open your Supabase project SQL Editor: [https://supabase.com/dashboard/project/htvcavnqsgyjrbtqefxk/sql/new](https://supabase.com/dashboard/project/htvcavnqsgyjrbtqefxk/sql/new)
2. Open [`supabase/run_all_migrations.sql`](./supabase/run_all_migrations.sql) in this repository.
3. Paste the contents into the query editor and click **RUN**.
4. All tables (`products`, `categories`, `collections`, `product_variants`, `pairings`, `orders`, `order_items`, `reviews`, `banners`, `profiles`) will be created and populated with luxury demo records.

---

## 💻 Local Development

```powershell
# Run locally on Chrome
.\tool\run_dev.ps1

# Or run local preview server
python .\scripts\serve_local.py
```
