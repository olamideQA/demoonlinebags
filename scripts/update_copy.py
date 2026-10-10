import os
import urllib.request
import json

PROJECT_REF = os.environ.get('SUPABASE_PROJECT_REF', 'htvcavnqsgyjrbtqefxk')
MGMT_TOKEN = os.environ.get('SUPABASE_MGMT_TOKEN', '')
if not MGMT_TOKEN:
    print("SUPABASE_MGMT_TOKEN environment variable required.")
QUERY_URL = f'https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query'

def run_sql(query_str):
    headers = {
        'Authorization': f'Bearer {MGMT_TOKEN}',
        'Content-Type': 'application/json'
    }
    body = json.dumps({'query': query_str}).encode('utf-8')
    req = urllib.request.Request(QUERY_URL, data=body, headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = resp.read().decode('utf-8')
            return json.loads(data) if data else []
    except urllib.error.HTTPError as e:
        err = e.read().decode('utf-8')
        print(f"Error ({e.code}): {err}")
        raise Exception(err)

settings = [
    ('announcement', {
        'text': 'FREE VIP DELIVERY IN LAGOS OVER ₦150,000  •  PAY ON DELIVERY IN LAGOS & ABUJA  •  100% REAL LEATHER — NO PEELING, NO FAKE',
        'is_active': True
    }),
    ('header', {
        'brand_name': 'LUXE LAGOS',
        'tagline': 'LUXURY BAGS & SHOES • LAGOS • ABUJA • NATIONWIDE'
    }),
    ('hero', {
        'badge': 'LAGOS BESTSELLER • 2026 COLLECTION',
        'title': 'Pepper Them at Every Owambe.',
        'subtitle': 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.',
        'cta_text': 'SHOP BAGS',
        'cta_url': '/shop',
        'secondary_cta_text': 'SHOP MATCHING SETS',
        'secondary_cta_url': '/pairings',
        'image_url': 'assets/images/hero1.jpg',
        'slides': [
            {'id': 's1', 'badge': 'LAGOS BESTSELLER • 2026 COLLECTION', 'title': 'Pepper Them at Every Owambe.', 'subtitle': 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.', 'cta_text': 'SHOP BAGS', 'cta_url': '/shop', 'secondary_cta_text': 'SHOP MATCHING SETS', 'secondary_cta_url': '/pairings', 'image_url': 'assets/images/hero1.jpg'},
            {'id': 's2', 'badge': 'NEW ARRIVAL • CHURCH TO BRUNCH', 'title': 'One Bag, From Desk to Dinner.', 'subtitle': 'Fine croc-finish shoulder bag for work in VI, brunch in Ikoyi and dinner after.', 'cta_text': 'SHOP SHOULDER BAGS', 'cta_url': '/shop', 'secondary_cta_text': 'SEE MATCHING SHOES', 'secondary_cta_url': '/pairings', 'image_url': 'assets/images/hero2.jpg'},
            {'id': 's3', 'badge': 'OWAMBE & WEDDING SEASON • LIMITED', 'title': 'Shine Like Candlelight.', 'subtitle': 'Crystal clutch that catches every light at weddings. Fits iPhone 16 Pro Max.', 'cta_text': 'SHOP PARTY CLUTCHES', 'cta_url': '/shop', 'secondary_cta_text': 'SHOP BAG + SHOE SETS', 'secondary_cta_url': '/pairings', 'image_url': 'assets/images/hero3.jpg'},
            {'id': 's4', 'badge': 'COMFY HEELS • DANCE ALL NIGHT', 'title': 'Heels That Dont Hurt.', 'subtitle': 'Soft padded heels for 6-hour Owambes, church and office. No leg pain, no wahala.', 'cta_text': 'SHOP COMFY HEELS', 'cta_url': '/shop', 'secondary_cta_text': 'MATCH WITH A BAG', 'secondary_cta_url': '/pairings', 'image_url': 'assets/images/hero4.jpg'},
        ]
    }),
    ('footer', {
        'bio': "LUXE LAGOS is made for Nigerian women who do it all — boardroom by day, Owambe by night. Real Italian leather bags and comfy matching shoes that will not peel. Chat on WhatsApp, pay on delivery in Lagos & Abuja.",
        'email': 'hello@luxelagos.ng',
        'phone': '+234 906 791 4511',
        'whatsapp': '+234 906 791 4511',
        'address': '12 Admiralty Way, Lekki Phase 1, Lagos, Nigeria',
        'copyright': '© 2026 LUXE LAGOS. ALL RIGHTS RESERVED.',
        'instagram': 'https://instagram.com/luxelagos.ng'
    }),
    ('general', {
        'currency': 'NGN',
        'currency_symbol': '₦',
        'free_shipping_threshold': 150000.0
    })
]

def main():
    print("=== UPDATING SUPABASE SITE_SETTINGS WITH PREMIER NIGERIAN LUXURY COPY ===")
    for key, val in settings:
        val_json = json.dumps(val).replace("'", "''")
        sql = f"""
        INSERT INTO public.site_settings (key, value)
        VALUES ('{key}', '{val_json}'::jsonb)
        ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
        """
        run_sql(sql)
        print(f"  OK: site_settings -> {key}")

    # Also update categories descriptions to warm Nigerian appeal
    category_updates = [
        ('tote-bags', 'Strong office totes for working women. Carries your 14-inch laptop, planner and purse — no sagging, no peeling.'),
        ('crossbody-bags', 'Hands-free bags for market runs, travel, brunch in VI and everyday slay. Light, fine and easy to carry.'),
        ('shoulder-bags', 'Fine under-arm bags that go from office in the morning to dinner at night. One bag, many occasions.'),
        ('evening-clutches', 'Shining crystal clutches for weddings, Owambe, church anniversary and red-carpet nights. Pepper them well.'),
        ('mini-bucket-bags', 'Small fine bags for phone, lip gloss and cards. Perfect for quick outings and Detty December parties.'),
        ('luxury-heels', 'Fine party heels with soft padding. Dance for hours at Owambe with no leg pain. Brides love them.'),
        ('mules-slides', 'Easy slip-on mules for office, church and brunch. Soft inside, classy outside.')
    ]

    print("\n=== UPDATING CATEGORIES DESCRIPTIONS ===")
    for slug, desc in category_updates:
        clean_desc = desc.replace("'", "''")
        run_sql(f"UPDATE public.categories SET description = '{clean_desc}' WHERE slug = '{slug}';")
        print(f"  OK: category -> {slug}")

    # Also update pairings descriptions
    pairing_updates = [
        ('e1111111-1111-1111-1111-111111111111', 'Owambe Ready Set: Crystal Clutch + Crystal Heels', 'Perfect match for weddings and Owambe. Shining clutch + comfy padded heels you can dance in for 6 hours. Buy together and save 15%.'),
        ('e2222222-2222-2222-2222-222222222222', 'Office Power Set: Laptop Tote + Comfy Mules', 'For working women: strong tote that carries your 14-inch laptop + comfy low heels for all-day office and church. Real leather, no peeling. Save 10% when you buy both.')
    ]

    print("\n=== UPDATING PAIRINGS COPY ===")
    for pid, title, pdesc in pairing_updates:
        t_clean = title.replace("'", "''")
        d_clean = pdesc.replace("'", "''")
        run_sql(f"UPDATE public.pairings SET title = '{t_clean}', description = '{d_clean}' WHERE id = '{pid}';")
        print(f"  OK: pairing -> {title[:40]}...")

    print("\nALL COPY UPDATES APPLIED TO SUPABASE SUCCESSFULLY!")

if __name__ == '__main__':
    main()
