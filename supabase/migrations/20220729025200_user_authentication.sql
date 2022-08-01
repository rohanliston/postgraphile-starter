-- Defines the structure of JWTs used for authentication.
CREATE TYPE app_public.jwt_token AS (
  username VARCHAR(64),
  role     VARCHAR(32),
  user_id  UUID,
  exp      INTEGER
);

-- Authenticates a user with the given username and password.
CREATE FUNCTION app_public.authenticate(
  username TEXT,
  password TEXT
) RETURNS app_public.jwt_token as $$
DECLARE
  login app_private.login;
BEGIN
  SELECT * INTO login
    FROM app_private.login
    WHERE app_private.login.username = authenticate.username;

  IF login.password_hash = crypt(password, login.password_hash) THEN
    RETURN (
      login.username,
      login.role,
      login.user_id,
      extract(epoch from now() + interval '7 days')
    )::app_public.jwt_token;
  ELSE
    RAISE EXCEPTION 'Invalid credentials';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION app_public.authenticate(TEXT, TEXT) IS 'Authenticates a user with the given username and password.';