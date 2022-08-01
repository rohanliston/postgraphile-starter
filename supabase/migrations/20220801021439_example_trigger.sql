-- Triggers a `user_registered` event whenever a new user is inserted.
DROP TRIGGER IF EXISTS user_notify ON app_public.user;
CREATE TRIGGER user_notify 
    AFTER INSERT ON app_public.user
    FOR EACH ROW EXECUTE PROCEDURE app_hidden.notify_trigger('user_registered');