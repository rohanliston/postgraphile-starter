-- ==[ General access privileges ]===========================================================

-- Anonymous users can only authenticate or register.
GRANT USAGE ON SCHEMA app_public to role_anon;
GRANT EXECUTE ON FUNCTION app_public.authenticate TO role_anon;
GRANT EXECUTE ON FUNCTION app_public.register TO role_anon;

-- Regular users can CRUD public tables (subject to RLS policies) and execute public functions.
GRANT USAGE ON SCHEMA app_public to role_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app_public TO role_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA app_public TO role_user;

-- Admins have full privileges on all public tables.
GRANT USAGE ON SCHEMA app_public to role_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app_public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app_public TO role_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA app_public TO role_admin;

-- ==[ Row-Level Security (RLS) policies ]===================================================

-- Organisation policies
ALTER TABLE app_public.organisation ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see organisations they are a member of"
    ON app_public.organisation FOR SELECT
    TO role_user
    USING (id IN (
        SELECT organisation_id
        FROM app_public.member
        WHERE user_id = current_setting('jwt.claims.user_id', true)::UUID
    ));

-- User policies
ALTER TABLE app_public.user ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see other users who belong to the same organisations"
    ON app_public.user FOR SELECT
    TO role_user
    USING (id IN (
        SELECT user_id
        FROM app_public.member
        WHERE organisation_id IN (
            SELECT organisation_id
            FROM app_public.member
            WHERE user_id = current_setting('jwt.claims.user_id', true)::UUID
        )
    )); 

-- Product policies
ALTER TABLE app_public.product ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see unpublished products from their own organisations"
    ON app_public.product FOR SELECT
    TO role_user
    USING (published = true OR (
        organisation_id IN (
            SELECT organisation_id
            FROM app_public.member
            WHERE user_id = current_setting('jwt.claims.user_id', true)::UUID
        )
    ));

-- Member policies

-- To avoid infinite recursion, we need to use a function or view for cases
-- where a policy depends on its own table.
CREATE FUNCTION app_hidden.can_access(app_public.member) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER AS
$$BEGIN
    -- Avoid recursion if the member is the current user.
    IF ($1).user_id = current_setting('jwt.claims.user_id')::UUID THEN
        RETURN TRUE;
    END IF;
    
    -- Otherwise, recurse.
    RETURN EXISTS (
        SELECT 1 FROM app_public.member
        WHERE ($1).organisation_id = organisation_id
        AND user_id = current_setting('jwt.claims.user_id')::UUID
    );
END;$$;

ALTER TABLE app_public.member ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see members who belong to the same organisations"
    ON app_public.member FOR SELECT
    TO role_user
    USING (app_hidden.can_access(member));