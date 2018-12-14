DO $$
DECLARE
    x text;
BEGIN
    DROP TYPE IF EXISTS public.msg_sec_level;

    DROP EXTENSION IF EXISTS pgcrypto;

    FOR x IN (select 'drop table if exists "' || tablename || '" cascade;' from pg_tables where schemaname = 'public') LOOP
        EXECUTE x;
    END LOOP;

    FOR x IN (select 'DROP FUNCTION IF EXISTS ' || oid::regprocedure || ' CASCADE;' from pg_proc where pronamespace =( SELECT oid FROM pg_namespace WHERE nspname =  'public')) LOOP
        EXECUTE x;
    END LOOP;
    
END;
$$;