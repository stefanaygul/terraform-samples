-- Commands used to create the readonly user
CREATE ROLE readonly1 WITH LOGIN;
CREATE ROLE readonly2 WITH LOGIN;
GRANT CONNECT ON DATABASE recognition_engine TO readonly1, readonly2;
GRANT USAGE ON SCHEMA public TO readonly1, readonly2;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly1, readonly2;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly1, readonly2;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly1, readonly2;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO readonly1, readonly2;

--- To set the password:
-- ALTER ROLE readonly1 PASSWORD 'thenewpassword';
-- ALTER ROLE readonly2 PASSWORD 'thenewpassword';

--- To delete a role
-- REVOKE ALL ON ALL TABLES IN SCHEMA public FROM readonly;
-- REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM readonly;
-- REVOKE ALL ON DATABASE recognition_engine FROM readonly;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM readonly;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON SEQUENCES FROM readonly;
-- REVOKE USAGE ON SCHEMA public FROM readonly;
-- DROP ROLE readonly;