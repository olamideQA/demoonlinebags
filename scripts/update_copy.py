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
        'text': 'COMPLIMENTARY VIP COURIER DELIVERY ON ORDERS OVER ₦150,000  •  SAME-DAY LAGOS DISPATCH & 24–48HR NATIONWIDE  •  100% AUTHENTIC FULL-GRAIN LEATHER',
        'is_active': True
    }),
    ('header', {
        'brand_name': 'DEMO ONLINE BAGS',
        'tagline': 'LUXURY HANDBAGS & FOOTWEAR • ATELIER LAGOS'
    }),
    ('hero', {
        'badge': 'NEW CAPSULE 2026 • LIMITED ATELIER EDITION',
        'title': 'Command Every Room.\nUnapologetic Luxury.',
        'subtitle': 'Crafted in certified Italian full-grain calfskin with non-tarnish 24K gold hardware. Structured for executive boardroom poise and sculpted for high-society wedding guest glamour.',
        'cta_text': 'EXPLORE SIGNATURE BAGS',
        'cta_url': '/shop',
        'secondary_cta_text': 'COMPLETE THE LOOK (SETS)',
        'secondary_cta_url': '/pairings',
        'image_url': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85'
    }),
    ('footer', {
        'bio': "Demo Online Bags is Nigeria's premier luxury handbag house and atelier. We craft structured full-grain leather handbags and perfectly paired sculpted footwear for discerning, modern African women who lead and inspire.",
        'email': 'concierge@demoonlinebags.com',
        'phone': '+234 810 000 2247',
        'whatsapp': '+234 810 000 2247',
        'address': 'Victoria Island, Lagos, Nigeria',
        'copyright': '© 2026 DEMO ONLINE BAGS ATELIER. ALL RIGHTS RESERVED.',
        'instagram': 'https://instagram.com/demoonlinebags'
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

    # Also update categories descriptions to high-fashion Nigerian appeal
    category_updates = [
        ('tote-bags', 'Architectural executive totes engineered for high-flying women. Holds your laptop, planner, and vanity pouch with zero sagging.'),
        ('crossbody-bags', 'Chic hands-free luxury for effortless airport travel, weekend brunches, and high-street shopping in Victoria Island.'),
        ('shoulder-bags', 'Sleek under-the-arm baguettes and chain carriers crafted to transition seamlessly from desk to dinner.'),
        ('evening-clutches', 'Show-stopping crystal minaudières and gilded clutches designed for red carpets, wedding guest glam, and grand evening receptions.'),
        ('mini-bucket-bags', 'Petite structured vanity silhouettes in rich pebble leather—holds your iPhone Pro Max, lip gloss, and cards in pure style.'),
        ('luxury-heels', 'Architectural stilettos and party pumps engineered with triple-layer memory-foam arch support to dance all night at Owambes without foot fatigue.'),
        ('mules-slides', 'Slip-on block mules with cushioned glove-leather insoles for effortless boardroom poise and luxury brunch dates.')
    ]

    print("\n=== UPDATING CATEGORIES DESCRIPTIONS ===")
    for slug, desc in category_updates:
        clean_desc = desc.replace("'", "''")
        run_sql(f"UPDATE public.categories SET description = '{clean_desc}' WHERE slug = '{slug}';")
        print(f"  OK: category -> {slug}")

    # Also update pairings descriptions
    pairing_updates = [
        ('e1111111-1111-1111-1111-111111111111', 'The Grand Soirée & Wedding Guest Set: Venetian Crystal Minaudière & Bellissima Stilettos', 'Turn heads at any high-society reception. Hand-set pave crystal clutch paired with arch-padded stiletto pumps designed for comfort throughout a 6-hour Owambe. Enjoy an exclusive 15% pairing privilege.'),
        ('e2222222-2222-2222-2222-222222222222', 'The Executive Power Duo: Sovereign Leather Tote & Paloma Sculpted Mules', 'The definitive boardroom power look for women of influence. Structured 14-inch laptop tote in scratch-resistant Italian calfskin paired with all-day comfortable 60mm block mules. Save 10% on the ensemble.')
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
