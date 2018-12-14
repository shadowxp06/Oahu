
DO $$
DECLARE
  x text;
BEGIN
  IF NOT EXISTS (SELECT * FROM pg_user WHERE usename = 'oahu_user') THEN
    CREATE ROLE oahu_user LOGIN PASSWORD 'password123';
  END IF;    

  GRANT ALL ON SCHEMA public TO postgres;
  GRANT ALL ON SCHEMA public TO public;
  GRANT ALL ON SCHEMA public TO oahu_user;

  GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO oahu_user;
  GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO oahu_user;
  GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO oahu_user;
  
END;
$$;