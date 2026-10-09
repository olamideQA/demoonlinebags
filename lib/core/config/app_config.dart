class AppConfig {
  static const String appName = 'DEMO ONLINE BAGS';
  static const String appTagline = 'Luxury Handbags & Sculpted Footwear';
  
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
  static const String conciergeEmail = 'vip@demoonlinebags.com';
  static const String conciergePhone = '+234 800 DEMO BAGS';
  static const String instagramUrl = 'https://instagram.com/demoonlinebags';
}
