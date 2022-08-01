-- Public schema: All tables and functions will be exposed to GraphQL.
-- Data can still be filtered/protected using Row-Level Security (RLS).
CREATE SCHEMA app_public;
COMMENT ON SCHEMA app_public IS 'Data and functions to be exposed via GraphQL.';

-- Hidden schema: Same privileges as public, but it's not intended
-- to be exposed publicly (i.e. implementation details, for internal use).
CREATE SCHEMA app_hidden;
COMMENT ON SCHEMA app_hidden IS 'Internal implementation details that should not be exposed to GraphQL.';

-- Private schema: For sensitive data such as passwords and access tokens.
-- Will not be exposed to GraphQL. No-one should be able to read this without
-- a SECURITY DEFINER function letting them selectively do things.
CREATE SCHEMA app_private;
COMMENT ON SCHEMA app_private IS 'Sensitive, encrypted/hashed data such as passwords and access tokens.';