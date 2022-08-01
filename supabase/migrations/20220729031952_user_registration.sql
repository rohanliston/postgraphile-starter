-- Registers a new user.
CREATE OR REPLACE FUNCTION app_public.register(
  name VARCHAR(32),
  email VARCHAR(64),
  password VARCHAR(32)
) RETURNS app_public.user AS $$
DECLARE
  user app_public.user;
BEGIN
  INSERT INTO app_public.user (name, email) VALUES
    (name, email)
    RETURNING * INTO user;

  INSERT INTO app_private.login (user_id, username, password_hash, role) VALUES
    ("user".id, "user".email, crypt(password, gen_salt('bf')), 'role_user');

  RETURN user;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION app_public.register(VARCHAR, VARCHAR, VARCHAR) IS 'Registers a single user and creates a login.';