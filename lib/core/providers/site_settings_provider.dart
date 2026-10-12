import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/site_settings.dart';

class SiteSettingsNotifier extends Notifier<SiteSettings> {
  @override
  SiteSettings build() {
    _loadFromSupabase();
    return SiteSettings.defaultSettings();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final response = await client.from('site_settings').select('key, value');
      final rows = response as List<dynamic>;

      AnnouncementSettings? announcement;
      HeaderSettings? header;
      HeroSettings? hero;
      FooterSettings? footer;
      GeneralSettings? general;

      for (final r in rows) {
        final key = r['key'] as String;
        final value = r['value'] as Map<String, dynamic>;

        if (key == 'announcement') {
          announcement = AnnouncementSettings.fromJson(value);
        } else if (key == 'header') {
          header = HeaderSettings.fromJson(value);
        } else if (key == 'hero') {
          hero = HeroSettings.fromJson(value);
        } else if (key == 'footer') {
          footer = FooterSettings.fromJson(value);
        } else if (key == 'general') {
          general = GeneralSettings.fromJson(value);
        }
      }

      state = state.copyWith(
        announcement: announcement,
        header: header,
        hero: hero,
        footer: footer,
        general: general,
      );
    } catch (e) {
      debugPrint('Note: Loaded default site settings (${e.toString()})');
    }
  }

  Future<void> updateAnnouncement({required String text, required bool isActive}) async {
    final updated = AnnouncementSettings(text: text, isActive: isActive);
    state = state.copyWith(announcement: updated);
    await _saveToSupabase('announcement', updated.toJson());
  }

  Future<void> updateHeader({required String brandName, required String tagline}) async {
    final updated = HeaderSettings(brandName: brandName, tagline: tagline);
    state = state.copyWith(header: updated);
    await _saveToSupabase('header', updated.toJson());
  }

  Future<void> updateHero({
    required String badge,
    required String title,
    required String subtitle,
    required String ctaText,
    required String ctaUrl,
    required String secondaryCtaText,
    required String secondaryCtaUrl,
    required String imageUrl,
  }) async {
    // Preserve existing slides so PUBLISH ALL never wipes banners 2-4.
    final updated = HeroSettings(
      badge: badge,
      title: title,
      subtitle: subtitle,
      ctaText: ctaText,
      ctaUrl: ctaUrl,
      secondaryCtaText: secondaryCtaText,
      secondaryCtaUrl: secondaryCtaUrl,
      imageUrl: imageUrl,
      slides: state.hero.slides,
    );
    state = state.copyWith(hero: updated);
    await _saveToSupabase('hero', updated.toJson());
  }

  /// Saves the full banners list. Singles mirror slide 1 as fallback.
  Future<void> updateHeroSlides(List<HeroSlide> slides) async {
    final safe = slides.isEmpty ? HeroSlide.defaultSlides : slides;
    final first = safe.first;
    final updated = HeroSettings(
      badge: first.badge,
      title: first.title,
      subtitle: first.subtitle,
      ctaText: first.ctaText,
      ctaUrl: first.ctaUrl,
      secondaryCtaText: first.secondaryCtaText,
      secondaryCtaUrl: first.secondaryCtaUrl,
      imageUrl: first.imageUrl,
      slides: safe,
    );
    state = state.copyWith(hero: updated);
    await _saveToSupabase('hero', updated.toJson());
  }

  Future<void> updateFooter({
    required String bio,
    required String email,
    required String phone,
    required String whatsapp,
    required String address,
    required String copyright,
    required String instagram,
  }) async {
    final updated = FooterSettings(
      bio: bio,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      address: address,
      copyright: copyright,
      instagram: instagram,
    );
    state = state.copyWith(footer: updated);
    await _saveToSupabase('footer', updated.toJson());
  }

  Future<void> updateGeneral({
    required String currency,
    required String currencySymbol,
    required double freeShippingThreshold,
  }) async {
    final updated = GeneralSettings(
      currency: currency,
      currencySymbol: currencySymbol,
      freeShippingThreshold: freeShippingThreshold,
    );
    state = state.copyWith(general: updated);
    await _saveToSupabase('general', updated.toJson());
  }

  Future<void> reload() => _loadFromSupabase();

  Future<bool> _saveToSupabase(String key, Map<String, dynamic> value) async {
    try {
      final client = Supabase.instance.client;
      await client.from('site_settings').upsert(
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'key',
      );
      return true;
    } catch (e) {
      debugPrint('Failed to persist setting $key to Supabase: $e');
      return false;
    }
  }
}

final siteSettingsProvider = NotifierProvider<SiteSettingsNotifier, SiteSettings>(() {
  return SiteSettingsNotifier();
});
