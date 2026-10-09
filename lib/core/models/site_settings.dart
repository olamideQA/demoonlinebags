class AnnouncementSettings {
  final String text;
  final bool isActive;

  const AnnouncementSettings({
    required this.text,
    required this.isActive,
  });

  factory AnnouncementSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AnnouncementSettings(
        text: 'FREE VIP DELIVERY IN LAGOS OVER ₦150,000  •  PAY ON DELIVERY IN LAGOS & ABUJA  •  100% REAL LEATHER — NO PEELING, NO FAKE',
        isActive: true,
      );
    }
    return AnnouncementSettings(
      text: json['text'] as String? ?? 'FREE VIP DELIVERY IN LAGOS OVER ₦150,000  •  PAY ON DELIVERY IN LAGOS & ABUJA  •  100% REAL LEATHER — NO PEELING, NO FAKE',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'is_active': isActive,
  };
}

class HeaderSettings {
  final String brandName;
  final String tagline;

  const HeaderSettings({
    required this.brandName,
    required this.tagline,
  });

  factory HeaderSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HeaderSettings(
        brandName: 'LUXE LAGOS',
        tagline: 'LUXURY BAGS & SHOES • LAGOS • ABUJA • NATIONWIDE',
      );
    }
    return HeaderSettings(
      brandName: json['brand_name'] as String? ?? 'LUXE LAGOS',
      tagline: json['tagline'] as String? ?? 'LUXURY BAGS & SHOES • LAGOS • ABUJA • NATIONWIDE',
    );
  }

  Map<String, dynamic> toJson() => {
    'brand_name': brandName,
    'tagline': tagline,
  };
}

class HeroSlide {
  final String id;
  final String badge;
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaUrl;
  final String secondaryCtaText;
  final String secondaryCtaUrl;
  final String imageUrl;

  const HeroSlide({
    required this.id,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaUrl,
    required this.secondaryCtaText,
    required this.secondaryCtaUrl,
    required this.imageUrl,
  });

  factory HeroSlide.fromJson(Map<String, dynamic> json) {
    return HeroSlide(
      id: json['id'] as String? ?? 'slide-1',
      badge: json['badge'] as String? ?? 'LAGOS BESTSELLER • 2026 COLLECTION',
      title: json['title'] as String? ?? 'Pepper Them at Every Owambe.',
      subtitle: json['subtitle'] as String? ?? 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.',
      ctaText: json['cta_text'] as String? ?? 'SHOP BAGS',
      ctaUrl: json['cta_url'] as String? ?? '/shop',
      secondaryCtaText: json['secondary_cta_text'] as String? ?? 'SHOP MATCHING SETS',
      secondaryCtaUrl: json['secondary_cta_url'] as String? ?? '/pairings',
      imageUrl: json['image_url'] as String? ?? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'badge': badge,
    'title': title,
    'subtitle': subtitle,
    'cta_text': ctaText,
    'cta_url': ctaUrl,
    'secondary_cta_text': secondaryCtaText,
    'secondary_cta_url': secondaryCtaUrl,
    'image_url': imageUrl,
  };

  static const List<HeroSlide> defaultSlides = [
    HeroSlide(
      id: 's1',
      badge: 'LAGOS BESTSELLER • 2026 COLLECTION',
      title: 'Pepper Them at Every Owambe.',
      subtitle: 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.',
      ctaText: 'SHOP BAGS',
      ctaUrl: '/shop',
      secondaryCtaText: 'SHOP MATCHING SETS',
      secondaryCtaUrl: '/pairings',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
    ),
    HeroSlide(
      id: 's2',
      badge: 'NEW ARRIVAL • CHURCH TO BRUNCH',
      title: 'One Bag, From Desk to Dinner.',
      subtitle: 'Fine croc-finish shoulder bag for work in VI, brunch in Ikoyi and dinner after.',
      ctaText: 'SHOP SHOULDER BAGS',
      ctaUrl: '/shop',
      secondaryCtaText: 'SEE MATCHING SHOES',
      secondaryCtaUrl: '/pairings',
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1600&q=85',
    ),
    HeroSlide(
      id: 's3',
      badge: 'OWAMBE & WEDDING SEASON • LIMITED',
      title: 'Shine Like Candlelight.',
      subtitle: 'Crystal clutch that catches every light at weddings. Fits iPhone 16 Pro Max.',
      ctaText: 'SHOP EVENING BAGS',
      ctaUrl: '/shop',
      secondaryCtaText: 'EXPLORE ENSEMBLES',
      secondaryCtaUrl: '/pairings',
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1600&q=85',
    ),
    HeroSlide(
      id: 's4',
      badge: 'THE SHOE SALON • EFFORTLESS CO-ORD',
      title: 'Sculpted Mules & Heels.',
      subtitle: 'Engineered memory-foam arch support for 6-hour Owambe comfort without fatigue.',
      ctaText: 'THE SHOE SALON',
      ctaUrl: '/shop',
      secondaryCtaText: 'PAIR WITH BAGS',
      secondaryCtaUrl: '/pairings',
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1600&q=85',
    ),
  ];
}

class HeroSettings {
  final String badge;
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaUrl;
  final String secondaryCtaText;
  final String secondaryCtaUrl;
  final String imageUrl;
  final List<HeroSlide> slides;

  const HeroSettings({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaUrl,
    required this.secondaryCtaText,
    required this.secondaryCtaUrl,
    required this.imageUrl,
    this.slides = HeroSlide.defaultSlides,
  });

