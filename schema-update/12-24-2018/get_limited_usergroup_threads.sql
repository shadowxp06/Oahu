-- FUNCTION: public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer)

-- DROP FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.get_limited_usergroup_threads(
	"inToken" character varying,
	"inCourseID" integer,
	"inUserGroupID" integer,
	"inLimit" integer,
	"inOffset" integer)
    RETURNS jsonb
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  ThisUserID integer;
  --ThisUserRec record;
  ThisCourseRec record;
  UserGroupMembers jsonb;
  UserThreads jsonb;
  result jsonb;
  Count integer;
  CleanLimit integer;
  CleanOffset integer;
  ThisUserReadgroupID integer;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- get user's ReadGroupID
  --SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = ThisUserID;
  

  IF "inLimit" IS NULL OR "inLimit" < 1 OR "inLimit" > 10000 THEN
    CleanLimit = 10000;
  ELSE
    CleanLimit = "inLimit";
  END IF;

  IF "inOffset" IS NULL OR "inOffset" < 0 OR "inOffset" > 10000 THEN
    CleanOffset = 0;
  ELSE
    CleanOffset = "inOffset";
  END IF;

  IF "inUserGroupID" IS NOT NULL THEN
  -- Check if usergroup is valid
    IF NOT EXISTS (SELECT 1 FROM "UserGroups" WHERE "ID" = "inUserGroupID") THEN
      RETURN ('{"ErrNo" : "4", "Description" : "Invalid UserGroupID."}');
    END IF;  
    -- Check if user has permission to access the group
    UserGroupMembers = get_usergroup_members("inToken","inUserGroupID");
    IF (UserGroupMembers->>'ErrNo') IS NOT NULL THEN
      RETURN UserGroupMembers;  -- return the error code
    END IF;  
  ELSE
    -- check if course exists
    SELECT * INTO ThisCourseRec FROM "Courses" WHERE "ID" = "inCourseID";
    IF NOT FOUND THEN
      RETURN ('{"ErrNo" : "2", "Description" : "The CourseID is not valid."}');
    END IF;
    -- check if user is in the course
    IF NOT EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = ThisCourseRec."ID" AND "UserID" = ThisUserID) THEN
      RETURN ('{"ErrNo" : "2", "Description" : "The user is not a member of this course."}');
    END IF;
  END IF;

  SELECT "ReadGroupID" INTO ThisUserReadgroupID FROM "Users" WHERE "ID" = ThisUserID;

--db_message_is_read(ThisUserRec."ReadGroupID","Messages"."ID")
  SELECT jsonb_agg(r) INTO UserThreads FROM
(SELECT "Messages"."ID","Messages"."CourseID","Messages"."UserID","Messages"."Type","Messages"."TimeCreated",
      "Messages"."Title","Messages"."Message","Messages"."hasAttachment","Messages"."ChildCount",
      db_message_is_read(ThisUserReadgroupID,"Messages"."ID") AS isRead,"Messages"."UserGroupID",
      "Users"."FirstName", "Users"."LastName","Messages"."LastEditedBy","Messages"."Setting"
  FROM "Messages"
  LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"
  WHERE "ParentID" IS NULL 
     AND "DeletedBy" IS NULL AND "EditedBy" IS NULL 
     AND (("inUserGroupID" IS NULL AND "UserGroupID" IS NULL AND "CourseID" = "inCourseID") -- All thread messages in the course
       OR ("inUserGroupID" IS NULL AND db_user_has_group_read_permission("UserGroupID",ThisUserID) AND "CourseID" = "inCourseID") -- All message threads in the course groups the user is a member.
       OR ("inUserGroupID" IS NOT NULL AND "UserGroupID" = "inUserGroupID")) -- A specific usergroup is being requested, so only get threads from that group.
  ORDER BY "Messages"."TimeCreated"
  LIMIT CleanLimit
  OFFSET CleanOffset ) r;  

 SELECT count(*) INTO Count FROM jsonb_array_elements(UserThreads);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN UserThreads;
  END IF;  
    --RETURN jsonb_build_object('Count',Count,'UserThreads',UserThreads);
    --RETURN jsonb_build_object('Count',Count,'UserGroupMembers',UserGroupMembers,'UserThreads',UserThreads);
END;
$BODY$;

ALTER FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO postgres;

GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO oahu_user;

