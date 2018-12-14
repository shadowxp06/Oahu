
CREATE OR REPLACE FUNCTION public.mark_message_as_read(
    "inToken" character varying,
    "inMessageID" integer)
  RETURNS json AS
$BODY$DECLARE
  CurrentUserID integer;
  MessageRec record;
  ThisUserRec record;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not found."}');
  END IF;

  -- Mark this message as read. 
  IF MessageRec."DeletedBy" IS NULL OR MessageRec."EditedBy" IS NULL THEN
    INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES (ThisUserRec."ReadGroupID","inMessageID") ON CONFLICT DO NOTHING;
  END IF;

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mark_message_as_read(character varying, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_message_as_read(character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION public.mark_message_as_read(character varying, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_message_as_read(character varying, integer) TO oahu_user;


CREATE OR REPLACE FUNCTION public.mark_message_as_unread(
    "inToken" character varying,
    "inMessageID" integer)
  RETURNS json AS
$BODY$DECLARE
  CurrentUserID integer;
  MessageRec record;
  ThisUserRec record;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not found."}');
  END IF;

  -- Mark this message as unread. 
  DELETE FROM "MessageGroupMembers" WHERE "MessageGroupID" = ThisUserRec."ReadGroupID" AND "MessageID" = "inMessageID";

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mark_message_as_unread(character varying, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_message_as_unread(character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION public.mark_message_as_unread(character varying, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_message_as_unread(character varying, integer) TO oahu_user;



CREATE OR REPLACE FUNCTION public.mark_thread_as_read(
    "inToken" character varying,
    "inMessageID" integer)
  RETURNS json AS
$BODY$DECLARE
  CurrentUserID integer;
  MessageRec record;
  ThisUserRec record;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not found."}');
  END IF;

  -- Mark parent message as read.
  INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES (ThisUserRec."ReadGroupID","inMessageID") ON CONFLICT DO NOTHING;

  -- Mark child messages as read.
  INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") 
      (SELECT ThisUserRec."ReadGroupID","ID" FROM "Messages" WHERE "ParentID" = "inMessageID")
      ON CONFLICT DO NOTHING;
  
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mark_thread_as_read(character varying, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_read(character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_read(character varying, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_read(character varying, integer) TO oahu_user;



CREATE OR REPLACE FUNCTION public.mark_thread_as_unread(
    "inToken" character varying,
    "inMessageID" integer)
  RETURNS json AS
$BODY$DECLARE
  CurrentUserID integer;
  MessageRec record;
  ThisUserRec record;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not found."}');
  END IF;

  -- Mark parent message as unread.
  DELETE FROM "MessageGroupMembers" WHERE "MessageGroupID" = ThisUserRec."ReadGroupID" AND "MessageID" = "inMessageID";

  -- Mark child messages as unread.
  --DELETE FROM "MessageGroupMembers" USING "Messages" 
  --       WHERE "Messages"."ParentID" = "inMessageID" AND "MessageGroupMembers"."MessageGroupID" = ThisUserRec."ReadGroupID";

  DELETE FROM "MessageGroupMembers" USING "Messages" 
         WHERE "MessageGroupID" = ThisUserRec."ReadGroupID" AND "MessageID" IN 
            (SELECT "ID" FROM "Messages" WHERE "ParentID" = "inMessageID");

  
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mark_thread_as_unread(character varying, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_unread(character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_unread(character varying, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.mark_thread_as_unread(character varying, integer) TO oahu_user;



CREATE OR REPLACE FUNCTION public.get_limited_thread_messages(
    "inToken" character varying,
    "inMessageID" integer,
    "inLimit" integer,
    "inOffset" integer)
  RETURNS jsonb AS
$BODY$DECLARE
  ThisUserID integer;
  ThisCourseID integer;
  ThisUserReadGroup integer;
  MessageRec record;
  Result jsonb;
  MessageRowResult jsonb;
  UserGroupResult jsonb;
  MessagePollResult jsonb;
  Count integer;
  CleanLimit integer;
  CleanOffset integer;

  ThisCourseRec record;
  IsCourseMember boolean;
  ThisUserGroupID integer; 
  ThisUserRec record;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT "ReadGroupID" INTO ThisUserReadGroup FROM "Users" WHERE "ID" = ThisUserID;

  -- Check if parent message exists
  --IF NOT EXISTS (SELECT 1 FROM "Messages" WHERE "ID" = "inMessageID" ) THEN
--    RETURN ('{"ErrNo" : "2", "Description" : "Thread MessageID does not exist."}');
--  END IF;  

  --SELECT "CourseID" INTO ThisCourseID FROM "Messages" WHERE "ID" = "inMessageID";
  
  -- Can user read messages from specified course?
  --IF NOT EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = ThisCourseID AND "UserID" = ThisUserID) THEN
--    RETURN ('{"ErrNo" : "3", "Description" : "User is not a member of this course."}');
--  END IF;  

  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = ThisUserID;

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Thread MessageID does not exist."}');
  END IF;  
    
  SELECT * INTO ThisCourseRec FROM "Courses" WHERE "ID" = MessageRec."CourseID";

  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = ThisCourseRec."ID" AND "UserID" = ThisUserID) THEN
    IsCourseMember = TRUE;
  ELSE
    IsCourseMember = FALSE;
  END IF;  

  IF MessageRec."ParentID" IS NULL THEN
    ThisUserGroupID = MessageRec."UserGroupID";
  ELSE
    ThisUserGroupID = db_get_parent_group(MessageRec."ParentID");
  END IF;

  -- Does the user have permission to read these messages.
  IF ThisUserGroupID IS NULL THEN
    -- it is a class message, so check if the user is in the class
    IF NOT IsCourseMember THEN
      RETURN ('{"ErrNo" : "4", "Description" : "User is not a member of this course and so does not have the permissions to read this message."}');
    END IF;  
  ELSE
    -- it is a group message so use group permissions
    UserGroupResult = get_usergroup_members(ThisUserRec."LoginName",ThisUserGroupID);
    IF (UserGroupResult->>'ErrNo') IS NOT NULL THEN
      RETURN UserGroupResult;
    ELSE
      UserGroupResult = jsonb_build_object('UserGroupMembers',UserGroupResult);  
    END IF;
  END IF;



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

  Result = '[]';
  Count = 0;
  FOR MessageRec IN SELECT "Messages"."ID","Messages"."CourseID","Messages"."UserID","Messages"."TimeCreated","Messages"."ParentID",
      "Messages"."Title","Messages"."Message","Messages"."hasAttachment","Messages"."ChildCount",
      db_message_is_read(ThisUserReadGroup,"Messages"."ID") AS isRead, "Messages"."UserGroupID","Messages"."LastEditedBy",
      "Users"."FirstName", "Users"."LastName","Messages"."Type","Messages"."Setting","Messages"."UserGroupID","Messages"."PollType",
      db_get_message_score("Messages"."ID") AS score
    FROM "Messages"
    LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"  
    WHERE ("Messages"."ParentID" = "inMessageID" OR "Messages"."ID" = "inMessageID") AND "DeletedBy" IS NULL AND "EditedBy" IS NULL  
    ORDER BY "Messages"."TimeCreated"
    LIMIT CleanLimit
    OFFSET CleanOffset
  LOOP
    MessageRowResult = to_jsonb(MessageRec);
    IF MessageRec."PollType" IS NOT NULL THEN
      -- Get poll results
      MessagePollResult = get_message_poll_votes("inToken",MessageRec."ID",TRUE);
      MessageRowResult = MessageRowResult || MessagePollResult;
    END IF;
    Result = Result || MessageRowResult;
    Count = Count + 1;
  END LOOP;



  -- Mark parent message as read.
--  INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES (ThisUserReadGroup,"inMessageID") ON CONFLICT DO NOTHING;

  -- Mark child messages as read.
--  INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") 
--      (SELECT ThisUserReadGroup,"ID" FROM "Messages" WHERE "ParentID" = "inMessageID")
--      ON CONFLICT DO NOTHING;

  --Result = jsonb_build_object('Count',Count,'ThreadMessages',Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_limited_thread_messages(character varying, integer, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.get_limited_thread_messages(character varying, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION public.get_limited_thread_messages(character varying, integer, integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.get_limited_thread_messages(character varying, integer, integer, integer) TO oahu_user;




CREATE OR REPLACE FUNCTION public.get_limited_usergroup_threads(
    "inToken" character varying,
    "inCourseID" integer,
    "inUserGroupID" integer,
    "inLimit" integer,
    "inOffset" integer)
  RETURNS jsonb AS
$BODY$DECLARE
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
      "Users"."FirstName", "Users"."LastName","Messages"."LastEditedBy"
  FROM "Messages"
  LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"
  WHERE "ParentID" IS NULL 
     AND "DeletedBy" IS NULL AND "EditedBy" IS NULL 
     AND (("inUserGroupID" IS NULL AND "UserGroupID" IS NULL AND "CourseID" = "inCourseID") -- The course threads are being requested
       OR ("inUserGroupID" IS NULL AND db_is_message_usergroup("UserGroupID") AND "CourseID" = "inCourseID") -- Targeted message threads are listed in course threads
       OR ("inUserGroupID" IS NOT NULL AND "UserGroupID" = "inUserGroupID")) -- A specific usergroup is being requested.
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
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.get_limited_usergroup_threads(character varying, integer, integer, integer, integer) TO oahu_user;



CREATE OR REPLACE FUNCTION public.get_message(
    "inToken" character varying,
    "inMessageID" integer)
  RETURNS jsonb AS
$BODY$DECLARE
  ThisUserID integer;
  ThisUserRec record;
  ThisCourseRec record;
  IsCourseMember boolean;
  ThisUserGroupID integer;
  ThisUserReadGroup integer;
  Permissions integer;
  Result jsonb;
  MessageRec record;
  UsergroupRec record;
  UserGroupResult jsonb;
  MessageRowResult jsonb;
  MessagePollResult jsonb;
  IsMember boolean;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;
  -- the user must exist to be logged in.
  SELECT * INTO ThisUserRec FROM "Users" WHERE "ID" = ThisUserID;

  -- Check if message exists
  IF NOT EXISTS (SELECT 1 FROM "Messages" WHERE "ID" = "inMessageID" ) THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Thread MessageID does not exist."}');
  END IF;  

  SELECT "ReadGroupID" INTO ThisUserReadGroup FROM "Users" WHERE "ID" = ThisUserID;


  SELECT "Messages"."ID","Messages"."ParentID","Messages"."CourseID","Messages"."UserID","Messages"."TimeCreated",
      "Messages"."Title","Messages"."Message","Messages"."hasAttachment","Messages"."ChildCount",
      db_message_is_read(ThisUserReadGroup,"Messages"."ID") AS isRead, "Messages"."UserGroupID","Messages"."LastEditedBy",
      "Users"."FirstName", "Users"."LastName","Messages"."Type","Messages"."Setting","Messages"."UserGroupID","Messages"."PollType",
      "Messages"."DeletedBy", "Messages"."EditedBy"
    INTO MessageRec
    FROM "Messages"
    LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"  
    WHERE "Messages"."ID" = "inMessageID";


  MessageRowResult = to_jsonb(MessageRec);
  result = jsonb_build_object('Message',MessageRowResult);

  SELECT * INTO ThisCourseRec FROM "Courses" WHERE "ID" = MessageRec."CourseID";

  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = ThisCourseRec."ID" AND "UserID" = ThisUserID) THEN
    IsCourseMember = TRUE;
  ELSE
    IsCourseMember = FALSE;
  END IF;  

  IF MessageRec."ParentID" IS NULL THEN
    ThisUserGroupID = MessageRec."UserGroupID";
  ELSE
    ThisUserGroupID = db_get_parent_group(MessageRec."ParentID");
  END IF;
  -- Does the user have permission to read these messages.
  IF ThisUserGroupID IS NULL THEN
    -- it is a class message, so check if the user is in the class
    IF NOT IsCourseMember THEN
      RETURN ('{"ErrNo" : "4", "Description" : "User is not a member of this course and so does not have the permissions to read this message."}');
    END IF;  
  ELSE
    -- it is a group message so use group permissions
    UserGroupResult = get_usergroup_members(ThisUserRec."LoginName",ThisUserGroupID);
    IF (UserGroupResult->>'ErrNo') IS NULL THEN
      result = result || jsonb_build_object('UserGroupMembers',UserGroupResult);  
    ELSE
      RETURN UserGroupResult;
    END IF;
  END IF;

  IF MessageRec."PollType" IS NOT NULL THEN
    -- Get poll results
    result = result || jsonb_build_object('PollResults',get_message_poll_votes("inToken",MessageRec."ID",TRUE));
  END IF;

  -- Mark this message as read. 
--  IF MessageRec."DeletedBy" IS NULL OR MessageRec."EditedBy" IS NULL THEN
--    INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES (ThisUserRec."ReadGroupID","inMessageID") ON CONFLICT DO NOTHING;
--  END IF;

  RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_message(character varying, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.get_message(character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION public.get_message(character varying, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.get_message(character varying, integer) TO oahu_user;


