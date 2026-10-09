-- ==============================================================================
-- DEMO ONLINE BAGS - ALL-IN-ONE COMPLETE MIGRATION & SEED SCRIPT
-- Paste this entire file into: https://supabase.com/dashboard/project/htvcavnqsgyjrbtqefxk/sql/new
-- Then click "RUN" (green button)
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop existing tables safely
DROP TABLE IF EXISTS public.order_items CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.reviews CASCADE;
DROP TABLE IF EXISTS public.pairings CASCADE;
DROP TABLE IF EXISTS public.product_variants CASCADE;
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.collections CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.banners CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 3. Create Profiles
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'staff')),
    preferred_currency TEXT DEFAULT 'NGN',
    saved_addresses JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create Categories
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    type TEXT NOT NULL DEFAULT 'bags' CHECK (type IN ('bags', 'shoes', 'accessories')),
    description TEXT,
    image_url TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create Collections
CREATE TABLE public.collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    tagline TEXT,
    description TEXT,
    cover_image_url TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Create Products
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    collection_id UUID REFERENCES public.collections(id) ON DELETE SET NULL,
    product_type TEXT NOT NULL DEFAULT 'bag' CHECK (product_type IN ('bag', 'shoe', 'set')),
    sub_category TEXT,
    base_price NUMERIC(12, 2) NOT NULL,
    sale_price NUMERIC(12, 2),
    currency TEXT DEFAULT 'NGN',
    short_description TEXT,
    description TEXT,
    images TEXT[] NOT NULL DEFAULT '{}',
    primary_image TEXT,
    material TEXT,
    dimensions_cm TEXT,
    strap_drop_cm NUMERIC(5, 2),
    heel_height_cm NUMERIC(5, 2),
    heel_type TEXT,
    closure_type TEXT,
    compartments_info TEXT,
    care_instructions TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    is_bestseller BOOLEAN DEFAULT FALSE,
    is_new_arrival BOOLEAN DEFAULT TRUE,
    stock_quantity INT DEFAULT 12,
    rating NUMERIC(3, 2) DEFAULT 5.0,
    review_count INT DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Create Product Variants
CREATE TABLE public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variant_type TEXT NOT NULL CHECK (variant_type IN ('color', 'size', 'hardware')),
    name TEXT NOT NULL,
    color_hex TEXT,
    stock_quantity INT DEFAULT 5,
    price_adjustment NUMERIC(12, 2) DEFAULT 0,
    sku TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Create Pairings
CREATE TABLE public.pairings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    bag_product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    shoe_product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    bundle_discount_percent INT DEFAULT 10,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Create Orders
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    shipping_address JSONB NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    shipping_fee NUMERIC(12, 2) DEFAULT 0,
    discount NUMERIC(12, 2) DEFAULT 0,
    total NUMERIC(12, 2) NOT NULL,
    currency TEXT DEFAULT 'NGN',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    payment_status TEXT DEFAULT 'paid' CHECK (payment_status IN ('pending', 'paid', 'failed')),
    payment_method TEXT DEFAULT 'transfer' CHECK (payment_method IN ('card', 'transfer', 'paystack', 'cash_on_delivery')),
    notes TEXT,
    tracking_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Create Order Items
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_title TEXT NOT NULL,
    product_image TEXT,
    selected_size TEXT,
    selected_color TEXT,
    unit_price NUMERIC(12, 2) NOT NULL,
    quantity INT DEFAULT 1,
    total_price NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Create Banners
CREATE TABLE public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    tagline TEXT,
    cta_text TEXT DEFAULT 'Shop Now',
    cta_url TEXT DEFAULT '/shop',
    image_url TEXT NOT NULL,
    placement TEXT DEFAULT 'hero' CHECK (placement IN ('hero', 'editorial', 'announcement')),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Create Reviews
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_email TEXT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    headline TEXT,
    comment TEXT NOT NULL,
    is_verified_buyer BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pairings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 14. Policies
CREATE POLICY "Public categories read" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Public collections read" ON public.collections FOR SELECT USING (true);
CREATE POLICY "Public products read" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public product_variants read" ON public.product_variants FOR SELECT USING (true);
CREATE POLICY "Public pairings read" ON public.pairings FOR SELECT USING (true);
CREATE POLICY "Public banners read" ON public.banners FOR SELECT USING (true);
CREATE POLICY "Public reviews read" ON public.reviews FOR SELECT USING (true);

CREATE POLICY "Public order creation" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Public orders read" ON public.orders FOR SELECT USING (true);
CREATE POLICY "Public order_items insert" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Public order_items select" ON public.order_items FOR SELECT USING (true);

