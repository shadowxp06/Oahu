-- Function: public.get_usergroup_threads(character varying, integer, integer)

-- DROP FUNCTION public.get_usergroup_threads(character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.get_usergroup_threads(
    "inToken" character varying,
    "inCourseID" integer,
    "inUserGroupID" integer)
  RETURNS json AS
$BODY$DECLARE
  ThisUserID integer;
  --ThisUserRec record;
  UserGroupMembers jsonb;
  UserThreads jsonb;
  result jsonb;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- get user's ReadGroupID
  --SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = ThisUserID;
  
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "2", "Description" : "The CourseID is not valid."}');
  END IF;

  -- Can user read messages from specified course?
  IF NOT EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = "inCourseID" AND "UserID" = ThisUserID) THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User is not a member of this course."}');
  END IF;  

  -- Check if usergroup is valid
  IF "inUserGroupID" IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM "UserGroups" WHERE "ID" = "inUserGroupID") THEN
      RETURN ('{"ErrNo" : "4", "Description" : "Invalid UserGroupID."}');
    END IF;  
  END IF;

--db_message_is_read(ThisUserRec."ReadGroupID","Messages"."ID")
  SELECT array_to_json(array_agg(row_to_json(r))) INTO UserThreads FROM
(SELECT "Messages"."ID","Messages"."CourseID","Messages"."UserID","Messages"."Type","Messages"."TimeCreated",
      "Messages"."Title","Messages"."Message","Messages"."hasAttachment","Messages"."ChildCount",
      db_message_is_read("Users"."ReadGroupID","Messages"."ID") AS isRead,"Messages"."UserGroupID",
      "Users"."FirstName", "Users"."LastName","Messages"."LastEditedBy"
  FROM "Messages"
  LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"
  WHERE "CourseID" = "inCourseID" AND "ParentID" IS NULL AND "DeletedBy" IS NULL AND "EditedBy" IS NULL AND ("UserGroupID" = "inUserGroupID" OR "UserGroupID" IS NULL)) r;  

  IF "inUserGroupID" IS NOT NULL THEN
    UserGroupMembers = get_usergroup_members("inToken","inUserGroupID");
    RETURN jsonb_build_object('UserGroupMembers',UserGroupMembers,'UserThreads',UserThreads);
  ELSE
    RETURN UserThreads;
  END IF;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_usergroup_threads(character varying, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.get_usergroup_threads(character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION public.get_usergroup_threads(character varying, integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.get_usergroup_threads(character varying, integer, integer) TO omsgroup;
