import urllib.request
import json
import os

PROJECT_REF = os.environ.get('SUPABASE_PROJECT_REF', 'htvcavnqsgyjrbtqefxk')
MGMT_TOKEN = os.environ.get('SUPABASE_MGMT_TOKEN', '')
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

sql_statements = [
    # 1. Create site_settings table
    """
    CREATE TABLE IF NOT EXISTS public.site_settings (
        key TEXT PRIMARY KEY,
        value JSONB NOT NULL,
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    """,
    "ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"Public site_settings read\" ON public.site_settings;",
    "CREATE POLICY \"Public site_settings read\" ON public.site_settings FOR SELECT USING (true);",
    "DROP POLICY IF EXISTS \"Public site_settings insert\" ON public.site_settings;",
    "CREATE POLICY \"Public site_settings insert\" ON public.site_settings FOR INSERT WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public site_settings update\" ON public.site_settings;",
    "CREATE POLICY \"Public site_settings update\" ON public.site_settings FOR UPDATE USING (true);",

    # 2. Seed site_settings
    """
    INSERT INTO public.site_settings (key, value)
    VALUES
        ('announcement', '{"text": "COMPLIMENTARY VIP COURIER DELIVERY ACROSS NIGERIA ON ORDERS OVER ₦150,000 • 100% ITALIAN FULL-GRAIN LEATHER", "is_active": true}'::jsonb),
        ('header', '{"brand_name": "DEMO ONLINE BAGS", "tagline": "LUXURY HANDBAGS & FOOTWEAR"}'::jsonb),
        ('hero', '{"badge": "NEW CAPSULE 2026", "title": "Sculpted Architecture.\\nUncompromising Luxury.", "subtitle": "Impeccable craftsmanship in full-grain Italian leathers and sculptured silhouettes tailored for modern executive elegance.", "cta_text": "EXPLORE THE ATELIER", "cta_url": "/shop", "secondary_cta_text": "COMPLETE THE LOOK", "secondary_cta_url": "/pairings", "image_url": "https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85"}'::jsonb),
        ('footer', '{"bio": "Demo Online Bags is an exclusive luxury atelier dedicated to the craft of exquisite leather handbags and sculptured footwear for the modern, discerning woman.", "email": "concierge@demoonlinebags.com", "phone": "+234 800 000 2247", "whatsapp": "+234 800 000 2247", "address": "Victoria Island, Lagos, Nigeria", "copyright": "© 2026 DEMO ONLINE BAGS. ALL RIGHTS RESERVED.", "instagram": "https://instagram.com/demoonlinebags"}'::jsonb),
        ('general', '{"currency": "NGN", "currency_symbol": "₦", "free_shipping_threshold": 150000}'::jsonb)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
    """,

    # 3. Create auth user to profile trigger
    """
    CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS trigger AS $$
    BEGIN
      INSERT INTO public.profiles (id, email, full_name, phone, role)
      VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', ''),
        COALESCE(new.raw_user_meta_data->>'phone', ''),
        COALESCE(new.raw_user_meta_data->>'role', 'customer')
      )
      ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = CASE WHEN EXCLUDED.full_name <> '' THEN EXCLUDED.full_name ELSE public.profiles.full_name END;
      RETURN new;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
    """,
    "DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;",
    """
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
    """,

    # 4. Mutation policies for CMS and admin
    "DROP POLICY IF EXISTS \"Public products mutate\" ON public.products;",
    "CREATE POLICY \"Public products mutate\" ON public.products FOR ALL USING (true) WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public categories mutate\" ON public.categories;",
    "CREATE POLICY \"Public categories mutate\" ON public.categories FOR ALL USING (true) WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public pairings mutate\" ON public.pairings;",
    "CREATE POLICY \"Public pairings mutate\" ON public.pairings FOR ALL USING (true) WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public variants mutate\" ON public.product_variants;",
    "CREATE POLICY \"Public variants mutate\" ON public.product_variants FOR ALL USING (true) WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public orders mutate\" ON public.orders;",
    "CREATE POLICY \"Public orders mutate\" ON public.orders FOR ALL USING (true) WITH CHECK (true);",
    "DROP POLICY IF EXISTS \"Public banners mutate\" ON public.banners;",
    "CREATE POLICY \"Public banners mutate\" ON public.banners FOR ALL USING (true) WITH CHECK (true);"
]

def main():
    print("=== APPLYING CMS SITE_SETTINGS AND AUTH TRIGGER TO SUPABASE ===")
    for i, stmt in enumerate(sql_statements):
        st = stmt.strip()
        print(f"[{i+1}/{len(sql_statements)}] Running: {st[:45]}...")
        run_sql(st)
    print("ALL STATEMENTS APPLIED SUCCESSFULLY!")

    # Verify site_settings
    res = run_sql("SELECT key, value FROM public.site_settings;")
    print("\nVerified site_settings in Supabase:")
    for row in res:
        print(f"  - {row['key']}: {json.dumps(row['value'])[:80]}...")

if __name__ == '__main__':
    main()