CREATE POLICY "Public profiles read" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users insert own profile" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 15. Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('products', 'products', true),
    ('banners', 'banners', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public Access Products Bucket" ON storage.objects;
CREATE POLICY "Public Access Products Bucket" ON storage.objects FOR SELECT USING (bucket_id = 'products');
DROP POLICY IF EXISTS "Public Access Banners Bucket" ON storage.objects;
CREATE POLICY "Public Access Banners Bucket" ON storage.objects FOR SELECT USING (bucket_id = 'banners');

-- ==============================================================================
-- 16. SEED DATA
-- ==============================================================================

-- Categories
INSERT INTO public.categories (id, name, slug, type, description, image_url, sort_order)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'Tote Bags', 'tote-bags', 'bags', 'Spacious, structured luxury totes tailored for everyday elegance and executive lifestyles.', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80', 1),
    ('c2222222-2222-2222-2222-222222222222', 'Crossbody Bags', 'crossbody-bags', 'bags', 'Effortless hands-free silhouettes with polished hardware and adjustable leather straps.', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80', 2),
    ('c3333333-3333-3333-3333-333333333333', 'Shoulder Bags', 'shoulder-bags', 'bags', 'Iconic 90s-inspired baguettes, ruched croissants, and classic chain-link shoulder carriers.', 'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=800&q=80', 3),
    ('c4444444-4444-4444-4444-444444444444', 'Evening Clutches', 'evening-clutches', 'bags', 'Show-stopping minaudières, crystal-encrusted boxes, and lustrous silk-satin pouches.', 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=800&q=80', 4),
    ('c5555555-5555-5555-5555-555555555555', 'Mini & Bucket Bags', 'mini-bucket-bags', 'bags', 'Playful yet sophisticated compact designs crafted in structured grain leathers.', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=800&q=80', 5),
    ('c6666666-6666-6666-6666-666666666666', 'Luxury Heels', 'luxury-heels', 'shoes', 'Signature sculpted stilettos, kitten heels, and slingbacks made to complement every bag.', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80', 6),
    ('c7777777-7777-7777-7777-777777777777', 'Mules & Slides', 'mules-slides', 'shoes', 'Architectural block heels, slip-on metallic mules, and cushioned everyday slides.', 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=800&q=80', 7)
ON CONFLICT (id) DO NOTHING;

-- Collections
INSERT INTO public.collections (id, name, slug, tagline, description, cover_image_url, is_featured, sort_order)
VALUES
    ('b1111111-1111-1111-1111-111111111111', 'The Noir Gold Edit', 'the-noir-gold-edit', 'Timeless Obsidian & Polished 24K Brass', 'Our definitive core collection uniting deep midnight calfskins with luminous gold-plated hardware.', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1200&q=80', true, 1),
    ('b2222222-2222-2222-2222-222222222222', 'Parisian Riviera', 'parisian-riviera', 'Sun-Kissed Straw, Nappa Leather & Alabaster', 'Evoking the South of France with woven natural textures, soft ivory leathers, and champagne metallics.', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1200&q=80', true, 2),
    ('b3333333-3333-3333-3333-333333333333', 'Gala & Soirée Couture', 'gala-soiree-couture', 'Jeweled Minaudières & Dramatic Stilettos', 'Crafted specifically for black-tie galas, opulent weddings, and evening celebrations.', 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1200&q=80', true, 3)
ON CONFLICT (id) DO NOTHING;

-- Banners
INSERT INTO public.banners (id, title, subtitle, tagline, cta_text, cta_url, image_url, placement, is_active, sort_order)
VALUES
    ('a1111111-1111-1111-1111-111111111111', 'The Art of the Handbag', 'Impeccable craftsmanship in full-grain Italian leathers and sculptured silhouettes.', 'NEW SEASON 2026', 'Discover The Collection', '/shop?category=tote-bags', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85', 'hero', true, 1),
    ('a2222222-2222-2222-2222-222222222222', 'Complete The Look: Bags & Shoes', 'Curated matching ensembles designed for unforgettable presence.', 'SIGNATURE PAIRINGS', 'Explore Pairings', '/pairings', 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1600&q=85', 'editorial', true, 2)
ON CONFLICT (id) DO NOTHING;

-- Products
INSERT INTO public.products (
    id, title, slug, category_id, collection_id, product_type, sub_category, base_price, sale_price, currency,
    short_description, description, images, primary_image, material, dimensions_cm, strap_drop_cm,
    heel_height_cm, heel_type, closure_type, compartments_info, care_instructions,
    is_featured, is_bestseller, is_new_arrival, stock_quantity, rating, review_count, tags
)
VALUES
    (
        'd1111111-1111-1111-1111-111111111111',
        'The Sovereign Structured Leather Tote',
        'the-sovereign-structured-leather-tote',
        'c1111111-1111-1111-1111-111111111111',
        'b1111111-1111-1111-1111-111111111111',
        'bag',
        'Tote',
        185000.00,
        165000.00,
        'NGN',
        'Sculpted architecture in full-grain calfskin leather with protective brass feet and dual top handles.',
        'The Sovereign Tote is the definitive hallmark of modern feminine leadership. Handcrafted from top-tier full-grain calfskin, it features a structured silhouette that maintains its refined profile whether lightly packed or holding your daily essentials. Accommodates up to a 14-inch MacBook Pro with ease.',
        ARRAY[
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
        'Full-Grain Italian Calfskin with Microfiber Suede Lining',
        '36cm x 27cm x 14cm',
        24.0,
        NULL,
        NULL,
        'Dual magnetic snaps with central padlock clasp',
        'Padded 14" laptop partition, zippered valuables pocket, twin smartphone slips',
        'Store in supplied velvet dust bag. Wipe clean with soft damp cloth.',
        true, true, true, 8, 4.95, 34,
        ARRAY['bestseller', 'workwear', 'tote', 'luxury-bag']
    ),
    (
        'd2222222-2222-2222-2222-222222222222',
        'The Aurelia Quilted Flap Crossbody',
        'the-aurelia-quilted-flap-crossbody',
        'c2222222-2222-2222-2222-222222222222',
        'b1111111-1111-1111-1111-111111111111',
        'bag',
        'Crossbody',
        145000.00,
        NULL,
        'NGN',
        'Diamond-quilted supple lambskin leather elevated with our 24K gold-plated lock mechanism.',
        'Radiating effortless Parisian chic, the Aurelia Crossbody transitions seamlessly from morning meetings to candlelit evenings. The sliding gold gourmette chain can be doubled for an over-the-shoulder carry or extended for crossbody freedom.',
        ARRAY[
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80',
        'Ultra-Soft Lambskin Leather with 24K Gold Plated Hardware',
        '25cm x 16cm x 8cm',
        52.0,
        NULL,
        NULL,
        'Signature Turn-Lock Closure',
        'Two accordion compartments and internal zippered divider',
        'Avoid prolonged contact with dark dyes. Condition biannually.',
        true, true, true, 12, 4.90, 28,
        ARRAY['crossbody', 'quilted', 'signature', 'gold-chain']
    ),
    (
        'd3333333-3333-3333-3333-333333333333',
        'The Venetian Crystal Minaudière Clutch',
        'the-venetian-crystal-minaudiere-clutch',
        'c4444444-4444-4444-4444-444444444444',
        'b3333333-3333-3333-3333-333333333333',
        'bag',
        'Clutch',
        175000.00,
        155000.00,
        'NGN',
        'Hand-set pave crystals on a gold-tone hard-shell frame with detachable jewelry snake chain.',
        'An heirloom-worthy evening companion. The Venetian Minaudière captures every angle of ambient light with over 1,200 hand-set faceted crystals. Holds an iPhone 16 Pro Max, keys, lipstick, and cards effortlessly.',
        ARRAY[
            'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1000&q=80',
        'Faceted K9 Crystals on Solid Brass Frame, Satin Interior',
        '20cm x 12cm x 6cm',
        55.0,
        NULL,
        NULL,
        'Jeweled Push-Clasp Lock',
        'Single satin-lined compartment with card pocket',
        'Spot clean crystals with microfiber jewel cloth.',
        true, false, true, 6, 5.00, 19,
        ARRAY['evening', 'clutch', 'crystals', 'wedding']
    ),
    (
        'd4444444-4444-4444-4444-444444444444',
        'The Riviera Woven Nappa Bucket Bag',
        'the-riviera-woven-nappa-bucket-bag',
        'c5555555-5555-5555-5555-555555555555',
        'b2222222-2222-2222-2222-222222222222',
        'bag',
        'Bucket Bag',
        135000.00,
        NULL,
        'NGN',
        'Intricate hand-woven leather lattice exterior with a removable canvas drawstring pouch.',
        'The Riviera Bucket Bag infuses effortless vacation serenity into modern city life. Its architectural cage silhouette is woven from supple saddle-tanned leather strips, offering airy structure and timeless charm.',
        ARRAY[
            'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
        'Hand-Woven Calf Nappa Leather with Natural Linen Pouch',
        '22cm x 22cm x 15cm',
        48.0,
        NULL,
        NULL,
        'Linen Drawstring Cinch',
        'Spacious open bucket interior with removable organizer insert',
        'Store with tissue stuffing to preserve bucket cylindrical form.',
        true, false, true, 10, 4.88, 14,
        ARRAY['woven', 'bucket-bag', 'riviera', 'summer']
    ),
    (
        'd5555555-5555-5555-5555-555555555555',
        'The Milan Croc-Embossed Baguette Shoulder Bag',
        'the-milan-croc-embossed-baguette',
        'c3333333-3333-3333-3333-333333333333',
        'b1111111-1111-1111-1111-111111111111',
        'bag',
        'Shoulder Bag',
        120000.00,
        110000.00,
        'NGN',
        'Ultra-sleek 90s shoulder silhouette in lustrous croc-embossed glaze leather.',
        'Designed to sit snugly under the arm, the Milan Baguette is an ode to minimalist nostalgia. Finished with custom brushed-brass buckles and a discreet zip top for total peace of mind.',
        ARRAY[
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80',
        'Gloss Croc-Embossed Italian Leather',
        '27cm x 14cm x 6cm',
        22.0,
        NULL,
        NULL,
        'Heavy-duty Brushed Brass Zipper',
        'Interior slip pocket, dedicated lipstick holder',
        'Buff with soft dry cloth to enhance glazed shine.',
        false, true, true, 15, 4.85, 22,
        ARRAY['shoulder-bag', 'baguette', 'croc', '90s']
    ),
    (
        'd6666666-6666-6666-6666-666666666666',
        'The Bellissima Crystal Pointed Stiletto',
        'the-bellissima-crystal-pointed-stiletto',
        'c6666666-6666-6666-6666-666666666666',
        'b3333333-3333-3333-3333-333333333333',
        'shoe',
        'Stiletto',
        115000.00,
        98000.00,
        'NGN',
        'Hand-embellished crystal brooch pump sculpted in luminous duchess satin with a 95mm stiletto heel.',
        'The definitive party and bridal silhouette. Features an ultra-flattering low-cut vamp, memory foam padded arch support for extended evening wear, and an Italian leather sole.',
        ARRAY[
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1000&q=80',
        'Silk Satin Upper, Lambskin Insole, Genuine Leather Sole',
        NULL,
        NULL,
        9.5,
        'Stiletto',
        'Slip-on with Elasticized Heel Support',
        NULL,
        'Treat with water repellent spray before wear. Keep crystal brooch dry.',
        true, true, true, 20, 4.96, 41,
        ARRAY['heels', 'stiletto', 'crystals', 'wedding-shoes']
    ),
    (
        'd7777777-7777-7777-7777-777777777777',
        'The Paloma Sculpted Block Heel Mule',
        'the-paloma-sculpted-block-heel-mule',
        'c7777777-7777-7777-7777-777777777777',
        'b1111111-1111-1111-1111-111111111111',
        'shoe',
        'Mule',
        88000.00,
        NULL,
        'NGN',
        'Contemporary square-toe mule featuring a curved geometric 60mm block heel in butter-soft leather.',
        'Effortlessly elevates tailored trousers, linen skirts, and denim alike. The ergonomic block heel provides all-day stability without sacrificing haute editorial poise.',
        ARRAY[
            'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80',
        'Glove Leather Upper with Cushioned Footbed',
        NULL,
        NULL,
        6.0,
        'Block',
        'Slip-on',
        NULL,
        'Condition with neutral leather balm.',
        false, true, true, 18, 4.89, 16,
        ARRAY['mules', 'block-heel', 'comfortable-heels', 'everyday-chic']
    ),
    (
        'd8888888-8888-8888-8888-888888888888',
        'The Capucine Petite Top-Handle Vanity',
        'the-capucine-petite-top-handle-vanity',
        'c5555555-5555-5555-5555-555555555555',
        'b1111111-1111-1111-1111-111111111111',
        'bag',
        'Mini Bag',
        110000.00,
        99000.00,
        'NGN',
        'Chic structured vanity box in grained leather with leather top-handle and detachable crossbody strap.',
        'The Capucine Vanity is an architectural statement in miniature form. Perfect for days when you only need the essentials: cards, keys, compact powder, and lipstick.',
        ARRAY[
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80'
        ],
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
        'Pebbled Calfskin Leather with Gold Accents',
        '18cm x 13cm x 9cm',
        54.0,
        NULL,
        NULL,
        'Double Wrap-Around Zipper',
        'Interior vanity mirror on lid, elasticized pouch',
        'Wipe with leather cleaner.',
        true, false, true, 9, 4.92, 11,
        ARRAY['vanity-bag', 'mini-bag', 'top-handle']
    )
ON CONFLICT (id) DO NOTHING;

-- Variants
INSERT INTO public.product_variants (product_id, variant_type, name, color_hex, stock_quantity, sku)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'color', 'Obsidian Black', '#1A1A1A', 4, 'SOV-TOT-BLK'),
    ('d1111111-1111-1111-1111-111111111111', 'color', 'Cognac Tan', '#8B4513', 3, 'SOV-TOT-COG'),
    ('d1111111-1111-1111-1111-111111111111', 'color', 'Alabaster Ivory', '#F5F5DC', 2, 'SOV-TOT-IVR'),

    ('d2222222-2222-2222-2222-222222222222', 'color', 'Noir Black', '#1A1A1A', 6, 'AUR-CRS-BLK'),
    ('d2222222-2222-2222-2222-222222222222', 'color', 'Burgundy Wine', '#6A1B29', 4, 'AUR-CRS-BUR'),
    ('d2222222-2222-2222-2222-222222222222', 'color', 'Emerald Green', '#0B5345', 2, 'AUR-CRS-EMR'),

    ('d6666666-6666-6666-6666-666666666666', 'size', 'EU 37 / UK 4', NULL, 4, 'BEL-STL-37'),
    ('d6666666-6666-6666-6666-666666666666', 'size', 'EU 38 / UK 5', NULL, 6, 'BEL-STL-38'),
    ('d6666666-6666-6666-6666-666666666666', 'size', 'EU 39 / UK 6', NULL, 5, 'BEL-STL-39'),
    ('d6666666-6666-6666-6666-666666666666', 'size', 'EU 40 / UK 7', NULL, 3, 'BEL-STL-40'),
    ('d6666666-6666-6666-6666-666666666666', 'size', 'EU 41 / UK 8', NULL, 2, 'BEL-STL-41'),

    ('d7777777-7777-7777-7777-777777777777', 'size', 'EU 38 / UK 5', NULL, 5, 'PAL-MUL-38'),
    ('d7777777-7777-7777-7777-777777777777', 'size', 'EU 39 / UK 6', NULL, 7, 'PAL-MUL-39'),
    ('d7777777-7777-7777-7777-777777777777', 'size', 'EU 40 / UK 7', NULL, 4, 'PAL-MUL-40');

-- Pairings
INSERT INTO public.pairings (id, title, bag_product_id, shoe_product_id, bundle_discount_percent, description)
VALUES
    (
        'e1111111-1111-1111-1111-111111111111',
        'The Black-Tie Gala Set: Venetian Minaudière & Bellissima Crystal Stiletto',
        'd3333333-3333-3333-3333-333333333333',
        'd6666666-6666-6666-6666-666666666666',
        15,
        'Save 15% when ordering the Venetian Crystal Clutch paired with the matching Bellissima Crystal Stiletto for weddings, galas, and red carpet occasions.'
    ),
    (
        'e2222222-2222-2222-2222-222222222222',
        'The Executive Power Duo: Sovereign Leather Tote & Paloma Sculpted Mule',
        'd1111111-1111-1111-1111-111111111111',
        'd7777777-7777-7777-7777-777777777777',
        10,
        'The ultimate luxury wardrobe pairing for women in business. Structured full-grain Italian leather elegance paired with all-day comfortable block heels.'
    )
ON CONFLICT (id) DO NOTHING;

-- Reviews
INSERT INTO public.reviews (product_id, author_name, rating, headline, comment, is_verified_buyer)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'Amina B.', 5, 'The leather quality is unmatched!', 'I took this tote to a board meeting in Lagos and received compliments the entire day. The structure is firm and holds my 14-inch laptop seamlessly.', true),
    ('d1111111-1111-1111-1111-111111111111', 'Chidinma O.', 5, 'Pure luxury in your hands', 'Heavy, rich calfskin and the gold hardware has a true 24K luster. Worth every single Naira.', true),
    ('d2222222-2222-2222-2222-222222222222', 'Zainab K.', 5, 'Best crossbody I own', 'The leather is so soft yet holds its shape. The sliding chain allows me to wear it long or double it up as an elegant shoulder bag.', true),
    ('d3333333-3333-3333-3333-333333333333', 'Folashade A.', 5, 'Breathtaking in person', 'Wore this to my sister wedding dinner. The sparkle is unreal under chandelier lights. Plus, it fits my phone without bulging!', true),
    ('d6666666-6666-6666-6666-666666666666', 'Ngozi E.', 5, 'Surprisingly comfortable for a high stiletto', 'The arch padding really makes a difference. Wore them for 6 hours straight without pain.', true);
