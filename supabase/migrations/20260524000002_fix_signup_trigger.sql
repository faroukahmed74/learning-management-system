-- Fix: "Database error saving new user" on registration
-- Cause: RLS blocked the handle_new_user() trigger from inserting profiles

-- Recreate trigger function with proper security settings
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role, status)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      split_part(COALESCE(NEW.email, 'user@local'), '@', 1)
    ),
    COALESCE(
      NULLIF(trim(NEW.raw_user_meta_data->>'role'), '')::user_role,
      'student'::user_role
    ),
    'pending_verification'::profile_status
  );
  RETURN NEW;
END;
$$;

-- Ensure trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Allow auth service (trigger) to insert profiles
DROP POLICY IF EXISTS profiles_insert_auth_admin ON profiles;
CREATE POLICY profiles_insert_auth_admin ON profiles
  FOR INSERT
  TO supabase_auth_admin
  WITH CHECK (true);

-- Allow users to insert their own profile (fallback)
DROP POLICY IF EXISTS profiles_insert_own ON profiles;
CREATE POLICY profiles_insert_own ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Grants for auth admin role
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;
GRANT INSERT ON public.profiles TO supabase_auth_admin;
GRANT SELECT ON public.profiles TO supabase_auth_admin;
