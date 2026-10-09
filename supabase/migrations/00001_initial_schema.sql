-- ==============================================================================
-- DEMO ONLINE BAGS - Core Ecommerce PostgreSQL Schema
-- High-Fashion Ladies Bags, Handbags & Footwear Platform
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Clean Existing Tables If Any (Safe re-runnable)
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

-- ==============================================================================
-- PROFILES TABLE (Linked with Supabase Auth)
-- ==============================================================================
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

-- ==============================================================================
-- CATEGORIES
-- ==============================================================================
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

-- ==============================================================================
-- COLLECTIONS
-- ==============================================================================
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

-- ==============================================================================
-- PRODUCTS
-- ==============================================================================
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

-- ==============================================================================
-- PRODUCT VARIANTS (Colors, Hardware, Shoe Sizes)
-- ==============================================================================
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

-- ==============================================================================
-- PAIRINGS (Matching Bag + Shoe Sets / Complete The Look)
-- ==============================================================================
CREATE TABLE public.pairings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    bag_product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    shoe_product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    bundle_discount_percent INT DEFAULT 10,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ORDERS
-- ==============================================================================
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

-- ==============================================================================
-- ORDER ITEMS
-- ==============================================================================
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

-- ==============================================================================
-- BANNERS & PROMOTIONS
-- ==============================================================================
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

-- ==============================================================================
-- REVIEWS
-- ==============================================================================
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

-- ==============================================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ==============================================================================
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

-- ==============================================================================
-- POLICIES (Public Can Read Products, Banners, Categories, Collections, Reviews)
-- ==============================================================================
CREATE POLICY "Public categories read" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Public collections read" ON public.collections FOR SELECT USING (true);
CREATE POLICY "Public products read" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public product_variants read" ON public.product_variants FOR SELECT USING (true);
CREATE POLICY "Public pairings read" ON public.pairings FOR SELECT USING (true);
CREATE POLICY "Public banners read" ON public.banners FOR SELECT USING (true);
CREATE POLICY "Public reviews read" ON public.reviews FOR SELECT USING (true);

-- Allow anyone to create an order (guest checkout & authenticated checkout)
CREATE POLICY "Public order creation" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Users read own orders" ON public.orders FOR SELECT USING (
    auth.uid() = user_id OR auth.role() = 'service_role' OR auth.role() = 'authenticated'
);
CREATE POLICY "Public order_items insert" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Public order_items select" ON public.order_items FOR SELECT USING (true);

-- Customer profile policies
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (
    auth.uid() = id OR auth.role() = 'service_role'
);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (
    auth.uid() = id
);
CREATE POLICY "Users insert own profile" ON public.profiles FOR INSERT WITH CHECK (
    auth.uid() = id
);

-- Storage buckets setup
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('products', 'products', true),
    ('banners', 'banners', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public Access Products Bucket" ON storage.objects FOR SELECT USING (bucket_id = 'products');
CREATE POLICY "Public Access Banners Bucket" ON storage.objects FOR SELECT USING (bucket_id = 'banners');
