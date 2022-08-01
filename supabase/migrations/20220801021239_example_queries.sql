CREATE EXTENSION IF NOT EXISTS "plv8";

-- Returns true if the current user is an admin.
CREATE OR REPLACE FUNCTION app_public.is_admin() RETURNS BOOLEAN AS $$
    SELECT current_setting('jwt.claims.role') = 'role_admin';
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION app_public.is_admin() IS 'Returns true if the current user is an admin.';

-- Returns all products that have been published.
CREATE OR REPLACE FUNCTION app_public.published_products() RETURNS SETOF app_public.product AS $$
    SELECT * FROM app_public.product WHERE published = true;
$$ LANGUAGE SQL STABLE;

-- Example function using JavaScript (plv8).
CREATE FUNCTION javascript_test(keys text[], vals text[]) RETURNS text AS $$
  var object = {}
  for (var i = 0; i < keys.length; i++) {
    object[keys[i]] = vals[i]
  }
  return JSON.stringify(object)
$$ LANGUAGE plv8 STABLE STRICT;