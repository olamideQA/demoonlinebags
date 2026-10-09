class AppConfig {
  static const String appName = 'LUXE LAGOS';
  static const String appTagline = 'Luxury Bags & Comfy Shoes for Nigerian Women';
  
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://htvcavnqsgyjrbtqefxk.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0dmNhdm5xc2d5anJidHFlZnhrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTU2OTI3OCwiZXhwIjoyMTA3MTQ1Mjc4fQ.OJQecqa4JD2xRUZb4FDR-A3uAHpufwkDUUMT7oAVneI',
  );
  
  // Currency Settings
  static const String defaultCurrencySymbol = '₦';
  static const String defaultCurrencyCode = 'NGN';
  
  // Contact & Socials
  static const String conciergeEmail = 'hello@luxelagos.ng';
  static const String conciergePhone = '+234 906 791 4511';
  static const String whatsappUrl = 'https://wa.me/2349067914511?text=Hello%20LUXE%20LAGOS%2C%20I%20need%20help%20with%20a%20bag';
  static const String instagramUrl = 'https://instagram.com/luxelagos.ng';
}