  factory HeroSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HeroSettings(
        badge: 'LAGOS BESTSELLER • 2026 COLLECTION',
        title: 'Pepper Them at Every Owambe.',
        subtitle: 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.',
        ctaText: 'SHOP BAGS',
        ctaUrl: '/shop',
        secondaryCtaText: 'SHOP MATCHING SETS',
        secondaryCtaUrl: '/pairings',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
        slides: HeroSlide.defaultSlides,
      );
    }

    List<HeroSlide> parsedSlides = HeroSlide.defaultSlides;
    if (json['slides'] != null && json['slides'] is List && (json['slides'] as List).isNotEmpty) {
      parsedSlides = (json['slides'] as List)
          .map((item) => HeroSlide.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return HeroSettings(
      badge: json['badge'] as String? ?? 'LAGOS BESTSELLER • 2026 COLLECTION',
      title: json['title'] as String? ?? 'Pepper Them at Every Owambe.',
      subtitle: json['subtitle'] as String? ?? 'Real Italian leather that will not peel in Lagos heat. Loved from Lekki to Maitama.',
      ctaText: json['cta_text'] as String? ?? 'SHOP BAGS',
      ctaUrl: json['cta_url'] as String? ?? '/shop',
      secondaryCtaText: json['secondary_cta_text'] as String? ?? 'SHOP MATCHING SETS',
      secondaryCtaUrl: json['secondary_cta_url'] as String? ?? '/pairings',
      imageUrl: json['image_url'] as String? ?? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
      slides: parsedSlides,
    );
  }

  Map<String, dynamic> toJson() => {
    'badge': badge,
    'title': title,
    'subtitle': subtitle,
    'cta_text': ctaText,
    'cta_url': ctaUrl,
    'secondary_cta_text': secondaryCtaText,
    'secondary_cta_url': secondaryCtaUrl,
    'image_url': imageUrl,
    'slides': slides.map((s) => s.toJson()).toList(),
  };
}

class FooterSettings {
  final String bio;
  final String email;
  final String phone;
  final String whatsapp;
  final String address;
  final String copyright;
  final String instagram;

  const FooterSettings({
    required this.bio,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.copyright,
    required this.instagram,
  });

  factory FooterSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FooterSettings(
        bio: 'Demo Online Bags is Nigeria\'s premier luxury handbag house and atelier. We craft structured full-grain leather handbags and perfectly paired sculpted footwear for discerning, modern African women who lead and inspire.',
        email: 'hello@luxelagos.ng',
        phone: '+234 810 123 4567',
        whatsapp: '+234 810 123 4567',
        address: '12 Admiralty Way, Lekki Phase 1, Lagos, Nigeria',
        copyright: '© 2026 LUXE LAGOS. ALL RIGHTS RESERVED.',
        instagram: 'https://instagram.com/luxelagos.ng',
      );
    }
    return FooterSettings(
      bio: json['bio'] as String? ?? 'Demo Online Bags is Nigeria\'s premier luxury handbag house and atelier. We craft structured full-grain leather handbags and perfectly paired sculpted footwear for discerning, modern African women who lead and inspire.',
      email: json['email'] as String? ?? 'hello@luxelagos.ng',
      phone: json['phone'] as String? ?? '+234 810 123 4567',
      whatsapp: json['whatsapp'] as String? ?? '+234 810 123 4567',
      address: json['address'] as String? ?? '12 Admiralty Way, Lekki Phase 1, Lagos, Nigeria',
      copyright: json['copyright'] as String? ?? '© 2026 LUXE LAGOS. ALL RIGHTS RESERVED.',
      instagram: json['instagram'] as String? ?? 'https://instagram.com/luxelagos.ng',
    );
  }

  Map<String, dynamic> toJson() => {
    'bio': bio,
    'email': email,
    'phone': phone,
    'whatsapp': whatsapp,
    'address': address,
    'copyright': copyright,
    'instagram': instagram,
  };
}

class GeneralSettings {
  final String currency;
  final String currencySymbol;
  final double freeShippingThreshold;

  const GeneralSettings({
    required this.currency,
    required this.currencySymbol,
    required this.freeShippingThreshold,
  });

  factory GeneralSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const GeneralSettings(
        currency: 'NGN',
        currencySymbol: '₦',
        freeShippingThreshold: 150000.0,
      );
    }
    return GeneralSettings(
      currency: json['currency'] as String? ?? 'NGN',
      currencySymbol: json['currency_symbol'] as String? ?? '₦',
      freeShippingThreshold: (json['free_shipping_threshold'] as num?)?.toDouble() ?? 150000.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'currency_symbol': currencySymbol,
    'free_shipping_threshold': freeShippingThreshold,
  };
}

class SiteSettings {
  final AnnouncementSettings announcement;
  final HeaderSettings header;
  final HeroSettings hero;
  final FooterSettings footer;
  final GeneralSettings general;

  const SiteSettings({
    required this.announcement,
    required this.header,
    required this.hero,
    required this.footer,
    required this.general,
  });

  factory SiteSettings.defaultSettings() {
    return SiteSettings(
      announcement: AnnouncementSettings.fromJson(null),
      header: HeaderSettings.fromJson(null),
      hero: HeroSettings.fromJson(null),
      footer: FooterSettings.fromJson(null),
      general: GeneralSettings.fromJson(null),
    );
  }

  SiteSettings copyWith({
    AnnouncementSettings? announcement,
    HeaderSettings? header,
    HeroSettings? hero,
    FooterSettings? footer,
    GeneralSettings? general,
  }) {
    return SiteSettings(
      announcement: announcement ?? this.announcement,
      header: header ?? this.header,
      hero: hero ?? this.hero,
      footer: footer ?? this.footer,
      general: general ?? this.general,
    );
  }
}
