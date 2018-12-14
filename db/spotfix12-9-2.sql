-- Fixes a bug where if the message is a member of a usergroup 
-- the system returned a session error

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
    IF NOT db_user_has_group_read_permission(ThisUserGroupID,ThisUserID) THEN
      RETURN ('{"ErrNo" : "5", "Description" : "User is not a member of this group and so does not have the permissions to read this message."}');
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
