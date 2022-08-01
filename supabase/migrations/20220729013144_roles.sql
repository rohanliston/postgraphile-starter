-- Anonymous role. Used by default when no role is specified.
DROP ROLE IF EXISTS role_anon;
CREATE ROLE role_anon;

-- Regular user role that is subject to Row-Level Security policies.
DROP ROLE IF EXISTS role_user;
CREATE ROLE role_user;

-- Admin role that has full access to all data.
-- Row-Level Security does not apply to users with role_admin role.
DROP ROLE IF EXISTS role_admin;
CREATE ROLE role_admin WITH BYPASSRLS;
