-- Seed default language center
-- Run after migrations in Supabase SQL Editor

INSERT INTO centers (name, slug, timezone, email)
VALUES (
    'Main Language Center',
    'main-center',
    'Africa/Cairo',
    'info@languagecenter.com'
)
ON CONFLICT (slug) DO NOTHING;
