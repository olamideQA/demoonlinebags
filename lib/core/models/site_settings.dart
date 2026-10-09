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
        text: 'COMPLIMENTARY VIP COURIER DELIVERY ON ORDERS OVER ₦150,000  •  SAME-DAY LAGOS DISPATCH & 24–48HR NATIONWIDE  •  100% AUTHENTIC FULL-GRAIN LEATHER',
        isActive: true,
      );
    }
    return AnnouncementSettings(
      text: json['text'] as String? ?? 'COMPLIMENTARY VIP COURIER DELIVERY ON ORDERS OVER ₦150,000  •  SAME-DAY LAGOS DISPATCH & 24–48HR NATIONWIDE  •  100% AUTHENTIC FULL-GRAIN LEATHER',
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
        brandName: 'DEMO ONLINE BAGS',
        tagline: 'LUXURY HANDBAGS & FOOTWEAR • ATELIER LAGOS',
      );
    }
    return HeaderSettings(
      brandName: json['brand_name'] as String? ?? 'DEMO ONLINE BAGS',
      tagline: json['tagline'] as String? ?? 'LUXURY HANDBAGS & FOOTWEAR • ATELIER LAGOS',
    );
  }

  Map<String, dynamic> toJson() => {
    'brand_name': brandName,
    'tagline': tagline,
  };
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

  const HeroSettings({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaUrl,
    required this.secondaryCtaText,
    required this.secondaryCtaUrl,
    required this.imageUrl,
  });

  factory HeroSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HeroSettings(
        badge: 'NEW CAPSULE 2026 • LIMITED ATELIER EDITION',
        title: 'Command Every Room.\nUnapologetic Luxury.',
        subtitle: 'Crafted in certified Italian full-grain calfskin with non-tarnish 24K gold hardware. Structured for executive boardroom poise and sculpted for high-society wedding guest glamour.',
        ctaText: 'EXPLORE SIGNATURE BAGS',
        ctaUrl: '/shop',
        secondaryCtaText: 'COMPLETE THE LOOK (SETS)',
        secondaryCtaUrl: '/pairings',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
      );
    }
    return HeroSettings(
      badge: json['badge'] as String? ?? 'NEW CAPSULE 2026 • LIMITED ATELIER EDITION',
      title: json['title'] as String? ?? 'Command Every Room.\nUnapologetic Luxury.',
      subtitle: json['subtitle'] as String? ?? 'Crafted in certified Italian full-grain calfskin with non-tarnish 24K gold hardware. Structured for executive boardroom poise and sculpted for high-society wedding guest glamour.',
      ctaText: json['cta_text'] as String? ?? 'EXPLORE SIGNATURE BAGS',
      ctaUrl: json['cta_url'] as String? ?? '/shop',
      secondaryCtaText: json['secondary_cta_text'] as String? ?? 'COMPLETE THE LOOK (SETS)',
      secondaryCtaUrl: json['secondary_cta_url'] as String? ?? '/pairings',
      imageUrl: json['image_url'] as String? ?? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1600&q=85',
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
        email: 'concierge@demoonlinebags.com',
        phone: '+234 810 000 2247',
        whatsapp: '+234 810 000 2247',
        address: 'Victoria Island, Lagos, Nigeria',
        copyright: '© 2026 DEMO ONLINE BAGS ATELIER. ALL RIGHTS RESERVED.',
        instagram: 'https://instagram.com/demoonlinebags',
      );
    }
    return FooterSettings(
      bio: json['bio'] as String? ?? 'Demo Online Bags is Nigeria\'s premier luxury handbag house and atelier. We craft structured full-grain leather handbags and perfectly paired sculpted footwear for discerning, modern African women who lead and inspire.',
      email: json['email'] as String? ?? 'concierge@demoonlinebags.com',
      phone: json['phone'] as String? ?? '+234 810 000 2247',
      whatsapp: json['whatsapp'] as String? ?? '+234 810 000 2247',
      address: json['address'] as String? ?? 'Victoria Island, Lagos, Nigeria',
      copyright: json['copyright'] as String? ?? '© 2026 DEMO ONLINE BAGS ATELIER. ALL RIGHTS RESERVED.',
      instagram: json['instagram'] as String? ?? 'https://instagram.com/demoonlinebags',
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
