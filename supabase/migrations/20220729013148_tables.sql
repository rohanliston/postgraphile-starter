CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Organisation: An organisation (e.g. a company) to which members can belong.
CREATE TABLE app_public.organisation (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       CITEXT      NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE app_public.organisation IS 'An organisation (e.g. a company) to which members can belong.';
CREATE INDEX ON app_public.organisation (name);

-- User: A user of the system.
CREATE TABLE app_public.user (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(32) NOT NULL,
    email      CITEXT      NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE app_public.user IS 'A user of the system.';
CREATE INDEX ON app_public.user (name);
CREATE INDEX ON app_public.user (email);

-- (PRIVATE) Login: Login details used by a user to access the system.
CREATE TABLE app_private.login (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID         NOT NULL REFERENCES app_public.user (id) ON DELETE CASCADE,
    username      CITEXT       NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    role          VARCHAR(32)  NOT NULL DEFAULT 'role_user',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);
COMMENT ON TABLE app_private.login IS 'Login details used by a user to access the system.';
COMMENT ON COLUMN app_private.login.password_hash IS 'An opaque hash of the user password.';
CREATE INDEX ON app_private.login (user_id);
CREATE INDEX ON app_private.login (username);
CREATE INDEX ON app_private.login (role);

-- Member: A user who belongs to an organisation.
CREATE TABLE app_public.member (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    organisation_id UUID        NOT NULL REFERENCES app_public.organisation (id),
    user_id         UUID        NOT NULL REFERENCES app_public.user (id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE app_public.member IS 'A user who belongs to an organisation.';
CREATE INDEX ON app_public.member (organisation_id);
CREATE INDEX ON app_public.member (user_id);

-- Product: A product sold by an organisation.
CREATE TABLE app_public.product (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    organisation_id UUID        NOT NULL REFERENCES app_public.organisation (id),
    name            VARCHAR(32) NOT NULL,
    published       BOOLEAN     NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (organisation_id, name)
);
COMMENT ON TABLE app_public.product IS 'A product sold by an organisation.';
COMMENT ON COLUMN app_public.product.published IS 'Whether the product is published or not. Unpublished products are only visible to members of the organisation.';
CREATE INDEX ON app_public.product (organisation_id);
CREATE INDEX ON app_public.product (name);
CREATE INDEX ON app_public.product (published);