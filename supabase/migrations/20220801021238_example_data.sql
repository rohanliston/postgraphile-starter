-- Create some test organisations
INSERT INTO app_public.organisation (id, name) VALUES 
    ('00000000-0000-0000-0000-000000000000', 'Vandelay Industries'),
    ('00000000-0000-0000-0000-000000000001', 'J. Peterman Catalog');

-- Create some test products
INSERT INTO app_public.product (id, organisation_id, name, published) VALUES
    ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'Fine Latex Rubber Bands', 't'),
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'Latex Pants', 'f'),
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'European Carry-All', 't'),
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Urban Sombrero', 'f');

-- Create some test users
INSERT INTO app_public.user (id, name, email) VALUES
    ('00000000-0000-0000-0000-000000000000', 'George Costanza', 'george@vandelayindustries.com'),
    ('00000000-0000-0000-0000-000000000001', 'Jerry Seinfeld', 'jerry@vandelayindustries.com'),
    ('00000000-0000-0000-0000-000000000002', 'Elaine Benes', 'elaine@peterman.com'),
    ('00000000-0000-0000-0000-000000000003', 'J. Peterman', 'peterman@peterman.com'),
    ('00000000-0000-0000-0000-000000000004', 'Newman', 'newman@uspost.com');

-- Create logins for test users
INSERT INTO app_private.login (id, user_id, username, password_hash, role) VALUES
    ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'george@vandelayindustries.com', crypt('george', gen_salt('bf')), 'role_user'),
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'jerry@vandelayindustries.com', crypt('jerry', gen_salt('bf')), 'role_user'),
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'elaine@peterman.com', crypt('elaine', gen_salt('bf')), 'role_user'),
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'peterman@peterman.com', crypt('peterman', gen_salt('bf')), 'role_user'),
    ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000004', 'newman@uspost.com', crypt('newman', gen_salt('bf')), 'role_admin');

-- Add users to organisations
INSERT INTO app_public.member (organisation_id, user_id) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000');   -- Vandelay + George Costanza
INSERT INTO app_public.member (organisation_id, user_id) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000001');   -- Vandelay + Jerry Seinfeld
INSERT INTO app_public.member (organisation_id, user_id) VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');   -- Peterman + Elaine Benes
INSERT INTO app_public.member (organisation_id, user_id) VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003');   -- Peterman + J. Peterman
