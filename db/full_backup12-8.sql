PGDMP     3    2                v            omsdiscussions    10.5    10.5 T   \	           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            ]	           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            ^	           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            _	           1262    16731    omsdiscussions    DATABASE     �   CREATE DATABASE omsdiscussions WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
    DROP DATABASE omsdiscussions;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            `	           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    4            a	           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO oahu_user;
                  postgres    false    4                        3079    12278    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            b	           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    20138    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    4            c	           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    2            T           1255    20175 G   add_instructor_to_course(character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.add_instructor_to_course("inToken" character varying, "inInstructorLoginName" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  InstructorUserID integer;
  AddUserRetVal json;
  ThisSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);

  -- Check for valid permissions
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions != 999  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "Only admins can add instructor to courses."}');
  END IF;

  -- check if user exists
  InstructorUserID = db_get_user_id("inInstructorLoginName",ThisSchool);
  IF InstructorUserID IS NULL THEN
    -- The user is not in database.  
    AddUserRetVal = db_add_user("inInstructorLoginName",ThisSchool);
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      InstructorUserID = db_get_user_id("inInstructorLoginName",ThisSchool);
    END IF;
  END IF;

  -- Check if the user has already been added to the class
  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "UserID"= InstructorUserID AND "CourseID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "The TA is already added to the course."}');
  END IF;

  -- The inputs should be valid at this point so insert user
  INSERT INTO "CourseMembers" ("UserID","CourseID","UserType") 
    VALUES (InstructorUserID,"inCourseID", 3);
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$$;
 �   DROP FUNCTION public.add_instructor_to_course("inToken" character varying, "inInstructorLoginName" character varying, "inCourseID" integer);
       public       postgres    false    1    4            d	           0    0    FUNCTION add_instructor_to_course("inToken" character varying, "inInstructorLoginName" character varying, "inCourseID" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_instructor_to_course("inToken" character varying, "inInstructorLoginName" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    340                       1255    20176 >   add_message_group_members(character varying, integer, integer)    FUNCTION     )  CREATE FUNCTION public.add_message_group_members("inToken" character varying, "inMessageGroupID" integer, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  thisCourseID integer;
  Permissions integer;
  MessageGroupRec record;
  MessageGroupUserID integer;
  MessageGroupID integer;
BEGIN
  -- check if message group exists
  SELECT * INTO MessageGroupRec FROM "MessageGroups" WHERE "ID" = "inMessageGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The MessageGroupID is not valid."}');
  END IF;

  MessageGroupUserID = MessageGroupRec."UserID";
  thisCourseID = MessageGroupRec."CourseID";
  MessageGroupID = MessageGroupRec."ID";
  
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(thisCourseID,CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user is not a member of this course."}');
  END IF;

  -- check if user owns this message group.
  IF MessageGroupUserID != CurrentUserID THEN
    RETURN ('{"ErrNo" : "4", "Description" : "One cannot add messages to another''s group."}');
  END IF;

  -- check if message is already added to group
  IF EXISTS (SELECT 1 FROM "MessageGroupMembers" WHERE "MessageID" = "inMessageID" AND "MessageGroupID" = "inMessageGroupID") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Message is already added to group."}');
  END IF;
      
  -- inputs should be good so insert
  INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES ("inMessageGroupID","inMessageID");

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;
$$;
 �   DROP FUNCTION public.add_message_group_members("inToken" character varying, "inMessageGroupID" integer, "inMessageID" integer);
       public       postgres    false    1    4            e	           0    0 r   FUNCTION add_message_group_members("inToken" character varying, "inMessageGroupID" integer, "inMessageID" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_message_group_members("inToken" character varying, "inMessageGroupID" integer, "inMessageID" integer) TO oahu_user;
            public       postgres    false    270                       1255    20177 D   add_message_poll_item(character varying, integer, character varying)    FUNCTION     �  CREATE FUNCTION public.add_message_poll_item("inToken" character varying, "inMessageID" integer, "inName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageRec record;
  CurrentUserID integer;
  ThisCourseID integer;
  Permissions integer;
BEGIN
  -- Check if MessageID is valid
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF MessageRec IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This MessageID is not valid."}');
  END IF;  

  -- Check if message is a poll type
  IF MessageRec."Type" != 2 THEN
    RETURN ('{"ErrNo" : "6", "Description" : "Message is not poll type."}');
  END IF;
 
  ThisCourseID = MessageRec."CourseID";

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;  
  Permissions = db_get_permission(MessageRec."CourseID",CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to access this class."}');
  END IF;

  IF "inName" = '' OR "inName" IS NULL THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Name cannot be an empty field."}');
  END IF;

  -- check if poll item is already added to the message
  IF EXISTS (SELECT 1 FROM "MessagePollItem" WHERE "Name" = "inName") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Item is already added to message."}');
  END IF;

  -- Inputs are good so insert
  INSERT INTO "MessagePollItem" ("MessageID","Name") VALUES ("inMessageID","inName");
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 |   DROP FUNCTION public.add_message_poll_item("inToken" character varying, "inMessageID" integer, "inName" character varying);
       public       postgres    false    1    4            f	           0    0 n   FUNCTION add_message_poll_item("inToken" character varying, "inMessageID" integer, "inName" character varying)    ACL     �   GRANT ALL ON FUNCTION public.add_message_poll_item("inToken" character varying, "inMessageID" integer, "inName" character varying) TO oahu_user;
            public       postgres    false    271            X           1255    20178 :   add_message_poll_vote(character varying, integer, integer)    FUNCTION     �  CREATE FUNCTION public.add_message_poll_vote("inToken" character varying, "inMessagePollItemID" integer, "inValue" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessagePollItemRec record;
  MessageRec record;
  CurrentUserID integer;
  ThisCourseID integer;
  Permissions integer;
BEGIN
  -- Check if MessageID is valid
  SELECT * INTO MessagePollItemRec FROM "MessagePollItem" WHERE "ID" = "inMessagePollItemID";
  IF MessagePollItemRec IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This MessagePollItem is not valid."}');
  END IF;  

  -- we need to extract the courseID from Messages
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = MessagePollItemRec."MessageID";

  ThisCourseID = MessageRec."CourseID";

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(ThisCourseID,CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to access this class."}');
  END IF;

  -- check if the user has already voted on single vote poll.
  IF MessageRec."PollType" = 1 OR MessageRec."PollType" = 3 THEN
    IF EXISTS (SELECT 1 FROM "MessagePollVote" WHERE "MessageID" = MessagePollItemRec."MessageID" AND "VotingUserID" = CurrentUserID) THEN
      RETURN ('{"ErrNo" : "4", "Description" : "This user has already voted."}');
    END IF;
  END IF;

  -- Inputs are good so insert
  -- Check if already voted (use if/then and insert/update if want user to edit votes)
  IF EXISTS (SELECT 1 FROM "MessagePollVote" WHERE "MessagePollItemID" = "inMessagePollItemID" AND "VotingUserID" = CurrentUserID) THEN
    UPDATE "MessagePollVote" SET "Value" = "inValue" WHERE "MessagePollItemID" = "inMessagePollItemID" AND "VotingUserID" = CurrentUserID;
  ELSE
    INSERT INTO "MessagePollVote" ("MessagePollItemID","VotingUserID","Value","MessageID") VALUES ("inMessagePollItemID",CurrentUserID,"inValue",MessagePollItemRec."MessageID");
  END IF;  

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 {   DROP FUNCTION public.add_message_poll_vote("inToken" character varying, "inMessagePollItemID" integer, "inValue" integer);
       public       postgres    false    1    4            g	           0    0 m   FUNCTION add_message_poll_vote("inToken" character varying, "inMessagePollItemID" integer, "inValue" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_message_poll_vote("inToken" character varying, "inMessagePollItemID" integer, "inValue" integer) TO oahu_user;
            public       postgres    false    344                       1255    20179 =   add_message_to_usergroup(character varying, integer, integer)    FUNCTION     �	  CREATE FUNCTION public.add_message_to_usergroup("inToken" character varying, "inMessageID" integer, "inUsergroupID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  GroupPermissions integer;
  UserPermissions integer;
  UserGroupRec record;
  MessageRec record;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;    

  --Check if GroupID is valid
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inUsergroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This GroupID is not valid."}');
  END IF;  

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This MessageID is not valid."}');
  END IF;
  
  -- Only thread messages can be moved.  It gets too messy trying to move a message in the middle of a thread.
  -- if you need that add the message to the other usergroups messagegroup which is permitted.
  IF MessageRec."ParentID" IS NOT NULL THEN
    -- This is not a message thread post.
    RETURN ('{"ErrNo" : "4", "Description" : "Message must be a thread message to be moved."}');
  END IF;

  -- Who can do this?  system admins, instructors, TAs, and message owners if they have write permission on the group

  UserPermissions = db_get_permission(MessageRec."CourseID",CurrentUserID);
  GroupPermissions = db_get_group_permissions(UserGroupRec."ID",CurrentUserID);
  IF UserPermissions < 2 THEN
    -- If UserPermissions >=2 We are a system admin, instructor, or TA so we are allowed to do this.  
    -- However, if Userpermissions < 2 then further tests are required

    -- Does user own the message?
    IF MessageRec."UserID" != CurrentUserID THEN
      RETURN ('{"ErrNo" : "5", "Description" : "Permission denied.  User is not responsible for this message."}');
    END IF;

    -- Does the user have write permission in the group
    IF GroupPermissions = 3 THEN
      --User is read only in this group
      RETURN ('{"ErrNo" : "6", "Description" : "Permission denied.  User is read only in this group."}');
    END IF;
  END IF;

  UPDATE "Messages" SET "UserGroupID" = UserGroupRec."ID" WHERE "Messages"."ID" = "inMessageID";

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 |   DROP FUNCTION public.add_message_to_usergroup("inToken" character varying, "inMessageID" integer, "inUsergroupID" integer);
       public       postgres    false    4    1            h	           0    0 n   FUNCTION add_message_to_usergroup("inToken" character varying, "inMessageID" integer, "inUsergroupID" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_message_to_usergroup("inToken" character varying, "inMessageID" integer, "inUsergroupID" integer) TO oahu_user;
            public       postgres    false    272            Z           1255    20180 5   add_message_vote(character varying, integer, integer)    FUNCTION     �  CREATE FUNCTION public.add_message_vote("inToken" character varying, "inMessageID" integer, "inScore" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageRec record;
  CurrentUserID integer;
  ThisCourseID integer;
  Permissions integer;
BEGIN
  -- Check if MessageID is valid
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This MessageID is not valid."}');
  END IF;  

  ThisCourseID = MessageRec."CourseID";

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(ThisCourseID,CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to access this class."}');
  END IF;

  -- Check if already voted (use if/then and insert/update if want user to edit votes)
  IF EXISTS (SELECT 1 FROM "MessageVotes" WHERE "MessageID" = "inMessageID" AND "UserID" = CurrentUserID) THEN
    DELETE FROM "MessageVotes" WHERE "MessageID" = "inMessageID" AND "UserID" = CurrentUserID;
	RETURN ('{"ErrNo": "999", "Description":"Vote has been removed"}');
  END IF;  

  -- Inputs are good so insert
  INSERT INTO "MessageVotes" ("MessageID","UserID","Score") VALUES ("inMessageID",CurrentUserID,"inScore");
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 n   DROP FUNCTION public.add_message_vote("inToken" character varying, "inMessageID" integer, "inScore" integer);
       public       postgres    false    1    4            i	           0    0 `   FUNCTION add_message_vote("inToken" character varying, "inMessageID" integer, "inScore" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_message_vote("inToken" character varying, "inMessageID" integer, "inScore" integer) TO oahu_user;
            public       postgres    false    346            [           1255    20181 D   add_student_to_course(character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.add_student_to_course("inToken" character varying, "inStudentLoginName" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  StudentUserID integer;
  AddUserRetVal json;
  ThisSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- Check Permissions
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 2  THEN   -- admin is 999 and instructor is 3  TA is 2
    RETURN ('{"ErrNo" : "3", "Description" : "This user must be an admin, instructor, or TA to add a student."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);

  -- check if user exists
  StudentUserID = db_get_user_id("inStudentLoginName",ThisSchool);
  IF StudentUserID IS NULL THEN
    -- The user is not in database.  
    AddUserRetVal = db_add_user("inStudentLoginName",ThisSchool);
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      StudentUserID = db_get_user_id("inStudentLoginName",ThisSchool);
    END IF;
  END IF;

  -- Check if the user has already been added to the class
  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "UserID"= StudentUserID AND "CourseID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "The student is already added to the course."}');
  END IF;

  -- The inputs should be valid at this point so insert user
  INSERT INTO "CourseMembers" ("UserID","CourseID","UserType") 
    VALUES (StudentUserID,"inCourseID", 1);
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$$;
 �   DROP FUNCTION public.add_student_to_course("inToken" character varying, "inStudentLoginName" character varying, "inCourseID" integer);
       public       postgres    false    1    4            j	           0    0 y   FUNCTION add_student_to_course("inToken" character varying, "inStudentLoginName" character varying, "inCourseID" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_student_to_course("inToken" character varying, "inStudentLoginName" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    347                       1255    20182 ?   add_ta_to_course(character varying, character varying, integer)    FUNCTION     [  CREATE FUNCTION public.add_ta_to_course("inToken" character varying, "inTAloginName" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  TAuserID integer;
  AddUserRetVal json;
  ThisSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- Check for valid permissions
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 3  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user must be instructor in this course or admin to add a TA."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);
  -- check if user exists
  TAuserID = db_get_user_id("inTAloginName",ThisSchool);
  IF TAuserID IS NULL THEN
    -- The user is not in database.  
    AddUserRetVal = db_add_user("inTAloginName",ThisSchool);
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      TAuserID = db_get_user_id("inTAloginName",ThisSchool);
    END IF;
  END IF;

  -- Check if the user has already been added to the class
  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "UserID"= TAuserID AND "CourseID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "The TA is already added to the course."}');
  END IF;

  -- The inputs should be valid at this point so insert user
  INSERT INTO "CourseMembers" ("UserID","CourseID","UserType") 
    VALUES (TAuserID,"inCourseID", 2);
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$$;
 }   DROP FUNCTION public.add_ta_to_course("inToken" character varying, "inTAloginName" character varying, "inCourseID" integer);
       public       postgres    false    1    4            k	           0    0 o   FUNCTION add_ta_to_course("inToken" character varying, "inTAloginName" character varying, "inCourseID" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_ta_to_course("inToken" character varying, "inTAloginName" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    273            >           1255    20183 I   add_user_to_group(character varying, integer, character varying, integer)    FUNCTION     %
  CREATE FUNCTION public.add_user_to_group("inToken" character varying, "inGroupID" integer, "inNewUserName" character varying, "inNewUserType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  GroupUserID integer;
  Permissions integer;
  GroupPermissions integer;
  UserGroupRec record;
  ThisCourseID integer;
  --ThisUserType integer;
  ThisSchool integer;
  --ThisGroupName character varying;
BEGIN
  --Check if GroupID is valid
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inGroupID";
  IF UserGroupRec IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This GroupID is not valid."}');
  END IF;  
  ThisCourseID = UserGroupRec."CourseID";

  --IF NOT EXISTS (SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inGroupID") THEN
--    RETURN ('{"ErrNo" : "1", "Description" : "ThGroupID is not valid."}');
--  END IF;

  
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    

  ThisSchool = db_get_school(CurrentUserID);
  
  --Check if new user exists in system
  GroupUserID = db_get_user_id("inNewUserName",ThisSchool);
  IF GroupUserID IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not exist in the system. Users must be added to system first"}');
  END IF;
  --Permissions = db_get_permission(ThisCourseID,CurrentUserID);
  --IF Permissions < 1  THEN
  --  RETURN ('{"ErrNo" : "4", "Description" : "New group member is not in this course."}');
  --END IF;  

  -- check if current user is an admin for the group.
  GroupPermissions = db_get_group_permissions(UserGroupRec."ID",CurrentUserID);
  IF GroupPermissions != 1  THEN
    RETURN ('{"ErrNo" : "4", "Description" : "This user does not have permission to do add members."}');
  END IF;

  -- check if new user is already added to group
  RAISE NOTICE 'GroupUserID: %', GroupUserID;
  IF EXISTS (SELECT 1 FROM "UserGroupMembers" WHERE "UserID" = GroupUserID) THEN
    RETURN ('{"ErrNo" : "5", "Description" : "User is already added to group."}');
  END IF;
    
  -- check if usertype is valid
  IF "inNewUserType" < 1 OR "inNewUserType" > 4 THEN
    RETURN ('{"ErrNo" : "6", "Description" : "User type is invalid."}');
  END IF;
  
  -- looks good...insert!
  INSERT INTO "UserGroupMembers" ("GroupID","UserID","UserType") VALUES ("inGroupID",GroupUserID,"inNewUserType");

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public.add_user_to_group("inToken" character varying, "inGroupID" integer, "inNewUserName" character varying, "inNewUserType" integer);
       public       postgres    false    4    1            l	           0    0 �   FUNCTION add_user_to_group("inToken" character varying, "inGroupID" integer, "inNewUserName" character varying, "inNewUserType" integer)    ACL     �   GRANT ALL ON FUNCTION public.add_user_to_group("inToken" character varying, "inGroupID" integer, "inNewUserName" character varying, "inNewUserType" integer) TO oahu_user;
            public       postgres    false    318            m	           0    0    FUNCTION armor(bytea)    ACL     8   GRANT ALL ON FUNCTION public.armor(bytea) TO oahu_user;
            public       postgres    false    336            n	           0    0 %   FUNCTION armor(bytea, text[], text[])    ACL     H   GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO oahu_user;
            public       postgres    false    337            \           1255    20184 4   create_message(character varying, character varying)    FUNCTION     �#  CREATE FUNCTION public.create_message("inToken" character varying, "JSONparams" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Params json;
  Result json;
  CurrentUserID integer;
  Permissions integer;
  GroupPermissions integer;
  GroupMember json;
  PollItem character varying;
  CourseID integer;
  Title character varying;
  Message character varying;
  ParentMessageID integer;
  Type character varying;
  Settings character varying;
  GroupMembers json;
  --UserGroupID integer;
  PollType integer;
  PollItems json;
  UserGroupName character varying;
  MessageGroupName character varying;
  NextMessageID integer;
  NextMessageGroupID integer;
  NextUserGroupID integer;
  newUserGroupName character varying;
  newMessageGroupName character varying;
  ParentDepth integer;
  TempString character varying;
  TempID integer;
  TempPermission integer;
  TempType integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;  

  Params = "JSONparams"::json;
  IF Params->>'Title' IS NOT NULL THEN
    Title = Params->>'Title';
  ELSE
    RETURN ('{"ErrNo" : "16", "Description" : "Title field cannot be empty."}');
  END IF;
  
  Message = Params->>'Message';
  IF Params->>'Message' IS NOT NULL THEN
    Message = Params->>'Message';
  ELSE
    RETURN ('{"ErrNo" : "17", "Description" : "Message field cannot be empty."}');
  END IF;

  ParentMessageID = Params->>'ParentMessageID';
  GroupMembers = Params->'GroupMembers';
  Type = Params->>'Type';
  Settings = Params->>'Settings';

  IF Params->>'CourseID' IS NOT NULL THEN
    CourseID = to_number(Params->>'CourseID','999999999')::integer;
    -- check if course exists
    IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = CourseID) THEN
      RETURN ('{"ErrNo" : "1", "Description" : "The CourseID is not valid."}');
    END IF;

    Permissions = db_get_permission(CourseID,CurrentUserID);
    IF Permissions < 1  THEN
      RETURN ('{"ErrNo" : "3", "Description" : "This user is not a member of selected course."}');
    END IF;
  ELSE
    CourseID = NULL;
  END IF;

  IF Params->>'PollType' IS NOT NULL THEN
    PollType = to_number(Params->>'PollType','99999')::integer;
  ELSE
    PollType = NULL;
  END IF;

  IF Params->>'UserGroupID' IS NOT NULL THEN
    IF GroupMembers IS NOT NULL THEN
      RETURN ('{"ErrNo" : "18", "Description" : "A message cannot be a member of two UserGroups.  The NextUserGroupID and GroupMembers keys cannot be used simultaneously."}');
    END IF;
    NextUserGroupID = to_number(Params->>'UserGroupID','999999999')::integer;
    -- check if we have write permissions on the group
    GroupPermissions = db_get_group_permissions(NextUserGroupID,CurrentUserID);
    IF GroupPermissions = 0 THEN
      RETURN ('{"ErrNo" : "14", "Description" : "Either this group does not exist or this user is not a member."}');
    END IF;
    IF GroupPermissions = 3 THEN
      RETURN ('{"ErrNo" : "15", "Description" : "This user does not have write permission into this group."}');
    END IF;
  ELSIF GroupMembers IS NULL AND CourseID IS NULL THEN
      RETURN ('{"ErrNo" : "13", "Description" : "The CourseID, UserGroupID, and GroupMembers cannot all be Empty. A group of some type is required."}');
  ELSE
    NextUserGroupID = NULL;
  END IF;

  -- We are ready to test for group members and poll items if they exist.  However, we need to be able to recover
  -- in the event of an error. If I were just throwing standard errors, the procedure would roll back to the starting 
  -- point on an error automatically and we would not need to test first.  However, I create a json and do a return so 
  -- the procedure thinks it terminated successfully.  There may be a way around that, but I don't know it or have time
  -- to find it. So, we step through the groupmenbers and pollitems twice, first to test and make sure there are not 
  -- problems and then again to actually apply the changes.

  NextMessageID = nextval('"Messages_ID_seq"'::regclass);
  NextMessageGroupID = NULL; 
  -- check to see if all group member types are valid  
  IF GroupMembers IS NOT NULL THEN
    IF NextUserGroupID IS NOT NULL THEN
      RETURN ('{"ErrNo" : "12", "Description" : "You cannot use an existing UserGroupID when creating a new group message."}');
    END IF;
    NextUserGroupID = nextval('"Groups_ID_seq"'::regclass);
    NextMessageGroupID = nextval('"MessageGroupTypes_ID_seq"'::regclass);
    newUserGroupName = NextMessageID::text || 'MessageAttachedUsergroup';
    newMessageGroupName = NextMessageID::text || 'MessageAttachedMessagegroup';
    FOR GroupMember IN SELECT * FROM json_array_elements(GroupMembers)
    LOOP
      IF GroupMember->>'UserID' IS NULL THEN
        RETURN ('{"ErrNo" : "6", "Description" : "Each groupmember must have a UserID."}');
      END IF;     
      TempID = to_number(GroupMember->>'UserID','99999999999')::integer;
      --Uncomment the following to restrict to course members only
      --TempPermission = db_get_permission(CourseID,TempID);
      --IF TempPermission = 0 THEN
      --  TempString = GroupMember->>'UserID'::text;
      --  RETURN ('{"ErrNo" : "7", "Description" : "The UserID ' || TempString || ' is not in course or not valid."}');
      --END IF;  
      IF NOT EXISTS(SELECT 1 FROM "Users" WHERE "ID" = TempID) THEN
        TempString = GroupMember->>'UserID'::text;
        RETURN ('{"ErrNo" : "7", "Description" : "The UserID ' || TempString || ' does not exist."}');
      END IF;
      IF GroupMember->>'UserType' IS NULL THEN
        RETURN ('{"ErrNo" : "8", "Description" : "Each groupmember must have a UserType."}');
      END IF;  
      TempType = to_number(GroupMember->>'UserType','999999999')::integer;
      IF TempType < 1 OR TempType > 4 THEN
        TempString = GroupMember->>'UserType'::text;
        RETURN ('{"ErrNo" : "9", "Description" : "' || TempString || ' is an invalid UserType."}');
      END IF;
    END LOOP;
  END IF;

  IF PollType IS NOT NULL THEN
    IF PollType < 1 OR PollType > 4 THEN
      RETURN ('{"ErrNo" : "10", "Description" : "PollType must be a number between 1 and 4."}');
    END IF;

    PollItems = Params->'PollItems';
    -- check if all PollItems are valid.
    IF PollItems IS NULL THEN
      RETURN ('{"ErrNo" : "10", "Description" : "PollItems must exist if PollType does."}');
    END IF;
  END IF;

  -- check parent message id
  IF ParentMessageID IS NOT NULL THEN
    ParentDepth = db_increment_child_count(ParentMessageID,1);
    IF ParentDepth = 0 then
      RETURN ('{"ErrNo" : "3", "Description" : "Parent Message does not exist."}');
    END IF;    
  END IF;


  -- All tests passed, start actually writing everything to the database.
  INSERT INTO "Messages" ("ID","ParentID","CourseID","UserID","Type","TimeCreated","Title","Message","hasAttachment","ChildCount","DeletedBy","EditedBy","UserGroupID","LastEditedBy","PollType","Setting")
    VALUES (NextMessageID,ParentMessageID,CourseID,CurrentUserID,Type,NOW(),Title,Message,FALSE,0,NULL,NULL,NextUserGroupID, NULL,PollType,Settings);

  IF GroupMembers IS NOT NULL THEN
    -- Create the new usergroup
    -- visibility is set to 4 for message visibility
    INSERT INTO "UserGroups" ("ID","CourseID","GroupName","Visibility","MessageGroupID") 
      VALUES (NextUserGroupID,CourseID,newUserGroupName,4,NextMessageGroupID);

    -- insert the current user into the usergroup as admin
    INSERT INTO "UserGroupMembers" ("GroupID","UserID","UserType")
      VALUES (NextUserGroupID,CurrentUserID,1);  

    -- Create the new messagegroup
    INSERT INTO "MessageGroups" ("ID","CourseID","UserID","Name") VALUES 
          (NextMessageGroupID,CourseID,CurrentUserID,newMessageGroupName);

    -- Insert this message into messagegroup
    INSERT INTO "MessageGroupMembers" ("MessageGroupID","MessageID") VALUES (NextMessageGroupID,NextMessageID);


    -- Add GroupMembers to the GroupMembers table.
    GroupMembers = Params->'GroupMembers';
    FOR GroupMember IN SELECT * FROM json_array_elements(GroupMembers)
    LOOP
      TempID = to_number(GroupMember->>'UserID','999999999')::integer;
      TempType = to_number(GroupMember->>'UserType','999999999')::integer;
      IF TempID != CurrentUserID THEN
        INSERT INTO "UserGroupMembers" ("GroupID","UserID","UserType")
          VALUES (NextUserGroupID,TempID,TempType);    
      END IF;
    END LOOP;  
  END IF;

  IF PollType IS NOT NULL THEN
    RAISE NOTICE 'PollType is not null so inserting poll data';
    -- Add PollItems to the MessagePollItem table.
    PollItems = Params->'PollItems';
    FOR PollItem IN SELECT * FROM json_array_elements(PollItems)
    LOOP
      RAISE NOTICE 'Inserting poll item: %',PollItem;
      INSERT INTO "MessagePollItem" ("MessageID","Name") VALUES (NextMessageID,PollItem);
    END LOOP;
  END IF;

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;
$$;
 b   DROP FUNCTION public.create_message("inToken" character varying, "JSONparams" character varying);
       public       postgres    false    4    1            o	           0    0 T   FUNCTION create_message("inToken" character varying, "JSONparams" character varying)    ACL     w   GRANT ALL ON FUNCTION public.create_message("inToken" character varying, "JSONparams" character varying) TO oahu_user;
            public       postgres    false    348                       1255    20186 C   create_message_group(character varying, integer, character varying)    FUNCTION     |  CREATE FUNCTION public.create_message_group("inToken" character varying, "inCourseID" integer, "inGroupName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to do add students."}');
  END IF;

  IF "inGroupName" = '' OR "inGroupName" IS NULL THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Group Name cannot be empty."}');
  END IF;

  -- check if name already exists
  IF EXISTS (SELECT 1 FROM "MessageGroups" WHERE "CourseID" = "inCourseID" AND "Name" = "inGroupName") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "This groupname already exists."}');
  END IF;

  INSERT INTO "MessageGroups" ("CourseID","UserID","Name") VALUES ("inCourseID",CurrentUserID,"inGroupName");

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
    DROP FUNCTION public.create_message_group("inToken" character varying, "inCourseID" integer, "inGroupName" character varying);
       public       postgres    false    4    1            p	           0    0 q   FUNCTION create_message_group("inToken" character varying, "inCourseID" integer, "inGroupName" character varying)    ACL     �   GRANT ALL ON FUNCTION public.create_message_group("inToken" character varying, "inCourseID" integer, "inGroupName" character varying) TO oahu_user;
            public       postgres    false    274            ]           1255    20187 _   create_message_reply(character varying, integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.create_message_reply("inToken" character varying, "inParentMessageID" integer, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE 
  MessageParams jsonb;
BEGIN
  MessageParams = jsonb_build_object('CourseID',"inCourseID",'Title',"inTitle",'ParentMessageID',"inParentMessageID",'Message',"inMessage");

  RETURN create_message("inToken",MessageParams::text);
END;$$;
 �   DROP FUNCTION public.create_message_reply("inToken" character varying, "inParentMessageID" integer, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying);
       public       postgres    false    1    4            q	           0    0 �   FUNCTION create_message_reply("inToken" character varying, "inParentMessageID" integer, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying)    ACL     �   GRANT ALL ON FUNCTION public.create_message_reply("inToken" character varying, "inParentMessageID" integer, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying) TO oahu_user;
            public       postgres    false    349            ^           1255    20188 W   create_message_thread(character varying, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.create_message_thread("inToken" character varying, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageParams jsonb;
BEGIN
  MessageParams = jsonb_build_object('CourseID',"inCourseID",'Title',"inTitle",'Message',"inMessage");

  RETURN create_message("inToken",MessageParams::text);
END$$;
 �   DROP FUNCTION public.create_message_thread("inToken" character varying, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying);
       public       postgres    false    1    4            r	           0    0 �   FUNCTION create_message_thread("inToken" character varying, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying)    ACL     �   GRANT ALL ON FUNCTION public.create_message_thread("inToken" character varying, "inCourseID" integer, "inTitle" character varying, "inMessage" character varying) TO oahu_user;
            public       postgres    false    350                       1255    20189 I   create_user_group(character varying, integer, character varying, integer)    FUNCTION     p  CREATE FUNCTION public.create_user_group("inToken" character varying, "inClassID" integer, "inGroupName" character varying, "inVisibility" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  NextUserGroupID integer;
  FirstChar character;
  NextMessageGroupID integer;
  newMessageGroupName character varying;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inClassID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- check if first character is a number
  FirstChar = left("inGroupName",1);
  IF FirstChar >= '0' AND FirstChar <= '9' THEN
    RETURN ('{"ErrNo" : "2", "Description" : "The first character in a groupname cannot be a number."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;  
  Permissions = db_get_permission("inClassID",CurrentUserID);


  IF "inGroupName" = '' OR "inGroupName" IS NULL THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Group Name cannot be empty."}');
  END IF;

  -- check if inVisibility is a valid input
  IF "inVisibility" < 1 OR "inVisibility" > 3 OR "inVisibility" IS NULL THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Visibility Level is invalid."}');
  END IF;

  --Check if group name already exists in this class
  IF EXISTS (SELECT 1 FROM "UserGroups" WHERE "CourseID" = "inClassID" AND "GroupName" = "inGroupName") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Group Name is already in use in this class."}');
  END IF;  

  -- Only admins can create global visible groups
  IF "inVisibility" = 1 AND Permissions != 999 THEN
    RETURN ('{"ErrNo" : "6", "Description" : "Only admins can create global visible groups."}');
  END IF;

  IF "inVisibility" = 2 AND Permissions < 2 THEN
    RETURN ('{"ErrNo" : "7", "Description" : "Only admins, Instructors, and TAs can create course visible groups."}');
  END IF;

  -- Check if Students are allowed to create groups
  --SELECT get_setting_for_course('inst1','DB_SETTING_ALLOW_GROUP_CREATION',NULL) if setting is not course
  --SELECT get_setting_for_course('inst1','DB_SETTING_ALLOW_GROUP_CREATION',2) if setting is course
  

  -- User Types:
  -- 1 admin – can add and remove users, can read, write, and ?delete? messages
  -- 2 write – can only add messages to the usergroup but not read. You can always read your personal messages and direct replies to them but not the messages from other users.
  -- 3 read – can only read messages in the usergroup but not write
  -- 4 read_write – can both read and write to the usergroup

  -- Visibility levels:
  -- 1 global - all users can see the group
  -- 2 course - all members of the course can see the group
  -- 3 group - only members of the group can see the group.
  -- 4 message - group only applies to a specific message so don't list in group listings.

  -- Inputs are valid so insert
  NextUserGroupID = nextval('"Groups_ID_seq"'::regclass);
  -- create messagegroup
  NextMessageGroupID = nextval('"MessageGroupTypes_ID_seq"'::regclass);
  newMessageGroupName = to_char(NextUserGroupID,'99999999999') || 'MessageAttachedMessagegroup';
  INSERT INTO "MessageGroups" ("ID","CourseID","UserID","Name") VALUES (NextMessageGroupID,"inClassID",CurrentUserID,newMessageGroupName);

  -- create user group
  INSERT INTO "UserGroups" ("ID","CourseID","GroupName","Visibility","MessageGroupID") 
    VALUES (NextUserGroupID,"inClassID","inGroupName","inVisibility",NextMessageGroupID);
  -- add this user as the first admin.
  INSERT INTO "UserGroupMembers" ("GroupID","UserID","UserType")
    VALUES (NextUserGroupID,CurrentUserID,1);
  
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public.create_user_group("inToken" character varying, "inClassID" integer, "inGroupName" character varying, "inVisibility" integer);
       public       postgres    false    4    1            s	           0    0 �   FUNCTION create_user_group("inToken" character varying, "inClassID" integer, "inGroupName" character varying, "inVisibility" integer)    ACL     �   GRANT ALL ON FUNCTION public.create_user_group("inToken" character varying, "inClassID" integer, "inGroupName" character varying, "inVisibility" integer) TO oahu_user;
            public       postgres    false    275                       1255    20190 Y   create_usergroup_thread(character varying, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.create_usergroup_thread("inToken" character varying, "inUsergroupID" integer, "inTitle" character varying, "inMessage" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageParams jsonb;
  UserGroupRec record;
BEGIN
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inUserGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "100", "Description" : "Invalid UsergroupID."}');
  END IF;

  MessageParams = jsonb_build_object('CourseID',UserGroupRec."CourseID",'Title',"inTitle",'Message',"inMessage",'UserGroupID',"inUserGroupID"::text);

  RETURN create_message("inToken",MessageParams::text);
END;$$;
 �   DROP FUNCTION public.create_usergroup_thread("inToken" character varying, "inUsergroupID" integer, "inTitle" character varying, "inMessage" character varying);
       public       postgres    false    4    1            t	           0    0 �   FUNCTION create_usergroup_thread("inToken" character varying, "inUsergroupID" integer, "inTitle" character varying, "inMessage" character varying)    ACL     �   GRANT ALL ON FUNCTION public.create_usergroup_thread("inToken" character varying, "inUsergroupID" integer, "inTitle" character varying, "inMessage" character varying) TO oahu_user;
            public       postgres    false    276            u	           0    0    FUNCTION crypt(text, text)    ACL     =   GRANT ALL ON FUNCTION public.crypt(text, text) TO oahu_user;
            public       postgres    false    324                       1255    20191 '   db_add_user(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.db_add_user("inUserName" character varying, "inSchool" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$--  This function is insecure if anyone gets direct access to the database.
--  In a highly secure environment it might be copied and pasted into
--  db_admin_add_user() and all of the add_student..() and add_ta..() and a
--  dd_instructor..() functions all of which call this function.
DECLARE
  --UserData RECORD;
  newReadGroupID integer;
  newUserID integer;

BEGIN
  -- Ensure inLoginName is not empty
  IF "inUserName" = '' OR "inUserName" IS null THEN
    RETURN ('{"ErrNo" : "11", "Description" : "LoginName is a required field"}');
  END IF;

--  Check if login name already exists
--  SELECT "ID","LoginName","FirstLogin" INTO UserData FROM "Users" WHERE "LoginName" = "inUserName";
--  IF UserData IS NOT NULL THEN
  IF EXISTS (SELECT 1 FROM "Users" WHERE "LoginName" = "inUserName") THEN
    -- The name already exists so it can't be added.
    RETURN ('{"ErrNo" : "12", "Description" : "Username is already in the database."}');
  END IF;

  -- User does not exist create one

  -- Add the read message group first
  newReadGroupID = nextval('"MessageGroupTypes_ID_seq"'::regclass);
  newUserID = nextval('"User_ID_seq"'::regclass);
  INSERT INTO "MessageGroups" ("ID","UserID","Name")
    VALUES (newReadGroupID,newUserID,"inUserName"||' individual read group');

  -- Now add the user
  INSERT INTO "Users" ("ID","LoginName","FirstLogin","ReadGroupID","Active","IsAdmin","School")
    VALUES (newUserID,"inUserName", TRUE, newReadGroupID,TRUE,FALSE,"inSchool" );

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;
  $$;
 V   DROP FUNCTION public.db_add_user("inUserName" character varying, "inSchool" integer);
       public       postgres    false    1    4            v	           0    0 H   FUNCTION db_add_user("inUserName" character varying, "inSchool" integer)    ACL     k   GRANT ALL ON FUNCTION public.db_add_user("inUserName" character varying, "inSchool" integer) TO oahu_user;
            public       postgres    false    277                       1255    20192 !   db_add_userOld(character varying)    FUNCTION     �  CREATE FUNCTION public."db_add_userOld"("inUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$--  This function is insecure if anyone gets direct access to the database.
--  In a highly secure environment it might be copied and pasted into
--  db_admin_add_user() and all of the add_student..() and add_ta..() and a
--  dd_instructor..() functions all of which call this function.
DECLARE
  --UserData RECORD;
  newReadGroupID integer;
  newUserID integer;

BEGIN
  -- Ensure inLoginName is not empty
  IF "inUserName" = '' OR "inUserName" IS null THEN
    RETURN ('{"ErrNo" : "11", "Description" : "LoginName is a required field"}');
  END IF;

--  Check if login name already exists
--  SELECT "ID","LoginName","FirstLogin" INTO UserData FROM "Users" WHERE "LoginName" = "inUserName";
--  IF UserData IS NOT NULL THEN
  IF EXISTS (SELECT 1 FROM "Users" WHERE "LoginName" = "inUserName") THEN
    -- The name already exists so it can't be added.
    RETURN ('{"ErrNo" : "12", "Description" : "Username is already in the database."}');
  END IF;

  -- User does not exist create one

  -- Add the read message group first
  newReadGroupID = nextval('"MessageGroupTypes_ID_seq"'::regclass);
  newUserID = nextval('"User_ID_seq"'::regclass);
  INSERT INTO "MessageGroups" ("ID","UserID","Name")
    VALUES (newReadGroupID,newUserID,"inUserName"||' individual read group');

  -- Now add the user
  INSERT INTO "Users" ("ID","LoginName","FirstLogin","ReadGroupID","Active","IsAdmin")
    VALUES (newUserID,"inUserName", TRUE, newReadGroupID,TRUE,FALSE );

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;
  
$$;
 G   DROP FUNCTION public."db_add_userOld"("inUserName" character varying);
       public       postgres    false    4    1            w	           0    0 9   FUNCTION "db_add_userOld"("inUserName" character varying)    ACL     \   GRANT ALL ON FUNCTION public."db_add_userOld"("inUserName" character varying) TO oahu_user;
            public       postgres    false    278                       1255    20193 <   db_admin_activate_user(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.db_admin_activate_user("inToken" character varying, "inUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData record;
  CurrentUserID integer;

BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- check if admin user and password is valid
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "1", "Description" : "User must be admin to activate a user."}');
  END IF;


  IF NOT EXISTS (SELECT 1 FROM "Users" WHERE "LoginName" = "inUserName") THEN
    -- The name already exists so it can't be added.
    RETURN ('{"ErrNo" : "2", "Description" : "No such user."}');
  END IF;

  SELECT "ID","Active" INTO UserData FROM "Users" WHERE "LoginName" = "inUserName";

  IF UserData."Active" = TRUE THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User is already active."}');
  END IF;

  UPDATE "Users" SET "Active" = TRUE WHERE "ID" = UserData."ID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');  
END;$$;
 j   DROP FUNCTION public.db_admin_activate_user("inToken" character varying, "inUserName" character varying);
       public       postgres    false    1    4            x	           0    0 \   FUNCTION db_admin_activate_user("inToken" character varying, "inUserName" character varying)    ACL        GRANT ALL ON FUNCTION public.db_admin_activate_user("inToken" character varying, "inUserName" character varying) TO oahu_user;
            public       postgres    false    279                       1255    20194 8   db_admin_add_admin(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.db_admin_add_admin("inToken" character varying, "newAdminUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData record;
  CurrentUserID integer;

BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- check if current user is an admin
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "1", "Description" : "User must be admin to activate a user."}');
  END IF;

  -- check if new admin user exists
  SELECT "ID","Active" INTO UserData FROM "Users" WHERE "LoginName" = "newAdminUserName";
  IF UserData IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "No such user."}');
  END IF;

  -- things look good so add the new admin.
  UPDATE "Users" SET "IsAdmin" = TRUE WHERE "ID" = UserData."ID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');    

END;$$;
 l   DROP FUNCTION public.db_admin_add_admin("inToken" character varying, "newAdminUserName" character varying);
       public       postgres    false    1    4            y	           0    0 ^   FUNCTION db_admin_add_admin("inToken" character varying, "newAdminUserName" character varying)    ACL     �   GRANT ALL ON FUNCTION public.db_admin_add_admin("inToken" character varying, "newAdminUserName" character varying) TO oahu_user;
            public       postgres    false    280                       1255    20195 7   db_admin_add_user(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.db_admin_add_user("inToken" character varying, "inNewUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData record;
  CurrentUserID integer;
  ThisSchool integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- check if admin user and password is valid
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "2", "Description" : "User must be admin to add a user."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);

  RETURN db_add_user("inNewUserName",ThisSchool);
END;$$;
 h   DROP FUNCTION public.db_admin_add_user("inToken" character varying, "inNewUserName" character varying);
       public       postgres    false    1    4            z	           0    0 Z   FUNCTION db_admin_add_user("inToken" character varying, "inNewUserName" character varying)    ACL     }   GRANT ALL ON FUNCTION public.db_admin_add_user("inToken" character varying, "inNewUserName" character varying) TO oahu_user;
            public       postgres    false    281                       1255    20196 n   db_admin_create_course(character varying, character varying, character varying, character varying, date, date)    FUNCTION     �  CREATE FUNCTION public.db_admin_create_course("inToken" character varying, "inClassNumber" character varying, "inClassName" character varying, "inSetupKey" character varying, "inStartDate" date, "inEndDate" date) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
   newIndex integer;
   CurrentUserID integer;
   ThisSchool integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- check if admin user and password is valid
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "2", "Description" : "User must be admin to activate a user."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);

  -- Validate inputs
  IF "inStartDate" > "inEndDate" THEN
    RETURN ('{"ErrNo" : "3", "Description" : "EndDate cannot be less than start date."}');
  END IF;

  -- check for duplicate setup key
  IF EXISTS (SELECT 1 FROM "Courses" WHERE "SetupKey" = "inSetupKey") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Duplicate Setup Key. A specific key can only be used for one course."}');
  END IF;
   
  -- Create the course
  INSERT INTO "Courses" ("Number", "Name", "StartDate", "EndDate", "SetupKey","School") 
     VALUES("inClassNumber","inClassName","inStartDate","inEndDate","inSetupKey",ThisSchool);
     
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$$;
 �   DROP FUNCTION public.db_admin_create_course("inToken" character varying, "inClassNumber" character varying, "inClassName" character varying, "inSetupKey" character varying, "inStartDate" date, "inEndDate" date);
       public       postgres    false    4    1            {	           0    0 �   FUNCTION db_admin_create_course("inToken" character varying, "inClassNumber" character varying, "inClassName" character varying, "inSetupKey" character varying, "inStartDate" date, "inEndDate" date)    ACL     �   GRANT ALL ON FUNCTION public.db_admin_create_course("inToken" character varying, "inClassNumber" character varying, "inClassName" character varying, "inSetupKey" character varying, "inStartDate" date, "inEndDate" date) TO oahu_user;
            public       postgres    false    282                       1255    20197 >   db_admin_deactivate_user(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.db_admin_deactivate_user("inToken" character varying, "inActiveUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData record;
  CurrentUserID integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- check if admin user and password is valid
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "1", "Description" : "User must be admin to activate a user."}');
  END IF;

  -- check if user exists
  IF NOT EXISTS (SELECT 1 FROM "Users" WHERE "LoginName" = "inActiveUserName") THEN
    RETURN ('{"ErrNo" : "2", "Description" : "No such user."}');
  END IF;

  SELECT "ID","Active" INTO UserData FROM "Users" WHERE "LoginName" = "inActiveUserName";

  IF UserData."Active" = FALSE THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User is already inactive."}');
  END IF;

  UPDATE "Users" SET "Active" = FALSE WHERE "ID" = UserData."ID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');  
END;$$;
 r   DROP FUNCTION public.db_admin_deactivate_user("inToken" character varying, "inActiveUserName" character varying);
       public       postgres    false    1    4            |	           0    0 d   FUNCTION db_admin_deactivate_user("inToken" character varying, "inActiveUserName" character varying)    ACL     �   GRANT ALL ON FUNCTION public.db_admin_deactivate_user("inToken" character varying, "inActiveUserName" character varying) TO oahu_user;
            public       postgres    false    283            ?           1255    20198 ;   db_admin_delete_admin(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.db_admin_delete_admin("inToken" character varying, "deleteAdminUserName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData record;
  CurrentUserID integer;

BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  -- check if current user is an admin
  IF NOT db_is_admin(CurrentUserID) THEN
    RETURN ('{"ErrNo" : "1", "Description" : "User must be admin to activate a user."}');
  END IF;

  -- check if new admin user exists
  SELECT "ID","Active" INTO UserData FROM "Users" WHERE "LoginName" = "deleteAdminUserName";
  IF UserData IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "No such user."}');
  END IF;

  -- things look good so remove the admin.
  UPDATE "Users" SET "IsAdmin" = FALSE WHERE "ID" = UserData."ID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');    

END;$$;
 r   DROP FUNCTION public.db_admin_delete_admin("inToken" character varying, "deleteAdminUserName" character varying);
       public       postgres    false    4    1            }	           0    0 d   FUNCTION db_admin_delete_admin("inToken" character varying, "deleteAdminUserName" character varying)    ACL     �   GRANT ALL ON FUNCTION public.db_admin_delete_admin("inToken" character varying, "deleteAdminUserName" character varying) TO oahu_user;
            public       postgres    false    319            �            1255    20199 !   db_decrement_child_count(integer)    FUNCTION       CREATE FUNCTION public.db_decrement_child_count("inParentMessageID" integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
  ParentRec record;
BEGIN
  SELECT * INTO ParentRec FROM "Messages" WHERE "ID" = "inParentMessageID";
  IF NOT FOUND THEN
    RETURN;
  END IF; 
    
  UPDATE "Messages" SET "ChildCount" = ParentRec."ChildCount" - 1 WHERE "ID" = "inParentMessageID";
  IF ParentRec."ParentID" IS NOT NULL THEN
    PERFORM db_decrement_child_count(ParentRec."ParentID");
  END IF;

END;$$;
 L   DROP FUNCTION public.db_decrement_child_count("inParentMessageID" integer);
       public       postgres    false    4    1            ~	           0    0 >   FUNCTION db_decrement_child_count("inParentMessageID" integer)    ACL     a   GRANT ALL ON FUNCTION public.db_decrement_child_count("inParentMessageID" integer) TO oahu_user;
            public       postgres    false    251            �            1255    20200    db_get_all_messages()    FUNCTION     �  CREATE FUNCTION public.db_get_all_messages() RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result json;
BEGIN
  SELECT array_to_json(array_agg(row_to_json(r))) INTO Result FROM
(SELECT "ID","ParentID","CourseID","UserID","Type","TimeCreated","Title","Message","hasAttachment","ChildCount",
      db_get_user_readgroup_id("UserID") AS ReadGroupID,
      db_message_is_read(db_get_user_readgroup_id("UserID"),"ID") AS isRead
  FROM "Messages") r; 
  RETURN Result;
END;$$;
 ,   DROP FUNCTION public.db_get_all_messages();
       public       postgres    false    1    4            	           0    0    FUNCTION db_get_all_messages()    ACL     A   GRANT ALL ON FUNCTION public.db_get_all_messages() TO oahu_user;
            public       postgres    false    252            �            1255    20201 &   db_get_all_messages(character varying)    FUNCTION     �  CREATE FUNCTION public.db_get_all_messages("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;  
  Result json;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;   

  SELECT array_to_json(array_agg(row_to_json(r))) INTO Result FROM
(SELECT "ID","ParentID","CourseID","UserID","Type","TimeCreated","Title","Message","hasAttachment","ChildCount",
      db_message_is_read(CurrentUserID,"ID") AS isRead,"DeletedBy","EditedBy","UserGroupID","LastEditedBy"
  FROM "Messages") r; 
  RETURN Result;
END;$$;
 G   DROP FUNCTION public.db_get_all_messages("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 9   FUNCTION db_get_all_messages("inToken" character varying)    ACL     \   GRANT ALL ON FUNCTION public.db_get_all_messages("inToken" character varying) TO oahu_user;
            public       postgres    false    253            @           1255    20202    db_get_err_no(json)    FUNCTION     �   CREATE FUNCTION public.db_get_err_no("inJsonError" json) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  Result integer;
BEGIN
  SELECT value::int INTO Result FROM json_each_text("inJsonError") WHERE key='ErrNo';  
  RETURN Result;
END;
$$;
 8   DROP FUNCTION public.db_get_err_no("inJsonError" json);
       public       postgres    false    1    4            �	           0    0 *   FUNCTION db_get_err_no("inJsonError" json)    ACL     M   GRANT ALL ON FUNCTION public.db_get_err_no("inJsonError" json) TO oahu_user;
            public       postgres    false    320            U           1255    20203 *   db_get_group_permissions(integer, integer)    FUNCTION     �  CREATE FUNCTION public.db_get_group_permissions("inGroupID" integer, "inUserID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$-- Function returns the specific permission of a user in the group
-- 0 This user is not a member of this group
-- 1 admin – can add and remove users, can read, write, and ?delete? messages
-- 2 write – can only add messages to the usergroup but not read. You can always read your personal messages and direct replies to them but not the messages from other users.
-- 3 read – can only read messages in the usergroup but not write
-- 4 read_write – can both read and write to the usergroup

DECLARE
   PermissionType integer;
BEGIN

   SELECT "UserType" INTO PermissionType FROM "UserGroupMembers" WHERE "GroupID" = "inGroupID" AND "UserID" = "inUserID";
   IF NOT FOUND THEN
      -- The user is not a member of this group
      RETURN 0;
   ELSE
      RETURN PermissionType;
   END IF;
END;
$$;
 X   DROP FUNCTION public.db_get_group_permissions("inGroupID" integer, "inUserID" integer);
       public       postgres    false    4    1            �	           0    0 J   FUNCTION db_get_group_permissions("inGroupID" integer, "inUserID" integer)    ACL     m   GRANT ALL ON FUNCTION public.db_get_group_permissions("inGroupID" integer, "inUserID" integer) TO oahu_user;
            public       postgres    false    341            V           1255    20204    db_get_max_permission(integer)    FUNCTION     :  CREATE FUNCTION public.db_get_max_permission("inUserID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  Result integer;
BEGIN
  SELECT MAX("UserType") INTO Result FROM "CourseMembers" WHERE "UserID" = "inUserID";
  IF Result IS NULL THEN
    Result = 0;
  END IF;
  RETURN Result;
END;$$;
 @   DROP FUNCTION public.db_get_max_permission("inUserID" integer);
       public       postgres    false    1    4            �	           0    0 2   FUNCTION db_get_max_permission("inUserID" integer)    ACL     U   GRANT ALL ON FUNCTION public.db_get_max_permission("inUserID" integer) TO oahu_user;
            public       postgres    false    342            W           1255    20205 *   db_get_message_group_id(character varying)    FUNCTION     	  CREATE FUNCTION public.db_get_message_group_id("inGroupName" character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  result integer;
BEGIN
  SELECT "ID" INTO result FROM "MessageGroups" WHERE "Name" = "inGroupName";
  RETURN result;
END;$$;
 O   DROP FUNCTION public.db_get_message_group_id("inGroupName" character varying);
       public       postgres    false    4    1            �	           0    0 A   FUNCTION db_get_message_group_id("inGroupName" character varying)    ACL     d   GRANT ALL ON FUNCTION public.db_get_message_group_id("inGroupName" character varying) TO oahu_user;
            public       postgres    false    343            _           1255    20206 )   db_get_message_poll_id(character varying)    FUNCTION     
  CREATE FUNCTION public.db_get_message_poll_id("inMessageTitle" character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  result integer;
BEGIN
  SELECT "ID" INTO result FROM "Messages" WHERE "Title" = "inMessageTitle";
  RETURN result;
END;$$;
 Q   DROP FUNCTION public.db_get_message_poll_id("inMessageTitle" character varying);
       public       postgres    false    1    4            �	           0    0 C   FUNCTION db_get_message_poll_id("inMessageTitle" character varying)    ACL     f   GRANT ALL ON FUNCTION public.db_get_message_poll_id("inMessageTitle" character varying) TO oahu_user;
            public       postgres    false    351            a           1255    20207    db_get_message_score(integer)    FUNCTION     "  CREATE FUNCTION public.db_get_message_score("inMessageID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  Result integer;

BEGIN
  SELECT SUM("Score") INTO Result
    FROM "MessageVotes"
    WHERE "MessageVotes"."MessageID" = "inMessageID";
  RETURN Result;
END$$;
 B   DROP FUNCTION public.db_get_message_score("inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 4   FUNCTION db_get_message_score("inMessageID" integer)    ACL     W   GRANT ALL ON FUNCTION public.db_get_message_score("inMessageID" integer) TO oahu_user;
            public       postgres    false    353            b           1255    20208    db_get_parent_group(integer)    FUNCTION     �  CREATE FUNCTION public.db_get_parent_group("inMessageID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageRec record;
BEGIN
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN NULL;
  END IF;
  IF MessageRec."ParentID" IS NULL THEN
    RETURN MessageRec."UserGroupID";
  ELSE
    RETURN db_get_parent_group(MessageRec."ParentID");
  END IF;
END;$$;
 A   DROP FUNCTION public.db_get_parent_group("inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 3   FUNCTION db_get_parent_group("inMessageID" integer)    ACL     V   GRANT ALL ON FUNCTION public.db_get_parent_group("inMessageID" integer) TO oahu_user;
            public       postgres    false    354            d           1255    20209 #   db_get_permission(integer, integer)    FUNCTION     ?  CREATE FUNCTION public.db_get_permission("inClassID" integer, "inUserID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

-- Function returns the specific permission of a user in the course
-- 0 the user is not in the course
-- 1 the user is a student
-- 2 the user is a TA
-- 3 the user is the instructor
-- 999 the user is an administrator

DECLARE
   PermissionType integer;
   UserIsAdmin boolean;
BEGIN
   UserIsAdmin = db_is_admin("inUserID");

   IF UserIsAdmin THEN
      return 999;
   END IF;

   SELECT "UserType" INTO PermissionType FROM "CourseMembers" WHERE "CourseID" = "inClassID" AND "UserID" = "inUserID";
   IF PermissionType IS NULL THEN
      -- The user does not have permission to be in this class
      RETURN 0;
   ELSE
      RETURN PermissionType;
   END IF;
END;

$$;
 Q   DROP FUNCTION public.db_get_permission("inClassID" integer, "inUserID" integer);
       public       postgres    false    1    4            �	           0    0 C   FUNCTION db_get_permission("inClassID" integer, "inUserID" integer)    ACL     f   GRANT ALL ON FUNCTION public.db_get_permission("inClassID" integer, "inUserID" integer) TO oahu_user;
            public       postgres    false    356            e           1255    20210    db_get_school(integer)    FUNCTION     @  CREATE FUNCTION public.db_get_school("inUserID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ DECLARE
   UserData RECORD;
BEGIN
  SELECT * INTO UserData FROM "Users" WHERE "ID" = "inUserID";
   IF UserData IS NOT NULL THEN
      RETURN UserData."School";
   ELSE
      RETURN NULL;
   END IF;
END;$$;
 8   DROP FUNCTION public.db_get_school("inUserID" integer);
       public       postgres    false    4    1            �	           0    0 *   FUNCTION db_get_school("inUserID" integer)    ACL     M   GRANT ALL ON FUNCTION public.db_get_school("inUserID" integer) TO oahu_user;
            public       postgres    false    357            f           1255    20211 *   db_get_user_id(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.db_get_user_id("inUserName" character varying, "inSchool" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
   UserData RECORD;

BEGIN
   SELECT "ID","LoginName" INTO UserData FROM "Users" WHERE "LoginName" = "inUserName" AND "School" = "inSchool";
   IF UserData IS NOT NULL THEN
      RETURN UserData."ID";
   ELSE
      RETURN NULL;
   END IF;
END$$;
 Y   DROP FUNCTION public.db_get_user_id("inUserName" character varying, "inSchool" integer);
       public       postgres    false    4    1            �	           0    0 K   FUNCTION db_get_user_id("inUserName" character varying, "inSchool" integer)    ACL     n   GRANT ALL ON FUNCTION public.db_get_user_id("inUserName" character varying, "inSchool" integer) TO oahu_user;
            public       postgres    false    358            g           1255    20212 $   db_get_user_idOld(character varying)    FUNCTION     _  CREATE FUNCTION public."db_get_user_idOld"(username character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
   UserData RECORD;
BEGIN
   SELECT "ID","LoginName" INTO UserData FROM "Users" WHERE "LoginName" = "username";
   IF UserData IS NOT NULL THEN
      RETURN UserData."ID";
   ELSE
      RETURN NULL;
   END IF;
END$$;
 F   DROP FUNCTION public."db_get_user_idOld"(username character varying);
       public       postgres    false    4    1            �	           0    0 8   FUNCTION "db_get_user_idOld"(username character varying)    ACL     [   GRANT ALL ON FUNCTION public."db_get_user_idOld"(username character varying) TO oahu_user;
            public       postgres    false    359            h           1255    20213 .   db_get_user_id_from_session(character varying)    FUNCTION       CREATE FUNCTION public.db_get_user_id_from_session("inToken" character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
   UserData RECORD;
BEGIN
   --RAISE NOTICE 'starting db_get_user_id_from_session';
   SELECT * INTO UserData FROM "Sessions" WHERE "Ticket" = "inToken";
   --RAISE NOTICE 'UserDat=%',UserData;
   IF FOUND THEN
      --RAISE NOTICE 'UserData."UserID" IS NOT NULL';
      RETURN UserData."UserID";
   ELSE
      --RAISE NOTICE 'UserData."UserID" IS NULL';
      RETURN NULL;
   END IF;
END$$;
 O   DROP FUNCTION public.db_get_user_id_from_session("inToken" character varying);
       public       postgres    false    4    1            �	           0    0 A   FUNCTION db_get_user_id_from_session("inToken" character varying)    ACL     d   GRANT ALL ON FUNCTION public.db_get_user_id_from_session("inToken" character varying) TO oahu_user;
            public       postgres    false    360            k           1255    20214    db_get_user_login_name(integer)    FUNCTION     e  CREATE FUNCTION public.db_get_user_login_name("inUserID" integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$DECLARE
   UserData RECORD;
BEGIN
   SELECT "ID","LoginName" INTO UserData FROM "Users" WHERE "ID" = "inUserID";
   IF UserData IS NOT NULL THEN
      RETURN UserData."LoginName";
   ELSE
      RETURN NULL;
   END IF;
END;$$;
 A   DROP FUNCTION public.db_get_user_login_name("inUserID" integer);
       public       postgres    false    1    4            �	           0    0 3   FUNCTION db_get_user_login_name("inUserID" integer)    ACL     V   GRANT ALL ON FUNCTION public.db_get_user_login_name("inUserID" integer) TO oahu_user;
            public       postgres    false    363            `           1255    20215 !   db_get_user_readgroup_id(integer)    FUNCTION       CREATE FUNCTION public.db_get_user_readgroup_id("inUserID" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  thisReadgroupID integer;

BEGIN
  SELECT "ReadGroupID" INTO thisReadgroupID FROM "Users" WHERE "ID" = "inUserID";
  RETURN thisReadgroupID;
END;
$$;
 C   DROP FUNCTION public.db_get_user_readgroup_id("inUserID" integer);
       public       postgres    false    4    1            �	           0    0 5   FUNCTION db_get_user_readgroup_id("inUserID" integer)    ACL     X   GRANT ALL ON FUNCTION public.db_get_user_readgroup_id("inUserID" integer) TO oahu_user;
            public       postgres    false    352            m           1255    20216    db_get_user_type(integer)    FUNCTION     j  CREATE FUNCTION public.db_get_user_type("inType" integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$BEGIN
  IF "inType" = 999 THEN
    RETURN 'Admin';
  ELSEIF "inType" = 3 THEN
    RETURN 'Instructor';
  ELSIF "inType" = 2 THEN
    RETURN 'TA';
  ELSIF "inType" = 1 THEN
    RETURN 'Student';
  ELSE
    RETURN 'N/A';
  END IF;
END$$;
 9   DROP FUNCTION public.db_get_user_type("inType" integer);
       public       postgres    false    1    4            �	           0    0 +   FUNCTION db_get_user_type("inType" integer)    ACL     N   GRANT ALL ON FUNCTION public.db_get_user_type("inType" integer) TO oahu_user;
            public       postgres    false    365            n           1255    20217 *   db_increment_child_count(integer, integer)    FUNCTION     �  CREATE FUNCTION public.db_increment_child_count("inParentMessageID" integer, "inDepth" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  ParentRec record;
BEGIN
  RAISE NOTICE 'Child Count:%',"inDepth";
  SELECT * INTO ParentRec FROM "Messages" WHERE "ID" = "inParentMessageID";
  RAISE NOTICE 'ParentRec:%',ParentRec;
  IF NOT FOUND THEN
    RETURN 0;
  END IF; 
    
  UPDATE "Messages" SET "ChildCount" = ParentRec."ChildCount" + 1 WHERE "ID" = "inParentMessageID";
  IF ParentRec."ParentID" IS NULL THEN
    RAISE NOTICE 'Returning: %',"inDepth";
    RETURN "inDepth";
  ELSE
    RETURN db_increment_child_count(ParentRec."ParentID","inDepth" + 1);
  END IF;

END;$$;
 _   DROP FUNCTION public.db_increment_child_count("inParentMessageID" integer, "inDepth" integer);
       public       postgres    false    4    1            �	           0    0 Q   FUNCTION db_increment_child_count("inParentMessageID" integer, "inDepth" integer)    ACL     t   GRANT ALL ON FUNCTION public.db_increment_child_count("inParentMessageID" integer, "inDepth" integer) TO oahu_user;
            public       postgres    false    366            �            1255    20218 a   db_init_user(character varying, character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.db_init_user("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inSchool" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData RECORD;
  thisUserID integer;
  AddUserRetVal json;
  FirstUser boolean;
  userIDcurrval integer;
BEGIN

  FirstUser = FALSE;
  SELECT * INTO UserData FROM "Users" WHERE "LoginName" = "inLoginName";
  IF FOUND THEN
    -- Database already includes user
    IF UserData."FirstLogin" = FALSE THEN
      RETURN ('{"ErrNo" : "6", "Description" : "User is already initialized."}');
    END IF;
    thisUserID = UserData."ID";
  ELSE
    -- Database does not include user so add him or her first.
    -- check if the is the first and only user
    userIDcurrval = nextval('"User_ID_seq"'::regclass);
    IF userIDcurrval = 2 THEN
      FirstUser = TRUE;
    END IF;
    AddUserRetVal = db_add_user("inLoginName","inSchool");
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      thisUserID = db_get_user_id("inLoginName","inSchool");
    END IF;
  END IF;

  -- User should exist at this point so update information
  UPDATE "Users" SET "FirstName" = "inFirstName","LastName" = "inLastName", 
    "EmailAddr" = "inEmail", "FirstLogin" = FALSE, "IsAdmin" = FirstUser WHERE "ID" = thisUserID;
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public.db_init_user("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inSchool" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION db_init_user("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inSchool" integer)    ACL     �   GRANT ALL ON FUNCTION public.db_init_user("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inSchool" integer) TO oahu_user;
            public       postgres    false    250            o           1255    20219 [   db_init_userOld(character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public."db_init_userOld"("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  UserData RECORD;
  thisUserID integer;
  AddUserRetVal json;
  FirstUser boolean;
  userIDcurrval integer;
BEGIN

  FirstUser = FALSE;
  SELECT * INTO UserData FROM "Users" WHERE "LoginName" = "inLoginName";
  IF FOUND THEN
    -- Database already includes user
    IF UserData."FirstLogin" = FALSE THEN
      RETURN ('{"ErrNo" : "6", "Description" : "User is already initialized."}');
    END IF;
    thisUserID = UserData."ID";
  ELSE
    -- Database does not include user so add him or her first.
    -- check if the is the first and only user
    userIDcurrval = nextval('"User_ID_seq"'::regclass);
    IF userIDcurrval = 2 THEN
      FirstUser = TRUE;
    END IF;
    AddUserRetVal = db_add_user("inLoginName");
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      thisUserID = db_get_user_id("inLoginName");
    END IF;
  END IF;

  -- User should exist at this point so update information
  UPDATE "Users" SET "FirstName" = "inFirstName","LastName" = "inLastName", 
    "EmailAddr" = "inEmailAddr", "FirstLogin" = FALSE, "IsAdmin" = FirstUser WHERE "ID" = thisUserID;
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public."db_init_userOld"("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION "db_init_userOld"("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying)    ACL     �   GRANT ALL ON FUNCTION public."db_init_userOld"("inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying) TO oahu_user;
            public       postgres    false    367                       1255    20220    db_is_admin(integer)    FUNCTION     �  CREATE FUNCTION public.db_is_admin("inUserID" integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
  UserIsAdmin boolean;
  EveryoneIsAdmin character varying;
BEGIN
  SELECT "Value" INTO EveryoneIsAdmin FROM "Settings" WHERE "Name" = 'EveryoneIsAdmin';
  IF EveryoneIsAdmin = 'TRUE' THEN
    RETURN TRUE;
  END IF;

  SELECT "IsAdmin" INTO UserIsAdmin FROM "Users" WHERE "ID" = "inUserID";
  RETURN UserIsAdmin;
END;$$;
 6   DROP FUNCTION public.db_is_admin("inUserID" integer);
       public       postgres    false    1    4            �	           0    0 (   FUNCTION db_is_admin("inUserID" integer)    ACL     K   GRANT ALL ON FUNCTION public.db_is_admin("inUserID" integer) TO oahu_user;
            public       postgres    false    284            p           1255    20221     db_is_message_usergroup(integer)    FUNCTION     �  CREATE FUNCTION public.db_is_message_usergroup("inUsergroupID" integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
  GroupRec record;
BEGIN
  SELECT * INTO GroupRec FROM "UserGroups" WHERE "ID" = "inUsergroupID";
  IF FOUND THEN
    IF GroupRec."Visibility" = 4 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;
  RETURN FALSE; -- Group is not found
END;$$;
 G   DROP FUNCTION public.db_is_message_usergroup("inUsergroupID" integer);
       public       postgres    false    4    1            �	           0    0 9   FUNCTION db_is_message_usergroup("inUsergroupID" integer)    ACL     \   GRANT ALL ON FUNCTION public.db_is_message_usergroup("inUsergroupID" integer) TO oahu_user;
            public       postgres    false    368            �            1255    20222 7   db_login(character varying, character varying, integer)    FUNCTION     t  CREATE FUNCTION public.db_login("inToken" character varying, "inLoginName" character varying, "inSchool" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserData RECORD;
  SessionData RECORD;
  AddUserRetVal jsonb;
BEGIN
  RAISE NOTICE 'inLoginName:%',"inLoginName";
  SELECT * INTO UserData FROM "Users" WHERE "LoginName" = "inLoginName" AND "School" = "inSchool";

  --IF UserData IS NULL THEN
  IF NOT FOUND THEN
    -- This user does not exist, so it needs to be initialized first.
    RETURN ('{"ErrNo" : "11", "Description" : "User does not exist."}');
  END IF;

  RAISE NOTICE 'UserData:%',UserData;
  IF UserData."FirstLogin" = TRUE THEN
    RETURN ('{"ErrNo" : "12", "Description" : "User is not initialized."}');
  END IF;

  IF UserData."Active" = FALSE THEN
    RETURN ('{"ErrNo" : "13", "Description" : "User is not active."}');
  END IF;

  SELECT * INTO SessionData FROM "Sessions" WHERE "UserLoginName" = "inLoginName";
  --IF SessionData IS NULL THEN
  IF NOT FOUND THEN
    -- This session key has not been used before
    -- and the user is active and initialized so create a new session
    INSERT INTO "Sessions" ("Ticket","UserLoginName","StartTime","LastUpdate","UserID")
       VALUES ("inToken","inLoginName",NOW(),NOW(),UserData."ID");
  ELSE 
    -- Session key exists
    -- check if user matches.
    IF SessionData."UserID" != UserData."ID" THEN
      RETURN ('{"ErrNo" : "14", "Description" : "Session Error: Username does not match"}');
    END IF;

    -- login is good so just update
    UPDATE "Sessions" SET "LastUpdate" = NOW(), "Ticket" = "inToken" WHERE "UserLoginName" = "inLoginName";

  END IF;
  -- No errors were encountered.
  AddUserRetVal = jsonb_build_object('ErrNo','0','Description','Success','LoginName',"inLoginName",'SessionKey',"inToken",'userId',UserData."ID");
  RETURN AddUserRetVal;
END;$$;
 q   DROP FUNCTION public.db_login("inToken" character varying, "inLoginName" character varying, "inSchool" integer);
       public       postgres    false    4    1            �	           0    0 c   FUNCTION db_login("inToken" character varying, "inLoginName" character varying, "inSchool" integer)    ACL     �   GRANT ALL ON FUNCTION public.db_login("inToken" character varying, "inLoginName" character varying, "inSchool" integer) TO oahu_user;
            public       postgres    false    245            c           1255    20223 $   db_message_is_read(integer, integer)    FUNCTION     O  CREATE FUNCTION public.db_message_is_read("inReadGroupID" integer, "inMessageID" integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
  IF EXISTS (SELECT 1 FROM "MessageGroupMembers" WHERE "MessageGroupID" = "inReadGroupID" AND "MessageID" = "inMessageID") THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END$$;
 Y   DROP FUNCTION public.db_message_is_read("inReadGroupID" integer, "inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 K   FUNCTION db_message_is_read("inReadGroupID" integer, "inMessageID" integer)    ACL     n   GRANT ALL ON FUNCTION public.db_message_is_read("inReadGroupID" integer, "inMessageID" integer) TO oahu_user;
            public       postgres    false    355                       1255    20224 %   db_null_int_compare(integer, integer)    FUNCTION     $  CREATE FUNCTION public.db_null_int_compare(int1 integer, int2 integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
  IF int1 IS NULL THEN
    IF int2 IS NULL THEN
      -- Both are null - same
      RETURN TRUE;
    ELSE
      -- int1 is null but int2 is not - different
      RETURN FALSE;
    END IF;
  ELSE
    IF int2 IS NULL THEN
      -- int1 is not null and int2 is null - different
      RETURN FALSE;
    ELSE
      -- int1 is not null and int2 is not null
      RETURN int1 = int2;
    END IF;
  END IF;
END;$$;
 F   DROP FUNCTION public.db_null_int_compare(int1 integer, int2 integer);
       public       postgres    false    4    1            �	           0    0 8   FUNCTION db_null_int_compare(int1 integer, int2 integer)    ACL     [   GRANT ALL ON FUNCTION public.db_null_int_compare(int1 integer, int2 integer) TO oahu_user;
            public       postgres    false    285                       1255    20225 r   db_set_global_setting(character varying, character varying, character varying, integer, integer, integer, integer)    FUNCTION     r  CREATE FUNCTION public.db_set_global_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer, "inSchool" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$-- This function is db because a client should not be directly setting a school other than login time
-- use set_system_default_setting() or set_school_default_setting() instead.

DECLARE
--  SettingTypeID integer;
  SettingRec record;
  CurrentUserID integer;
  --Permissions integer;
  --newPermission integer;
  --newVisibility integer;
BEGIN
  IF "inToken" IS NOT NULL THEN
    -- Validate admin user
    -- Check Token
    CurrentUserID = db_get_user_id_from_session("inToken");
    IF CurrentUserID IS NULL THEN
      RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
    END IF;

    --Permissions = db_get_permission("inCourseID",CurrentUserID);
    IF NOT db_is_admin(CurrentUserID) THEN
      RETURN ('{"ErrNo" : "2", "Description" : "Only an admin can alter system settings."}');
    END IF;
  END IF;

  -- Check if setting name is empty
  IF "inSettingName" = '' OR "inSettingName" IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "Setting Name cannot be an empty field."}');
  END IF;

  -- check if setting value is empty
  IF "inSettingValue" = '' OR "inSettingValue" IS NULL THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Setting Value cannot be an empty field."}');
  END IF;

  -- check if inPermission is valid
  --newPermission = to_number("inPermission",9999999);  
  IF NOT ("inPermission" = 999 OR ("inPermission">=1 AND "inPermission" <=3) ) THEN
    RETURN ('{"ErrNo" : "5", "Description" : "New permission is not valid."}');
  END IF;

  -- check if inVisibility is valid
  --newVisibility = to_number("inVisibility",9999999);  
  IF NOT ("inVisibility" = 999 OR ("inVisibility">=1 AND "inVisibility" <=3) ) THEN
    RETURN ('{"ErrNo" : "6", "Description" : "New visibility is not valid."}');
  END IF;

  -- Make sure visibility is <= permission
  IF "inVisibility" > "inPermission" THEN
    RETURN ('{"ErrNo" : "7", "Description" : "Cannot set visibility requirements higher than permission."}');
  END IF;  

  -- Check if setting exists
  IF NOT EXISTS (SELECT 1 FROM "Settings" WHERE "Name" = "inSettingName" AND "Rank" = 0 
                   AND db_null_int_compare("School","inSchool")) THEN
    -- It does not currently exist so create a new one
    RAISE NOTICE 'Inserting %, Value %, inSchool %',"inSettingName","inSettingValue","inSchool";
    INSERT INTO "Settings" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type","School")
      VALUES (0,null,null,"inSettingName","inSettingValue","inPermission","inVisibility","inType","inSchool");
  ELSE
    -- This setting already exists.
    RAISE NOTICE 'Updating %, Value %, inSchool %',"inSettingName","inSettingValue","inSchool";
    UPDATE "Settings" SET "Value" = "inSettingValue","Permission" = "inPermission", "Visibility" = "inVisibility"
      WHERE "Name" = "inSettingName" AND "Rank" = 0 AND db_null_int_compare("School","inSchool") ;
  END IF;


  --UPDATE "Settings" SET "Visibility" = "inVisibility", "Permission" = "inPermission" WHERE "Name" = "inSettingName" AND "Rank" > 0;

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.db_set_global_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer, "inSchool" integer);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION db_set_global_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer, "inSchool" integer)    ACL     �   GRANT ALL ON FUNCTION public.db_set_global_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer, "inSchool" integer) TO oahu_user;
            public       postgres    false    286            �	           0    0    FUNCTION dearmor(text)    ACL     9   GRANT ALL ON FUNCTION public.dearmor(text) TO oahu_user;
            public       postgres    false    338            �	           0    0 $   FUNCTION decrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO oahu_user;
            public       postgres    false    254            �	           0    0 .   FUNCTION decrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO oahu_user;
            public       postgres    false    256                        1255    20226 *   delete_message(character varying, integer)    FUNCTION     e  CREATE FUNCTION public.delete_message("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  MessageRec record;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- Check if MessageID is valid
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not valid."}');
  END IF;  

  IF MessageRec."ChildCount" > 0 THEN
    RETURN ('{"ErrNo" : "3", "Description" : "You cannot delete a message that has existing sub-messages. Delete sub-messages first."}');
  END IF;

  -- Check Permissions. TAs, Instructors, Admins, and the message owner can delete
  Permissions = db_get_permission(MessageRec."CourseID",CurrentUserID);
  IF NOT (Permissions > 1  OR CurrentUserID = MessageRec."UserID") THEN  
    RETURN ('{"ErrNo" : "12", "Description" : "This user does not have permission to delete this message."}');
  END IF;
  
  PERFORM db_decrement_child_count(MessageRec."ParentID");

  UPDATE "Messages" SET "DeletedBy" = CurrentUserID WHERE "ID" = MessageRec."ID";

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 Y   DROP FUNCTION public.delete_message("inToken" character varying, "inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 K   FUNCTION delete_message("inToken" character varying, "inMessageID" integer)    ACL     n   GRANT ALL ON FUNCTION public.delete_message("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    288            !           1255    20227 F   delete_user_from_course(character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.delete_user_from_course("inToken" character varying, "inDelUserLoginName" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  deleteUserID integer;
  AddUserRetVal json;
  ThisSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 2  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to alter this class."}');
  END IF;

  ThisSchool = db_get_school(CurrentUserID);

  -- check if user exists
  deleteUserID = db_get_user_id("inDelUserLoginName",ThisSchool);
  IF deleteUserID IS NULL THEN
    -- The user is not in database.  
    RETURN ('{"ErrNo" : "4", "Description" : "User to be deleted does not exist."}');
  END IF;

  -- Check if the user is in the class
  IF NOT EXISTS (SELECT 1 FROM "CourseMembers" WHERE "UserID"= deleteUserID AND "CourseID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "The user to be deleted is not in the course."}');
  END IF;

  -- The inputs should be valid at this point so insert user
  DELETE FROM "CourseMembers" WHERE "UserID"= deleteUserID AND "CourseID" = "inCourseID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');

END;$$;
 �   DROP FUNCTION public.delete_user_from_course("inToken" character varying, "inDelUserLoginName" character varying, "inCourseID" integer);
       public       postgres    false    4    1            �	           0    0 {   FUNCTION delete_user_from_course("inToken" character varying, "inDelUserLoginName" character varying, "inCourseID" integer)    ACL     �   GRANT ALL ON FUNCTION public.delete_user_from_course("inToken" character varying, "inDelUserLoginName" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    289            "           1255    20228 ;   delete_user_from_group(character varying, integer, integer)    FUNCTION     �  CREATE FUNCTION public.delete_user_from_group("inToken" character varying, "inGroupID" integer, "inUserID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  GroupUserID integer;
  Permissions integer;
  GroupPermissions integer;
  UserGroupRec record;
  ThisCourseID integer;
  ThisUserType integer;
  --ThisGroupName character varying;
BEGIN
  --Check if GroupID is valid
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This GroupID is not valid."}');
  END IF;  
  ThisCourseID = UserGroupRec."CourseID";

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    

  -- check if current user is an admin for the group.
  GroupPermissions = db_get_group_permissions(UserGroupRec."ID",CurrentUserID);
  RAISE NOTICE 'GroupPermission is %',GroupPermissions;
  IF GroupPermissions != 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to do delete members."}');
  END IF;  

  --Check if userID is in group
  DELETE FROM "UserGroupMembers" WHERE "UserID" = "inUserID" AND "GroupID" = "inGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "4", "Description" : "User is not in this group."}');
  END IF;

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 s   DROP FUNCTION public.delete_user_from_group("inToken" character varying, "inGroupID" integer, "inUserID" integer);
       public       postgres    false    4    1            �	           0    0 e   FUNCTION delete_user_from_group("inToken" character varying, "inGroupID" integer, "inUserID" integer)    ACL     �   GRANT ALL ON FUNCTION public.delete_user_from_group("inToken" character varying, "inGroupID" integer, "inUserID" integer) TO oahu_user;
            public       postgres    false    290            #           1255    20229 -   delete_user_group(character varying, integer)    FUNCTION     C  CREATE FUNCTION public.delete_user_group("inToken" character varying, "inUserGroupID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  UserGroupRec record;
  IsGroupAdmin boolean;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- Check if UserGroupID is valid
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inUserGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This UserGroupID is not valid."}');
  END IF;    

  -- Check if the usergroup has any messages in it.
  IF EXISTS (SELECT 1 FROM "MessageGroupMembers" WHERE "MessageGroupID" = UserGroupRec."MessageGroupID") THEN
    RETURN ('{"ErrNo" : "3", "Description" : "There are still messages in this usergroup.  Remove them first."}');
  END IF;
  

  -- Check if the current user is an admin in the usergroup
  IsGroupAdmin = FALSE;
  IF NOT EXISTS (SELECT 1 FROM "UserGroupMembers" WHERE "UserID" = CurrentUserID AND "GroupID" = "inUserGroupID" AND "UserType" = 1) THEN
    IsGroupAdmin = TRUE;
  END IF;   

  -- Check Permissions. TAs, Instructors, Admins, and the group admin can delete
  Permissions = db_get_permission(UserGroupRec."CourseID",CurrentUserID);
  IF NOT (Permissions > 1  OR IsGroupAdmin) THEN  
    RETURN ('{"ErrNo" : "4", "Description" : "This user does not have permission to alter this class."}');
  END IF;

  -- should be good to delete
  DELETE FROM "UserGroupMembers" WHERE "GroupID" = "inUserGroupID";
  DELETE FROM "MessageGroups" WHERE "ID" = UserGroupRec."MessageGroupID";
  DELETE FROM "UserGroups" WHERE "ID" = "inUserGroupID";
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 ^   DROP FUNCTION public.delete_user_group("inToken" character varying, "inUserGroupID" integer);
       public       postgres    false    1    4            �	           0    0 P   FUNCTION delete_user_group("inToken" character varying, "inUserGroupID" integer)    ACL     s   GRANT ALL ON FUNCTION public.delete_user_group("inToken" character varying, "inUserGroupID" integer) TO oahu_user;
            public       postgres    false    291            �	           0    0    FUNCTION digest(bytea, text)    ACL     ?   GRANT ALL ON FUNCTION public.digest(bytea, text) TO oahu_user;
            public       postgres    false    321            �	           0    0    FUNCTION digest(text, text)    ACL     >   GRANT ALL ON FUNCTION public.digest(text, text) TO oahu_user;
            public       postgres    false    345            q           1255    20230 N   edit_message(character varying, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$--MessageTypes:
--1 - question thread
--2 - note thread
--3 - message reply
--4 - group message thread  ( send group members in json )
--5 - poll message thread  (send poll items in json )
--6 - poll message with group
--7 - group message

DECLARE
  MessageRec record;
  CurrentUserRec record;
  CurrentUserID integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;  

  SELECT * INTO CurrentUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  -- Check if MessageID is valid
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not valid."}');
  END IF;  

  -- Check if user has permission to edit
  IF CurrentUserID != MessageRec."UserID" AND MessageRec."Type" != '7' THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User does not have permission to edit this message."}');
  END IF;

  -- We want to maintain the current message ID for the edited message, so copy the current message to a new message
  -- and mark it as edited
  INSERT INTO "Messages" ("ParentID","CourseID","UserID","Type","TimeCreated",
                          "Title","Message","hasAttachment","ChildCount",
                          "DeletedBy","EditedBy","UserGroupID","LastEditedBy")
    VALUES (MessageRec."ID",MessageRec."CourseID",MessageRec."UserID",MessageRec."Type",MessageRec."TimeCreated",
            MessageRec."Title",MessageRec."Message",MessageRec."hasAttachment",MessageRec."ChildCount",
            MessageRec."DeletedBy",CurrentUserID,MessageRec."UserGroupID",MessageRec."LastEditedBy");

  UPDATE "Messages" SET "TimeCreated" = NOW(), "Title" = "inMessageTitle", 
                        "Message" = "inMessageMessage", "LastEditedBy" = CurrentUserRec."LoginName"
          WHERE "ID" = "inMessageID";


  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying)    ACL     �   GRANT ALL ON FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying) TO oahu_user;
            public       postgres    false    369            %           1255    20231 t   edit_message(character varying, integer, character varying, character varying, character varying, character varying)    FUNCTION     ;  CREATE FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying, "inMessageSetting" character varying, "inMessageType" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  MessageRec record;
  CurrentUserRec record;
  CurrentUserID integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;  

  SELECT * INTO CurrentUserRec FROM "Users" WHERE "ID" = CurrentUserID;

  -- Check if MessageID is valid
  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "This MessageID is not valid."}');
  END IF;  

  -- Check if user has permission to edit
  IF CurrentUserID != MessageRec."UserID" THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User does not have permission to edit this message."}');
  END IF;

  -- We want to maintain the current message ID for the edited message, so copy the current message to a new message
  -- and mark it as edited
  INSERT INTO "Messages" ("ParentID","CourseID","UserID","Type","TimeCreated",
                          "Title","Message","hasAttachment","ChildCount",
                          "DeletedBy","EditedBy","UserGroupID","LastEditedBy")
    VALUES (MessageRec."ID",MessageRec."CourseID",MessageRec."UserID",MessageRec."Type",MessageRec."TimeCreated",
            MessageRec."Title",MessageRec."Message",MessageRec."hasAttachment",MessageRec."ChildCount",
            MessageRec."DeletedBy",CurrentUserID,MessageRec."UserGroupID",MessageRec."LastEditedBy");

  UPDATE "Messages" SET "TimeCreated" = NOW(), "Title" = "inMessageTitle", 
                        "Message" = "inMessageMessage", "LastEditedBy" = CurrentUserRec."LoginName",
                        "Type" = "inMessageType", "Setting" = "inMessageSetting"
          WHERE "ID" = "inMessageID";


  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying, "inMessageSetting" character varying, "inMessageType" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying, "inMessageSetting" character varying, "inMessageType" character varying)    ACL     �   GRANT ALL ON FUNCTION public.edit_message("inToken" character varying, "inMessageID" integer, "inMessageTitle" character varying, "inMessageMessage" character varying, "inMessageSetting" character varying, "inMessageType" character varying) TO oahu_user;
            public       postgres    false    293            �	           0    0 $   FUNCTION encrypt(bytea, bytea, text)    ACL     G   GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO oahu_user;
            public       postgres    false    327            �	           0    0 .   FUNCTION encrypt_iv(bytea, bytea, bytea, text)    ACL     Q   GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO oahu_user;
            public       postgres    false    255            �	           0    0 "   FUNCTION gen_random_bytes(integer)    ACL     E   GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO oahu_user;
            public       postgres    false    257            �	           0    0    FUNCTION gen_random_uuid()    ACL     =   GRANT ALL ON FUNCTION public.gen_random_uuid() TO oahu_user;
            public       postgres    false    258            �	           0    0    FUNCTION gen_salt(text)    ACL     :   GRANT ALL ON FUNCTION public.gen_salt(text) TO oahu_user;
            public       postgres    false    325            �	           0    0     FUNCTION gen_salt(text, integer)    ACL     C   GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO oahu_user;
            public       postgres    false    326            &           1255    20232 %   get_active_courses(character varying)    FUNCTION     |  CREATE FUNCTION public.get_active_courses("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  UserID integer;
  Count integer;
  ThisSchool integer;
BEGIN
  UserID = db_get_user_id_from_session("inToken");
  IF UserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisSchool = db_get_school(UserID);

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "Courses"."ID","Courses"."Number","Courses"."Name","Courses"."StartDate","Courses"."EndDate" 
  FROM "Courses"
  WHERE "Courses"."EndDate" > NOW() AND "Courses"."School" = ThisSchool) r;

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;  

  --RETURN jsonb_build_object('MyActiveCourses',Result,'Count',Count);
END;$$;
 F   DROP FUNCTION public.get_active_courses("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 8   FUNCTION get_active_courses("inToken" character varying)    ACL     [   GRANT ALL ON FUNCTION public.get_active_courses("inToken" character varying) TO oahu_user;
            public       postgres    false    294            '           1255    20233 "   get_all_courses(character varying)    FUNCTION     E  CREATE FUNCTION public.get_all_courses("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  UserID integer;
  Count integer;
  ThisSchool integer;
BEGIN
  UserID = db_get_user_id_from_session("inToken");
  IF UserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisSchool = db_get_school(UserID);

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "Courses"."ID","Courses"."Number","Courses"."Name","Courses"."StartDate","Courses"."EndDate" 
  FROM "Courses"
  WHERE "School" = ThisSchool) r;

 SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;
  --RETURN jsonb_build_object('AllCourses',Result,'Count',Count);
END;$$;
 C   DROP FUNCTION public.get_all_courses("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 5   FUNCTION get_all_courses("inToken" character varying)    ACL     X   GRANT ALL ON FUNCTION public.get_all_courses("inToken" character varying) TO oahu_user;
            public       postgres    false    295            (           1255    20234 &   get_course(character varying, integer)    FUNCTION     4  CREATE FUNCTION public.get_course("inToken" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  ThisUserID integer;
  Result json;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;
  -- Can user read info from the specified course?
  IF NOT EXISTS (SELECT 1 FROM "CourseMembers" WHERE "CourseID" = "inCourseID" AND "UserID" = ThisUserID) THEN
    RETURN ('{"ErrNo" : "2", "Description" : "User is not a member of this course."}');
  END IF;  

  SELECT array_to_json(array_agg(row_to_json(r))) INTO Result FROM
(SELECT "ID","Number","Name","StartDate","EndDate"
  FROM "Courses"
  WHERE "ID" = "inCourseID") r;  
  
  RETURN Result;
END;$$;
 T   DROP FUNCTION public.get_course("inToken" character varying, "inCourseID" integer);
       public       postgres    false    1    4            �	           0    0 F   FUNCTION get_course("inToken" character varying, "inCourseID" integer)    ACL     i   GRANT ALL ON FUNCTION public.get_course("inToken" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    296            r           1255    20235 =   get_limited_search(character varying, json, integer, integer)    FUNCTION     �  CREATE FUNCTION public.get_limited_search("inToken" character varying, "inCriteria" json, "inLimit" integer, "inOffset" integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
  ThisUserID integer;
  Count integer;
  Item text;
  Value text;
  Result jsonb;
  WhereClause character varying;
  FinalQuerry character varying;
  FoundUsergroupID boolean;
  GroupPermissionType integer;
  GroupID integer;
  CleanLimit integer;
  CleanOffset integer;  
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
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


  FoundUsergroupID = FALSE;
  FOR Item IN SELECT * FROM json_object_keys("inCriteria")
  LOOP
    Value = "inCriteria"->>Item;
    --RAISE NOTICE 'Item:%  Value:%',Item,Value;
    IF WhereClause IS NOT NULL THEN
      WhereClause = WhereClause || ' AND ';
    ELSE
      WhereClause = '';
    END IF;
    IF Item = 'CourseID' THEN
      --RAISE NOTICE 'Found CourseID';
      WhereClause = WhereClause || '"CourseID" = ' || to_char(to_number(Value,'9999999999'),'9999999999') ;
    ELSIF Item = 'UserGroupID' THEN
      --RAISE NOTICE 'Found UserGroupID';
      FoundUsergroupID = TRUE;
      WhereClause = WhereClause || '"UserGroupID" = ' || to_char(to_number(Value,'9999999999'),'9999999999') ;
    ELSIF Item = 'MessageGroupID' THEN
      --RAISE NOTICE 'Found MessageGroupID';
      GroupID = Value;
      IF NOT GroupID > 0 THEN
        RETURN ('{"ErrNo" : "3", "Description" : "Invalid GroupID."}');
      END IF;
      GroupPermissionType = db_get_group_permissions(ThisUserID,GroupID);
      IF GroupPermissionType = 1 OR GroupPermissionType = 3 OR GroupPermissionType = 4 THEN
        WhereClause = WhereClause || '"CourseID" = ' || to_char(GroupID,'9999999999') ;
      ELSE
        RETURN ('{"ErrNo" : "3", "Description" : "Cannot read group."}');
      END IF;
    ELSIF Item = 'IsThread' THEN
      --RAISE NOTICE 'Found IsThread';
      WhereClause = WhereClause || '"ParentID" IS NULL';
    --ELSIF Item = 'MessageType' THEN
--      RAISE NOTICE 'Found MessageType';
--      WhereClause = WhereClause || '"Type" = ' || to_char(to_number(Value,'9999999999'),'9999999999') ;
--    ELSIF Item = 'LastPostLTE' THEN
--      RAISE NOTICE 'Found LastPostLTE';
--      WhereClause = WhereClause || '"LastPost" <= ' || '''' || to_char(to_date(Value,'YYYY-MM-DD'),'YYYY-MM-DD') || '''' ;
--    ELSIF Item = 'LastPostGTE' THEN
--      RAISE NOTICE 'Found LastPostGTE';
--      WhereClause = WhereClause || '"LastPost" >= ' || '''' || to_char(to_date(Value,'YYYY-MM-DD'),'YYYY-MM-DD') || '''' ;
    ELSIF Item = 'CreationTimeLTE' THEN
      --RAISE NOTICE 'Found CreationTimeLTE';
      WhereClause = WhereClause || '"TimeCreated" <= ' || '''' || to_char(to_date(Value,'YYYY-MM-DD'),'YYYY-MM-DD') || '''' ;
    ELSIF Item = 'CreationTimeGTE' THEN
      --RAISE NOTICE 'Found CreationTimeGTE';
      WhereClause = WhereClause || '"TimeCreated" >= ' || '''' || to_char(to_date(Value,'YYYY-MM-DD'),'YYYY-MM-DD') || '''' ;
    ELSEIF Item = 'ChildCountGTE' THEN
      --RAISE NOTICE 'Found ChildCountGTE';
      WhereClause = WhereClause || '"ChildCount" >= ' || '''' || to_char(to_number(Value,'9999999999'),'9999999999') || '''' ;
    ELSEIF Item = 'ChildCountLTE' THEN
      --RAISE NOTICE 'Found ChildCountLTE';
      WhereClause = WhereClause || '"ChildCount" <= ' || '''' || to_char(to_number(Value,'9999999999'),'9999999999') || '''' ;
    ELSEIF Item = 'ScoreGTE' THEN
      --RAISE NOTICE 'Found ChildCountGTE';
      WhereClause = WhereClause || '"score" >= ' || '''' || to_char(to_number(Value,'9999999999'),'9999999999') || '''' ;
    ELSEIF Item = 'ScoreLTE' THEN
      --RAISE NOTICE 'Found ChildCountLTE';
      WhereClause = WhereClause || '("score" <= ' || '''' || to_char(to_number(Value,'9999999999'),'9999999999') || ''' OR "score" IS NULL)' ;
    --ELSIF Item = 'MessageText' THEN
    --  RAISE NOTICE 'Found MessageText';
    -- 
    --  WhereClause = WhereClause || '"MessageText" ???? ;
    ELSE
      RETURN ('{"ErrNo" : "2", "Description" : "Invalid search Criteria: ' || Item || '"}');
    END IF;
    --RAISE NOTICE 'WhereClause: %',WhereClause;
  END LOOP;

--  FinalQuerry = 'SELECT array_to_json(array_agg(row_to_json(r))) FROM
 --(SELECT "ID","Type","TimeCreated","Title","Message","hasAttachment"
  --FROM "Messages"
  --WHERE '||WhereClause||' ) r';


  FinalQuerry = 'SELECT jsonb_agg(r) FROM
       (SELECT "Messages"."ID","Messages"."CourseID","Messages"."UserID","Messages"."TimeCreated",
      "Messages"."Title","Messages"."Message","Messages"."hasAttachment","Messages"."ChildCount",
      db_message_is_read("Users"."ReadGroupID","Messages"."ID") AS isRead, "Messages"."UserGroupID","Messages"."LastEditedBy",
      "Users"."FirstName", "Users"."LastName","Messages"."Type","Messages"."Setting","Messages"."UserGroupID","Messages"."PollType",
      s.score AS "Score"
    FROM "Messages"
    LEFT OUTER JOIN "Users" ON "Users"."ID" = "Messages"."UserID"
    LEFT OUTER JOIN (SELECT "MessageID",SUM("Score") AS score
                FROM "MessageVotes" GROUP BY "MessageID") AS s ON s."MessageID" = "Messages"."ID"
    WHERE "Messages"."DeletedBy" IS NULL AND "Messages"."EditedBy" IS NULL AND '||WhereClause||' 
    ORDER BY "Messages"."TimeCreated"
    LIMIT ' || CleanLimit || '
    OFFSET ' || CleanOffset || '
    ) r';


  --RAISE NOTICE 'FinalQuerry: %',FinalQuerry;

    
  EXECUTE FinalQuerry INTO Result;  

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('AllCourses',Result,'Count',Count);

END;$$;
 �   DROP FUNCTION public.get_limited_search("inToken" character varying, "inCriteria" json, "inLimit" integer, "inOffset" integer);
       public       postgres    false    1    4            �	           0    0 r   FUNCTION get_limited_search("inToken" character varying, "inCriteria" json, "inLimit" integer, "inOffset" integer)    ACL     �   GRANT ALL ON FUNCTION public.get_limited_search("inToken" character varying, "inCriteria" json, "inLimit" integer, "inOffset" integer) TO oahu_user;
            public       postgres    false    370            �            1255    20237 I   get_limited_thread_messages(character varying, integer, integer, integer)    FUNCTION     o  CREATE FUNCTION public.get_limited_thread_messages("inToken" character varying, "inMessageID" integer, "inLimit" integer, "inOffset" integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
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

END;$$;
 �   DROP FUNCTION public.get_limited_thread_messages("inToken" character varying, "inMessageID" integer, "inLimit" integer, "inOffset" integer);
       public       postgres    false    4    1            �	           0    0    FUNCTION get_limited_thread_messages("inToken" character varying, "inMessageID" integer, "inLimit" integer, "inOffset" integer)    ACL     �   GRANT ALL ON FUNCTION public.get_limited_thread_messages("inToken" character varying, "inMessageID" integer, "inLimit" integer, "inOffset" integer) TO oahu_user;
            public       postgres    false    247            +           1255    20238 T   get_limited_usergroup_threads(character varying, integer, integer, integer, integer)    FUNCTION     Q  CREATE FUNCTION public.get_limited_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer, "inLimit" integer, "inOffset" integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
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
END;$$;
 �   DROP FUNCTION public.get_limited_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer, "inLimit" integer, "inOffset" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION get_limited_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer, "inLimit" integer, "inOffset" integer)    ACL     �   GRANT ALL ON FUNCTION public.get_limited_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer, "inLimit" integer, "inOffset" integer) TO oahu_user;
            public       postgres    false    299            �            1255    20239 '   get_message(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.get_message("inToken" character varying, "inMessageID" integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
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
$$;
 V   DROP FUNCTION public.get_message("inToken" character varying, "inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 H   FUNCTION get_message("inToken" character varying, "inMessageID" integer)    ACL     k   GRANT ALL ON FUNCTION public.get_message("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    235            s           1255    20240 5   get_message_group_members(character varying, integer)    FUNCTION     /  CREATE FUNCTION public.get_message_group_members("inToken" character varying, "inMessageGroupID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  GroupInfo record;
  Result jsonb;
  Count integer;
BEGIN
  -- check if group exists
  SELECT * into GroupInfo FROM "MessageGroups" WHERE "ID" = "inMessageGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This group ID does not exist."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(GroupInfo."CourseID",CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user is not a member of this course."}');
  END IF;

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "MessageGroupMembers"."MessageID" ,"Messages"."Title","Messages"."Message"
  FROM "MessageGroupMembers"
  INNER JOIN "Messages" ON "MessageGroupMembers"."MessageID" = "Messages"."ID"
  WHERE "MessageGroupMembers"."MessageGroupID" = "inMessageGroupID") r;  
  -- ,"Messages"."Title","Messages"."Message"
  --INNER JOIN "Messages" ON "MessageGroupMembers"."MessageID" = "Messages"."ID"

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('Count',Count,'MessageGroupMembers',Result);
END;$$;
 i   DROP FUNCTION public.get_message_group_members("inToken" character varying, "inMessageGroupID" integer);
       public       postgres    false    4    1            �	           0    0 [   FUNCTION get_message_group_members("inToken" character varying, "inMessageGroupID" integer)    ACL     ~   GRANT ALL ON FUNCTION public.get_message_group_members("inToken" character varying, "inMessageGroupID" integer) TO oahu_user;
            public       postgres    false    371            )           1255    20241 ;   get_message_poll_votes(character varying, integer, boolean)    FUNCTION     H  CREATE FUNCTION public.get_message_poll_votes("inToken" character varying, "inMessagePollID" integer, "inDoSums" boolean) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  MessageInfo record;
  MessagePollInfo record;
  Result jsonb;
  VoteResults jsonb;
  VoteItems jsonb;
  Count integer;
BEGIN
  -- check if message exists
  SELECT * into MessageInfo FROM "Messages" WHERE "ID" = "inMessagePollID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "11", "Description" : "This message ID does not exist."}');
  END IF;

  -- Check if message is a poll type
  IF MessageInfo."PollType" IS NULL THEN
    RETURN ('{"ErrNo" : "14", "Description" : "Message is not poll type."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "12", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(MessageInfo."CourseID",CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "13", "Description" : "This user is not a member of this course."}');
  END IF;

  SELECT jsonb_agg(r) INTO VoteItems FROM
  ( SELECT "ID","Name" FROM "MessagePollItem" WHERE "MessageID" = MessageInfo."ID" ORDER BY "ID") r;

  SELECT jsonb_agg(r) INTO VoteResults FROM
(SELECT "MessagePollVote"."MessagePollItemID" ,"MessagePollItem"."Name" AS "PollItemName","Users"."LoginName","Users"."ID" AS "UserID","MessagePollVote"."Value","Users"."FirstName","Users"."LastName"
  FROM "MessagePollVote"
  LEFT OUTER JOIN "MessagePollItem" ON "MessagePollVote"."MessagePollItemID" = "MessagePollItem"."ID"
  INNER JOIN "Messages" ON "MessagePollItem"."MessageID" = "Messages"."ID"
  INNER JOIN "Users" ON "MessagePollVote"."VotingUserID" = "Users"."ID"
  WHERE "MessagePollItem"."MessageID" = "inMessagePollID"
  ORDER BY "MessagePollVote"."MessagePollItemID") r;  

  SELECT count(*) INTO Count FROM jsonb_array_elements(VoteResults);

  RETURN jsonb_build_object('Count',Count,'PollItems',VoteItems,'PollVotes',VoteResults);
END;$$;
 y   DROP FUNCTION public.get_message_poll_votes("inToken" character varying, "inMessagePollID" integer, "inDoSums" boolean);
       public       postgres    false    1    4            �	           0    0 k   FUNCTION get_message_poll_votes("inToken" character varying, "inMessagePollID" integer, "inDoSums" boolean)    ACL     �   GRANT ALL ON FUNCTION public.get_message_poll_votes("inToken" character varying, "inMessagePollID" integer, "inDoSums" boolean) TO oahu_user;
            public       postgres    false    297            t           1255    20242 /   get_message_threads(character varying, integer)    FUNCTION     +  CREATE FUNCTION public.get_message_threads("inToken" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  ThisUserID integer;
  --ThisUserRec record;
  Result json;
BEGIN
  RETURN get_limited_usergroup_threads("inToken","inCourseID",NULL,0,0);
END;$$;
 ]   DROP FUNCTION public.get_message_threads("inToken" character varying, "inCourseID" integer);
       public       postgres    false    1    4            �	           0    0 O   FUNCTION get_message_threads("inToken" character varying, "inCourseID" integer)    ACL     r   GRANT ALL ON FUNCTION public.get_message_threads("inToken" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    372            ,           1255    20243 -   get_message_votes(character varying, integer)    FUNCTION     [  CREATE FUNCTION public.get_message_votes("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  MessageInfo record;
  Result jsonb;
  Count integer;
  
BEGIN
  -- check if message exists
  SELECT * into MessageInfo FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This message ID does not exist."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(MessageInfo."CourseID",CurrentUserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user is not a member of this course."}');
  END IF;

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "MessageVotes"."UserID" ,"MessageVotes"."Score"
  FROM "MessageVotes"
  INNER JOIN "Users" ON "Users"."ID" = "MessageVotes"."UserID"
  WHERE "MessageVotes"."MessageID" = "inMessageID") r;  

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('Count',Count,'MessageVotes',Result);
END;$$;
 \   DROP FUNCTION public.get_message_votes("inToken" character varying, "inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 N   FUNCTION get_message_votes("inToken" character varying, "inMessageID" integer)    ACL     q   GRANT ALL ON FUNCTION public.get_message_votes("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    300            -           1255    20244 (   get_my_active_courses(character varying)    FUNCTION     ,  CREATE FUNCTION public.get_my_active_courses("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  UserID integer;
  Count integer;
  CountRec record;
  ThisSchool integer;
BEGIN
  UserID = db_get_user_id_from_session("inToken");
  IF UserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisSchool = db_get_school(UserID);

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "Courses"."ID","Courses"."Number","Courses"."Name","Courses"."StartDate","Courses"."EndDate","CourseMembers"."UserType" 
  FROM "Courses"
  LEFT OUTER JOIN "CourseMembers" ON "Courses"."ID" = "CourseMembers"."CourseID" 
  WHERE "Courses"."EndDate" > NOW() AND "CourseMembers"."UserID" = UserID AND "Courses"."School" = ThisSchool) r;

  
  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('MyActiveCourses',Result,'Count',Count);
 
END;$$;
 I   DROP FUNCTION public.get_my_active_courses("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 ;   FUNCTION get_my_active_courses("inToken" character varying)    ACL     ^   GRANT ALL ON FUNCTION public.get_my_active_courses("inToken" character varying) TO oahu_user;
            public       postgres    false    301            .           1255    20245 %   get_my_all_courses(character varying)    FUNCTION     �  CREATE FUNCTION public.get_my_all_courses("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  UserID integer;
  Count integer;
  ThisSchool integer;
BEGIN
  UserID = db_get_user_id_from_session("inToken");
  IF UserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisSchool = db_get_school(UserID);

  SELECT jsonb_agg(r)INTO Result FROM
(SELECT "Courses"."ID","Courses"."Number","Courses"."Name","Courses"."StartDate","Courses"."EndDate","CourseMembers"."UserType" 
  FROM "Courses"
  LEFT OUTER JOIN "CourseMembers" ON "Courses"."ID" = "CourseMembers"."CourseID" 
  WHERE "CourseMembers"."UserID" = UserID AND "Courses"."School" = ThisSchool) r;

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('MyAllCourses',Result,'Count',Count);
END;$$;
 F   DROP FUNCTION public.get_my_all_courses("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 8   FUNCTION get_my_all_courses("inToken" character varying)    ACL     [   GRANT ALL ON FUNCTION public.get_my_all_courses("inToken" character varying) TO oahu_user;
            public       postgres    false    302            /           1255    20246 '   get_my_messagegroups(character varying)    FUNCTION     �  CREATE FUNCTION public.get_my_messagegroups("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Result jsonb;
BEGIN
    -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    

  SELECT jsonb_agg(r) INTO Result FROM 
    (SELECT "Courses"."ID" AS "CourseID","Courses"."Number" AS "CourseNumber","MessageGroups"."ID","MessageGroups"."Name" 
       FROM "MessageGroups"
       LEFT JOIN "Courses" ON "MessageGroups"."CourseID" = "Courses"."ID"
       WHERE "MessageGroups"."UserID" = CurrentUserID) r;

  RETURN Result;
END;$$;
 H   DROP FUNCTION public.get_my_messagegroups("inToken" character varying);
       public       postgres    false    4    1            �	           0    0 :   FUNCTION get_my_messagegroups("inToken" character varying)    ACL     ]   GRANT ALL ON FUNCTION public.get_my_messagegroups("inToken" character varying) TO oahu_user;
            public       postgres    false    303            0           1255    20247 $   get_my_usergroups(character varying)    FUNCTION     /  CREATE FUNCTION public.get_my_usergroups("inToken" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
  -- Visibility levels:
  -- 1 global - all users can see the group
  -- 2 course - all members of the course can see the group
  -- 3 group - only members of the group can see the group.
  -- 4 message - group only applies to a specific message so don't list in group listings.

DECLARE
  Result jsonb;
  CurrentUserID integer;
  MaxVisibility integer;
  Count integer;
BEGIN
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  SELECT jsonb_agg(r)  INTO Result FROM
(SELECT "UserGroups"."ID","UserGroups"."CourseID","UserGroups"."GroupName","UserGroups"."Visibility","UserGroupMembers"."UserType","UserGroups"."MessageGroupID"
  FROM "UserGroups"
  LEFT OUTER JOIN "UserGroupMembers" ON "UserGroups"."ID" = "UserGroupMembers"."GroupID" 
  WHERE --("UserGroups"."Visibility" = 4  AND "UserGroupMembers"."UserID" = CurrentUserID) OR
        ("UserGroups"."Visibility" = 3  AND "UserGroupMembers"."UserID" = CurrentUserID) OR
        ("UserGroups"."Visibility" = 2 AND db_get_permission("UserGroups"."CourseID",CurrentUserID) != 0) OR
        ("UserGroups"."Visibility" = 1)

  ) r;
  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('Count',Count,'MyUsergroups',Result);

END;$$;
 E   DROP FUNCTION public.get_my_usergroups("inToken" character varying);
       public       postgres    false    1    4            �	           0    0 7   FUNCTION get_my_usergroups("inToken" character varying)    ACL     Z   GRANT ALL ON FUNCTION public.get_my_usergroups("inToken" character varying) TO oahu_user;
            public       postgres    false    304            1           1255    20248 E   get_setting_for_course(character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.get_setting_for_course("inToken" character varying, "inName" character varying, "inCourse" integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
  ThisUserID integer;
  ThisUserSchool integer;
  SettingRec record;
  SelectedSettingRec record;

  Invisible boolean;

  ThisUserPermission integer;

  Count integer;

BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisUserSchool = db_get_school(ThisUserID);

  IF db_is_admin(ThisUserID) THEN
    --This user is an admin and that applies to all settings and all courses.
    ThisUserPermission = 999;
  ELSE
    --This user is not an admin so permissions need to be checked for each setting as it applies to specific courses.
    ThisUserPermission = db_get_max_permission(ThisUserID);
  END IF;


  Invisible = FALSE;
  Count = 0;
  FOR SettingRec IN SELECT * FROM "Settings" WHERE "Name" = "inName" AND ("CourseID" = "inCourse" OR "CourseID" IS NULL) AND ("School" = ThisUserSchool OR "School" IS NULL) AND ("UserID" = ThisUserID OR "UserID" IS NULL) ORDER BY "Rank" ASC,"School" ASC NULLS FIRST 
  LOOP
    IF "inCourse" IS NULL AND SettingRec."Rank">1 THEN
      -- Course settings do not apply if the courseid is null
      CONTINUE;
    END IF;
    Count = Count + 1;
    IF Invisible THEN
      CONTINUE;
    END IF;
    IF SettingRec."Rank" = 0 THEN
      IF SettingRec."Visibility" > ThisUserPermission THEN
        Invisible = TRUE;
      END IF;
    ELSIF SettingRec."Rank" = 2 THEN
      -- Get real permissions
      ThisUserPermission = db_get_permission(SettingRec."CourseID",ThisUserID);
      IF SettingRec."Visibility" > ThisUserPermission THEN
        Invisible = TRUE;
      END IF;
    END IF;
    SelectedSettingRec = SettingRec;
  END LOOP;

  IF Count = 0 THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Setting does not exist."}');
  END IF;

  IF Invisible THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User does not have permission to see this setting."}');
  END IF;

  RETURN jsonb_build_object('ErrNo','0') || to_jsonb(SelectedSettingRec);
  
END;$$;
 z   DROP FUNCTION public.get_setting_for_course("inToken" character varying, "inName" character varying, "inCourse" integer);
       public       postgres    false    4    1            �	           0    0 l   FUNCTION get_setting_for_course("inToken" character varying, "inName" character varying, "inCourse" integer)    ACL     �   GRANT ALL ON FUNCTION public.get_setting_for_course("inToken" character varying, "inName" character varying, "inCourse" integer) TO oahu_user;
            public       postgres    false    305            i           1255    20249 /   get_thread_messages(character varying, integer)    FUNCTION     �   CREATE FUNCTION public.get_thread_messages("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN get_limited_thread_messages("inToken","inMessageID",0,0);
END;$$;
 ^   DROP FUNCTION public.get_thread_messages("inToken" character varying, "inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 P   FUNCTION get_thread_messages("inToken" character varying, "inMessageID" integer)    ACL     s   GRANT ALL ON FUNCTION public.get_thread_messages("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    361                       1255    20250 .   get_user(character varying, character varying)    FUNCTION     &  CREATE FUNCTION public.get_user("inToken" character varying, "inLoginName" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Result jsonb;
BEGIN
  -- Confirm current user is logged in
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- Confirm that the selected user exists.
  IF NOT EXISTS (SELECT 1 FROM "Users" WHERE "LoginName" = "inLoginName" ) THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Selected user does not exist."}');
  END IF;  

  -- return user information
  SELECT jsonb_agg(r) INTO Result FROM
(SELECT * 
  FROM "Users"
  WHERE "LoginName" = "inLoginName") r;    

  RETURN Result;

END;$$;
 ]   DROP FUNCTION public.get_user("inToken" character varying, "inLoginName" character varying);
       public       postgres    false    1    4            �	           0    0 O   FUNCTION get_user("inToken" character varying, "inLoginName" character varying)    ACL     r   GRANT ALL ON FUNCTION public.get_user("inToken" character varying, "inLoginName" character varying) TO oahu_user;
            public       postgres    false    287            j           1255    20251 $   get_user_settings(character varying)    FUNCTION     �9  CREATE FUNCTION public.get_user_settings("inToken" character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  ReturnVal character varying;
  ThisUserID integer;
  ThisUserSchool integer;
  --IsAdmin boolean;

  SettingRec record;
  LastSettingRec record;
  Rank0SettingRec record;  
  Rank1SettingRec record;
  Rank2SettingRec record;
  SelectedSettingRec record;  
  InvisibleAtRank0 boolean;
  InvisibleAtRank2 boolean;

  ThisUserPermission integer;
  ThisUserMaxPermission integer;
  Count integer;
  FoundSomething boolean;
BEGIN
  ThisUserID = db_get_user_id_from_session("inToken");
  IF ThisUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  ThisUserSchool = db_get_school(ThisUserID);

  --DROP TABLE IF EXISTS "UserSettingResults";
  CREATE TEMPORARY TABLE "UserSettingResults"
  (
    "Rank" integer NOT NULL,
    "UserID" integer,
    "CourseID" integer,
    "Name" text NOT NULL,
    "Value" text NOT NULL,
    "Permission" integer,
    "Visibility" integer,
    "Type" integer
  );

  IF db_is_admin(ThisUserID) THEN
    --This user is an admin and that applies to all settings and all courses.
    ThisUserPermission = 999;
    ThisUserMaxPermission = 999;
  ELSE
    --This user is not an admin so permissions need to be checked for each setting as it applies to specific courses.
    ThisUserMaxPermission = db_get_max_permission(ThisUserID);
    ThisUserPermission = ThisUserMaxPermission;
  END IF;

  --CourseList = ARRAY(SELECT "ID" FROM "Courses"
  --  LEFT OUTER JOIN "CourseMembers" ON "Courses"."ID" = "CourseMembers"."CourseID"
  --  WHERE "CourseMembers"."UserID" = 10);

  -- So now we have the list of courses we can step through each setting and know which courses do not
  -- have settings assigned and therefore use the defaults.  We only need to include the defaults once.
  --LastSettingValid = FALSE;
  --LastVisibility = 999; -- Assume the worst
  --RAISE NOTICE 'First Initialization';
  SELECT NULL INTO SelectedSettingRec;
  SELECT NULL INTO Rank0SettingRec;
  SELECT NULL INTO Rank1SettingRec;
  SELECT NULL INTO Rank2SettingRec;
  Count = 0;
  InvisibleAtRank0 = FALSE;
  InvisibleAtRank2 = FALSE;
  FoundSomething = FALSE;
  FOR SettingRec IN SELECT * FROM "Settings" WHERE ("School" = ThisUserSchool OR "School" IS NULL) AND ("UserID" = ThisUserID OR "UserID" IS NULL) ORDER BY "Name","CourseID" ASC NULLS FIRST,"Rank" ASC,"School" ASC NULLS FIRST 
  LOOP
    FoundSomething = TRUE;
    RAISE NOTICE 'Evaluating SEtting : %',SettingRec;
    IF SelectedSettingRec IS NULL THEN
      -- The only way this can happen is if it is the very first SettingRec, so there is nothing to compare it against and it needs to be handled special.
      RAISE NOTICE 'SelectedSettingRec IS NULL so get next';
      SelectedSettingRec = SettingRec;
      IF SettingRec."Rank" = 0 THEN
        IF SettingRec."Visibility" > ThisUserMaxPermission THEN
          InvisibleAtRank0=TRUE;
        ELSE
          Rank0SettingRec = SettingRec;
        END IF;
      ELSIF SettingRec."Rank" = 2 THEN
        -- Rank >=2 means that courseid is valid so get permissions
        ThisUserPermission = db_get_permission(SettingRec."CourseID",ThisUserID);        
        IF SettingRec."Visibility" > ThisUserPermission THEN
          InvisibleAtRank2 = TRUE;
        ELSE
          Rank2SettingRec = SettingRec;
        END IF;
      -- Rank 1 and Rank3 do not use permissions and visiblility. Since this is the only setting we have so far, it is considered good for now if rank 1 or 2
      END IF;
      -- Setup for the first setting is complete so continue to the next iteration of the loop.
      CONTINUE;
    END IF;
    
    -- The first iteration of the loop has been handled, so we are ready to process the normal way.
    IF SettingRec."Name" != SelectedSettingRec."Name" THEN
      -- This is a completely new setting so write the old one if applicable and initialize the new one
      RAISE NOTICE 'New Setting Name Detected so write the last one to results';
      -- Write the old setting
      IF NOT (InvisibleAtRank0 OR InvisibleAtRank2) THEN
        RAISE NOTICE 'Writing Setting % AS %',SelectedSettingRec."Name",SelectedSettingRec."Value";
        IF ThisUserPermission != 0 THEN  -- 0 Means they are not in this course.
          Count = Count + 1;
          INSERT INTO "UserSettingResults" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type")
            VALUES (SelectedSettingRec."Rank",SelectedSettingRec."UserID",SelectedSettingRec."CourseID",SelectedSettingRec."Name",SelectedSettingRec."Value",SelectedSettingRec."Permission",SelectedSettingRec."Visibility",SelectedSettingRec."Type");
        END IF;
        IF SelectedSettingRec."Rank" > 1 AND NOT (Rank0SettingRec IS NULL) THEN 
          -- The Rank0 and Rank1 settings exist outside of courses.  Since any courses can overwrite the Rank0 and Rank1 settings for
          -- that course but not all courses, we need to write the default that applies to any unset courses.  There can be 4 or 5 rank 2 and 3
          -- settings but only 1 rank 0 and 1.  That 1 rank 0 or 1 setting is written here after the other ones are processed if it exists.
          Count = Count + 1;
          INSERT INTO "UserSettingResults" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type")
            VALUES (Rank0SettingRec."Rank",Rank0SettingRec."UserID",Rank0SettingRec."CourseID",Rank0SettingRec."Name",Rank0SettingRec."Value",Rank0SettingRec."Permission",Rank0SettingRec."Visibility",Rank0SettingRec."Type");
        END IF;
      ELSE
        RAISE NOTICE 'Setting % is invisible at Rank 0',SelectedSettingRec."Name";
      END IF;
      -- Starting over with a new setting so initialize everything.
      RAISE NOTICE 'Reinitializing for setting %',SettingRec."Name";
      --SELECT NULL INTO SelectedSettingRec;
      SELECT NULL INTO Rank0SettingRec;
      SELECT NULL INTO Rank1SettingRec;
      SELECT NULL INTO Rank2SettingRec;
      InvisibleAtRank0 = FALSE;
      InvisibleAtRank2 = FALSE;
      IF ThisUserPermission != 999 THEN
        ThisUserPermission = 1;
      END IF;
    END IF;

    -- Setup for this setting chain is complete so start processing the settings.
    IF InvisibleAtRank0 THEN
      CONTINUE;
    ELSIF SettingRec."Rank" = 0 THEN
      RAISE NOTICE 'Found Setting % AT Rank 0',SettingRec."Name";
      IF SettingRec."Visibility" > ThisUserMaxPermission THEN
        --RAISE NOTICE 'Visibility check of % failed for user permission %',SettingRec."Visibility",ThisUserPermission;
        InvisibleAtRank0 = TRUE;
        CONTINUE;
      ELSE
        Rank0SettingRec = SettingRec;  -- There can be only one
        SelectedSettingRec = SettingRec;
        RAISE NOTICE 'Setting Selected at rank 0';
      END IF;
    ELSIF SettingRec."Rank" = 1 THEN
      RAISE NOTICE 'Found Setting % AT Rank 1',SettingRec."Name";
      IF Rank0SettingRec IS NULL THEN
        RAISE NOTICE 'Rank0SettingRec is NULL';
        Rank0SettingRec = SettingRec;  -- Rank0SettingRec becomes the best of the two
        SelectedSettingRec = SettingRec;
        RAISE NOTICE 'Setting Selected at rank 1';
      ELSIF Rank0SettingRec."Permission" <= ThisUserMaxPermission THEN
        -- Permissions and visibility are set by Rank 0
        RAISE NOTICE 'Permission check of % failed for user permission %',SettingRec."Permission",ThisUserMaxPermission;
        SettingRec."Permission" = Rank0SettingRec."Permission";
        SettingRec."Visibility" = Rank0SettingRec."Permission"; -- Permission can never be lower than visibility.  This covers the case where permission has changed.
        Rank0SettingRec = SettingRec;  -- Rank0SettingRec becomes the best of the two
        SelectedSettingRec = SettingRec;
        RAISE NOTICE 'Setting Selected at rank 1';
      END IF;
    ELSE
      -- Setting Rank must be 2 or 3
      IF Rank2SettingRec IS NULL THEN
        -- This must be the first occurance of this setting at Rank2
        -- Set this CourseID's permissions for this user.
        RAISE NOTICE 'Initializing the % CourseID at rank 2 or 3',SettingRec."CourseID";
        IF ThisUserPermission != 999 THEN 
          -- must be a regular user so permissions change with the course.
          ThisUserPermission = db_get_permission(SettingRec."CourseID",ThisUserID);
          IF ThisUserPermission = 0 THEN
            -- This user is not a member of this course so don't worry about this setting.
            RAISE NOTICE 'This user is not a member of course %',SettingRec."CourseID";
            CONTINUE;
          END IF;
        END IF;
        InvisibleAtRank2 = FALSE;
      ELSE
        -- check if it is a different course
        IF SettingRec."CourseID" != Rank2SettingRec."CourseID" THEN
          -- This is a new course, and the old setting is still in play, so write it to the table.
          RAISE NOTICE 'A new course ID has been found at rank 2 or 3';
          IF NOT InvisibleAtRank2 THEN
            IF ThisUserPermission != 0 THEN
              RAISE NOTICE 'Writing setting % at rank 2 or 3 for course %',SelectedSettingRec."Name",SelectedSettingRec."CourseID";
              Count = Count + 1;
              INSERT INTO "UserSettingResults" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type")
                VALUES (SelectedSettingRec."Rank",SelectedSettingRec."UserID",SelectedSettingRec."CourseID",SelectedSettingRec."Name",SelectedSettingRec."Value",SelectedSettingRec."Permission",SelectedSettingRec."Visibility",SelectedSettingRec."Type");
            END IF;
          END IF;
          SELECT NULL INTO Rank2SettingRec;
        -- Set this CourseID's permissions for this user.
          IF ThisUserPermission != 999 THEN 
            -- must be a regular user so permissions change with the course.
            ThisUserPermission = db_get_permission(SettingRec."CourseID",ThisUserID);
            IF ThisUserPermission = 0 THEN
              -- This user is not a member of this course so don't worry about these settings.
              RAISE NOTICE 'This user is not a member of course %',SettingRec."CourseID";
              CONTINUE;
            END IF;
          END IF;
          InvisibleAtRank2 = FALSE;
        END IF;
      END IF;

      -- The setup for rank 2 and 3 is complete.  Process the setting.
      IF InvisibleAtRank2 THEN
        CONTINUE;
      END IF;

      -- Check if Rank2 overrides the visibility settings
      IF SettingRec."Rank" = 2 THEN
        RAISE NOTICE 'Setting is rank 2';
        IF Rank0SettingRec IS NULL THEN
          -- This setting should select visibility at Rank 2
          IF SettingRec."Visibility" > ThisUserPermission THEN
            RAISE NOTICE 'Rank 0 set the setting invisible in rank 2';
            InvisibleAtRank2 = TRUE;
          ELSE
            RAISE NOTICE 'Setting Selected at rank 2';
            SelectedSettingRec = SettingRec;
            Rank2SettingRec = SettingRec;
            CONTINUE;
          END IF;
        ELSE
          IF Rank0SettingRec."Permission" = 999 AND SettingRec."Permission" != 999 THEN
            -- This possibility is a gray area.  There is no way for a non-admin to set this setting
            -- with a Permission of admin on Rank0.  I don't know if it was an admin or not who
            -- set the permission.  However, if it is 999 then I know it was set by an admin.  
            -- So, this choice allows an admin to override at the course level by using a permission 
            -- of 999 there.  Everyone else is assumed to not have permission even if they really do.  
            -- This is to cover a fringe case where an admin changes permissions at rank 0 after settings 
            -- at rank 2 have been created.  Under all other circumstances this never happens since it 
            -- could not have been created in the first place. Since it should not exist, pretend the 
            -- setting does not exist and make it invisible at rank 2 and above.
            InvisibleAtRank2 = TRUE;
            CONTINUE;
          ELSE         
            -- This setting should select visiblity.     
            IF SettingRec."Visibility" > ThisUserPermission THEN
              RAISE NOTICE 'Rank 2 set the setting invisible';
              InvisibleAtRank2 = TRUE;
            ELSE
              RAISE NOTICE 'Setting Selected at rank 2';
              Rank2SettingRec = SettingRec;
              SelectedSettingRec = SettingRec;
            END IF;
          END IF;
        END IF;
      ELSE
        -- Setting must be Rank 3 AND it must be visible.
        -- There is nowhere else to go so set it as the selected setting
        RAISE NOTICE 'Setting Selected at rank 3';
        SelectedSettingRec = SettingRec;
        Rank2SettingRec = SettingRec; -- Permissions pass up for the purpose of writing to the temp table.
      END IF;
    END IF;
  END LOOP;
  IF FoundSomething AND NOT (InvisibleAtRank2 OR InvisibleAtRank0) THEN
    IF ThisUserPermission != 0 THEN
      RAISE NOTICE 'Writing Final setting % at rank 2 or 3 for course %',SelectedSettingRec."Name",SelectedSettingRec."CourseID";
      Count = Count + 1;
      INSERT INTO "UserSettingResults" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type")
        VALUES (SelectedSettingRec."Rank",SelectedSettingRec."UserID",SelectedSettingRec."CourseID",SelectedSettingRec."Name",SelectedSettingRec."Value",SelectedSettingRec."Permission",SelectedSettingRec."Visibility",SelectedSettingRec."Type");
    END IF;
    IF SelectedSettingRec."Rank" > 1 AND NOT (Rank0SettingRec IS NULL) THEN 
      -- Write the default that applies outside of the courses.
      RAISE NOTICE 'Writing final Rank 0 settings';
      Count = Count + 1;
      INSERT INTO "UserSettingResults" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type")
        VALUES (Rank0SettingRec."Rank",Rank0SettingRec."UserID",Rank0SettingRec."CourseID",Rank0SettingRec."Name",Rank0SettingRec."Value",Rank0SettingRec."Permission",Rank0SettingRec."Visibility",Rank0SettingRec."Type");
    END IF;
  END IF;

  SELECT jsonb_agg(r) INTO Result FROM "UserSettingResults" r;
  DROP TABLE "UserSettingResults";

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('Count',Count,'Settings',Result);
END;$$;
 E   DROP FUNCTION public.get_user_settings("inToken" character varying);
       public       postgres    false    4    1            �	           0    0 7   FUNCTION get_user_settings("inToken" character varying)    ACL     Z   GRANT ALL ON FUNCTION public.get_user_settings("inToken" character varying) TO oahu_user;
            public       postgres    false    362            2           1255    20253 1   get_usergroup_members(character varying, integer)    FUNCTION     9  CREATE FUNCTION public.get_usergroup_members("inToken" character varying, "inGroupID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  GroupInfo record;
  Result jsonb;
  IsMember boolean;
  Count integer;
BEGIN
  -- check if group exists
  SELECT * into GroupInfo FROM "UserGroups" WHERE "ID" = "inGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This group ID does not exist."}');
  END IF;

  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;    
  Permissions = db_get_permission(GroupInfo."CourseID",CurrentUserID);

  -- Check if user is in the group
  IsMember = FALSE;
  IF EXISTS (SELECT 1 FROM "UserGroupMembers" WHERE "UserID" = CurrentUserID AND "GroupID" = GroupInfo."ID") THEN
    IsMember = TRUE;
  END IF;

  IF NOT ((GroupInfo."Visibility" = 1) OR
          (GroupInfo."Visibility" = 2 AND Permissions > 0) OR
          (GroupInfo."Visibility" = 3 AND IsMember) OR
          (GroupInfo."Visibility" = 4 AND IsMember)) THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to access this group."}');
  END IF;

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "UserGroupMembers"."UserID","Users"."LoginName","Users"."FirstName", "Users"."LastName"
  FROM "UserGroupMembers"
  INNER JOIN "Users" ON "UserGroupMembers"."UserID" = "Users"."ID"
  WHERE "UserGroupMembers"."GroupID" = "inGroupID") r;  

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;

  --RETURN jsonb_build_object('Count',Count,'UserGroupMembers',Result);
END;$$;
 ^   DROP FUNCTION public.get_usergroup_members("inToken" character varying, "inGroupID" integer);
       public       postgres    false    1    4            �	           0    0 P   FUNCTION get_usergroup_members("inToken" character varying, "inGroupID" integer)    ACL     s   GRANT ALL ON FUNCTION public.get_usergroup_members("inToken" character varying, "inGroupID" integer) TO oahu_user;
            public       postgres    false    306            l           1255    20254 :   get_usergroup_threads(character varying, integer, integer)    FUNCTION       CREATE FUNCTION public.get_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN get_limited_usergroup_threads("inToken","inCourseID","inUserGroupID",0,0);

END;$$;
 x   DROP FUNCTION public.get_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer);
       public       postgres    false    4    1            �	           0    0 j   FUNCTION get_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer)    ACL     �   GRANT ALL ON FUNCTION public.get_usergroup_threads("inToken" character varying, "inCourseID" integer, "inUserGroupID" integer) TO oahu_user;
            public       postgres    false    364            3           1255    20255 /   get_users_in_course(character varying, integer)    FUNCTION     T  CREATE FUNCTION public.get_users_in_course("inToken" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  Result jsonb;
  UserID integer;
  Count integer;
  Permissions integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The CourseID is not valid."}');
  END IF;

  UserID = db_get_user_id_from_session("inToken");
  IF UserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

  Permissions = db_get_permission("inCourseID",UserID);
  IF Permissions < 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "You must be a member of the course to see other members."}');
  END IF;

  SELECT jsonb_agg(r) INTO Result FROM
(SELECT "Users"."ID","Users"."LoginName","Users"."FirstName","Users"."LastName",db_get_user_type("CourseMembers"."UserType") AS "UserType"
   FROM "Users" 
   INNER JOIN "CourseMembers" ON "CourseMembers"."UserID" = "Users"."ID" 
   WHERE "CourseMembers"."CourseID" = "inCourseID") r;

  SELECT count(*) INTO Count FROM jsonb_array_elements(Result);

  IF Count = 0 THEN
    RETURN ('{"Count" : "0"}');
  ELSE
    RETURN Result;
  END IF;
  --RETURN jsonb_build_object('Count',Count,'CourseMembers',Result);

END;$$;
 ]   DROP FUNCTION public.get_users_in_course("inToken" character varying, "inCourseID" integer);
       public       postgres    false    4    1            �	           0    0 O   FUNCTION get_users_in_course("inToken" character varying, "inCourseID" integer)    ACL     r   GRANT ALL ON FUNCTION public.get_users_in_course("inToken" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    307            �	           0    0 !   FUNCTION hmac(bytea, bytea, text)    ACL     D   GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO oahu_user;
            public       postgres    false    323            �	           0    0    FUNCTION hmac(text, text, text)    ACL     B   GRANT ALL ON FUNCTION public.hmac(text, text, text) TO oahu_user;
            public       postgres    false    322            4           1255    20256 k   init_userOld(character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public."init_userOld"("inToken" character varying, "inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmailAddr" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$-- this function both updates user information an logs the user in.
DECLARE
  UserData RECORD;
  thisUserID integer;
  AddUserRetVal json;
  FirstUser boolean;
  userIDcurrval integer;
BEGIN

  FirstUser = FALSE;
  SELECT * INTO UserData FROM "Users" WHERE "LoginName" = "inLoginName";
  IF FOUND THEN
    -- Database already includes user
    IF UserData."FirstLogin" = FALSE THEN
      RETURN ('{"ErrNo" : "6", "Description" : "User is already initialized."}');
    END IF;
    thisUserID = UserData."ID";
  ELSE
    -- Database does not include user so add him or her first.
    -- check if the is the first and only user
    userIDcurrval = nextval('"User_ID_seq"'::regclass);
    IF userIDcurrval = 2 THEN
      FirstUser = TRUE;
    END IF;
    AddUserRetVal = db_add_user("inLoginName");
    IF db_get_err_no(AddUserRetVal) != 0 THEN
      RETURN AddUserRetVal;
    ELSE
      thisUserID = db_get_user_id("inLoginName");
    END IF;
  END IF;

  -- User should exist at this point so update information
  UPDATE "Users" SET "FirstName" = "inFirstName","LastName" = "inLastName", 
    "EmailAddr" = "inEmailAddr", "FirstLogin" = FALSE, "IsAdmin" = FirstUser WHERE "ID" = thisUserID;
  INSERT INTO "Sessions" ("Ticket","UserLoginName","StartTime","LastUpdate","UserID")
     VALUES ("inToken","inLoginName",NOW(),NOW(),thisUserID);
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public."init_userOld"("inToken" character varying, "inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmailAddr" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION "init_userOld"("inToken" character varying, "inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmailAddr" character varying)    ACL     �   GRANT ALL ON FUNCTION public."init_userOld"("inToken" character varying, "inLoginName" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmailAddr" character varying) TO oahu_user;
            public       postgres    false    308            5           1255    20257 �   local_login_create_user(character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION     x  CREATE FUNCTION public.local_login_create_user("inUserName" character varying, "inPassword" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inValidationKey" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  PasswordHash character varying;
BEGIN
  -- check if the username already exists
  IF EXISTS (SELECT 1 FROM "LocalLogin" WHERE "UserName" = "inUserName") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Username is already in use."}');
  END IF;

  IF "inUserName" = '' OR "inUserName" IS null THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Username is a required field"}');
  END IF;  

  IF "inFirstName" = '' OR "inFirstName" IS null THEN
    RETURN ('{"ErrNo" : "3", "Description" : "FirstName is a required field"}');
  END IF;  

  IF "inLastName" = '' OR "inLastName" IS null THEN
    RETURN ('{"ErrNo" : "4", "Description" : "LastName is a required field"}');
  END IF;  

  IF "inEmail" = '' OR "inEmail" IS null THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Email address is a required field"}');
  END IF;  

  IF "inValidationKey" = '' OR "inValidationKey" IS NULL THEN
    RETURN ('{"ErrNo" : "6", "Description" : "The validationkey cannot be empty."}');
  END IF;

  PasswordHash = crypt('inPassword',gen_salt('bf',8));

  INSERT INTO "LocalLogin" ("UserName","Password","Email","FirstName","LastName","Created","ValidationKey") 
      VALUES ("inUserName",PasswordHash,"inEmail","inFirstName","inLastName",NOW(),"inValidationKey");

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.local_login_create_user("inUserName" character varying, "inPassword" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inValidationKey" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION local_login_create_user("inUserName" character varying, "inPassword" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inValidationKey" character varying)    ACL       GRANT ALL ON FUNCTION public.local_login_create_user("inUserName" character varying, "inPassword" character varying, "inFirstName" character varying, "inLastName" character varying, "inEmail" character varying, "inValidationKey" character varying) TO oahu_user;
            public       postgres    false    309            �            1255    20258 M   local_login_get_user(character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.local_login_get_user("inSessionKey" character varying, "inUserName" character varying, "inPassword" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserResult record;

  PasswordHash character varying;
BEGIN
  SELECT * INTO UserResult FROM "LocalLogin" WHERE "UserName" = "inUserName";

  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Username or password are invalid."}');
  END IF;

  --PasswordHash = crypt('inPassword',gen_salt('bf',8));
  PasswordHash = crypt('inPassword',UserResult."Password");

  IF UserResult."Password" != PasswordHash THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Username or password are invalid."}');
  END IF;

  IF UserResult."ValidationKey" IS NOT NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User has not been validated."}');
  END IF;

  RETURN db_login("inSessionKey","inUserName",1);

END;$$;
 �   DROP FUNCTION public.local_login_get_user("inSessionKey" character varying, "inUserName" character varying, "inPassword" character varying);
       public       postgres    false    4    1            �	           0    0    FUNCTION local_login_get_user("inSessionKey" character varying, "inUserName" character varying, "inPassword" character varying)    ACL     �   GRANT ALL ON FUNCTION public.local_login_get_user("inSessionKey" character varying, "inUserName" character varying, "inPassword" character varying) TO oahu_user;
            public       postgres    false    236            $           1255    20259 =   local_login_get_userOld(character varying, character varying)    FUNCTION     x  CREATE FUNCTION public."local_login_get_userOld"("inUserName" character varying, "inPassword" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  UserResult record;

  PasswordHash character varying;
BEGIN
  SELECT * INTO UserResult FROM "LocalLogin" WHERE "UserName" = "inUserName";

  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Username or password are invalid."}');
  END IF;

  --PasswordHash = crypt('inPassword',gen_salt('bf',8));
  PasswordHash = crypt('inPassword',UserResult."Password");

  IF UserResult."Password" != PasswordHash THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Username or password are invalid."}');
  END IF;

  IF UserResult."ValidationKey" IS NOT NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "User has not been validated."}');
  END IF;

  RETURN jsonb_agg(UserResult);

END;$$;
 p   DROP FUNCTION public."local_login_get_userOld"("inUserName" character varying, "inPassword" character varying);
       public       postgres    false    1    4            �	           0    0 b   FUNCTION "local_login_get_userOld"("inUserName" character varying, "inPassword" character varying)    ACL     �   GRANT ALL ON FUNCTION public."local_login_get_userOld"("inUserName" character varying, "inPassword" character varying) TO oahu_user;
            public       postgres    false    292            *           1255    20260 '   local_login_validate(character varying)    FUNCTION     C  CREATE FUNCTION public.local_login_validate("inValidationKey" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  LocalUser record;
BEGIN
  SELECT * INTO LocalUser FROM "LocalLogin" WHERE "ValidationKey" = "inValidationKey";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid validation key"}');
  ELSE
    UPDATE "LocalLogin" SET "ValidationKey" = NULL WHERE "ValidationKey" = "inValidationKey";
    RETURN db_init_user(LocalUser."UserName",LocalUser."FirstName",LocalUser."LastName",LocalUser."Email",1);
  END IF;

END$$;
 P   DROP FUNCTION public.local_login_validate("inValidationKey" character varying);
       public       postgres    false    4    1            �	           0    0 B   FUNCTION local_login_validate("inValidationKey" character varying)    ACL     e   GRANT ALL ON FUNCTION public.local_login_validate("inValidationKey" character varying) TO oahu_user;
            public       postgres    false    298            �            1255    20451 0   mark_message_as_read(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.mark_message_as_read("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
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

END;$$;
 _   DROP FUNCTION public.mark_message_as_read("inToken" character varying, "inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 Q   FUNCTION mark_message_as_read("inToken" character varying, "inMessageID" integer)    ACL     t   GRANT ALL ON FUNCTION public.mark_message_as_read("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    246            �            1255    20454 2   mark_message_as_unread(character varying, integer)    FUNCTION     x  CREATE FUNCTION public.mark_message_as_unread("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
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

END;$$;
 a   DROP FUNCTION public.mark_message_as_unread("inToken" character varying, "inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 S   FUNCTION mark_message_as_unread("inToken" character varying, "inMessageID" integer)    ACL     v   GRANT ALL ON FUNCTION public.mark_message_as_unread("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    242            �            1255    20453 /   mark_thread_as_read(character varying, integer)    FUNCTION     q  CREATE FUNCTION public.mark_thread_as_read("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
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
END;$$;
 ^   DROP FUNCTION public.mark_thread_as_read("inToken" character varying, "inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 P   FUNCTION mark_thread_as_read("inToken" character varying, "inMessageID" integer)    ACL     s   GRANT ALL ON FUNCTION public.mark_thread_as_read("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    248            �            1255    20455 1   mark_thread_as_unread(character varying, integer)    FUNCTION     1  CREATE FUNCTION public.mark_thread_as_unread("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
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
END;$$;
 `   DROP FUNCTION public.mark_thread_as_unread("inToken" character varying, "inMessageID" integer);
       public       postgres    false    4    1            �	           0    0 R   FUNCTION mark_thread_as_unread("inToken" character varying, "inMessageID" integer)    ACL     u   GRANT ALL ON FUNCTION public.mark_thread_as_unread("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    243            �	           0    0 >   FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)    ACL     a   GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO oahu_user;
            public       postgres    false    339            �	           0    0    FUNCTION pgp_key_id(bytea)    ACL     =   GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO oahu_user;
            public       postgres    false    335            �	           0    0 &   FUNCTION pgp_pub_decrypt(bytea, bytea)    ACL     I   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO oahu_user;
            public       postgres    false    330            �	           0    0 ,   FUNCTION pgp_pub_decrypt(bytea, bytea, text)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO oahu_user;
            public       postgres    false    332            �	           0    0 2   FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO oahu_user;
            public       postgres    false    261            �	           0    0 ,   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO oahu_user;
            public       postgres    false    331            �	           0    0 2   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO oahu_user;
            public       postgres    false    333            �	           0    0 8   FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)    ACL     [   GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO oahu_user;
            public       postgres    false    334            �	           0    0 %   FUNCTION pgp_pub_encrypt(text, bytea)    ACL     H   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO oahu_user;
            public       postgres    false    268            �	           0    0 +   FUNCTION pgp_pub_encrypt(text, bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO oahu_user;
            public       postgres    false    328            �	           0    0 ,   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)    ACL     O   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO oahu_user;
            public       postgres    false    269            �	           0    0 2   FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)    ACL     U   GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO oahu_user;
            public       postgres    false    329            �	           0    0 %   FUNCTION pgp_sym_decrypt(bytea, text)    ACL     H   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO oahu_user;
            public       postgres    false    264            �	           0    0 +   FUNCTION pgp_sym_decrypt(bytea, text, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO oahu_user;
            public       postgres    false    266            �	           0    0 +   FUNCTION pgp_sym_decrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO oahu_user;
            public       postgres    false    265            �	           0    0 1   FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO oahu_user;
            public       postgres    false    267            �	           0    0 $   FUNCTION pgp_sym_encrypt(text, text)    ACL     G   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO oahu_user;
            public       postgres    false    259            �	           0    0 *   FUNCTION pgp_sym_encrypt(text, text, text)    ACL     M   GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO oahu_user;
            public       postgres    false    262            �	           0    0 +   FUNCTION pgp_sym_encrypt_bytea(bytea, text)    ACL     N   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO oahu_user;
            public       postgres    false    260            �	           0    0 1   FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)    ACL     T   GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO oahu_user;
            public       postgres    false    263            6           1255    20261 9   remove_message_from_usergroup(character varying, integer)    FUNCTION     2	  CREATE FUNCTION public.remove_message_from_usergroup("inToken" character varying, "inMessageID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  GroupPermissions integer;
  UserPermissions integer;
  UserGroupRec record;
  MessageRec record;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;    

  SELECT * INTO MessageRec FROM "Messages" WHERE "ID" = "inMessageID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This MessageID is not valid."}');
  END IF;
  
  -- Only thread messages can be moved.  It gets too messy trying to move a message in the middle of a thread.
  -- if you need that add the message to the other usergroups messagegroup which is permitted.
  IF MessageRec."ParentID" IS NOT NULL THEN
    -- This is not a message thread post.
    RETURN ('{"ErrNo" : "4", "Description" : "Message must be a thread message to be moved."}');
  END IF;

  IF MessageRec."UserGroupID" IS NULL THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Message is not a group member."}');
  END IF;

  -- Who can do this?  system admins, instructors, TAs, and message owners if they have write permission on the group

  UserPermissions = db_get_permission(MessageRec."CourseID",CurrentUserID);
  GroupPermissions = db_get_group_permissions(MessageRec."UserGroupID",CurrentUserID);
  IF UserPermissions < 2 THEN
    -- If UserPermissions >=2 We are a system admin, instructor, or TA so we are allowed to do this.  
    -- However, if Userpermissions < 2 then further tests are required

    -- Does user own the message?
    IF MessageRec."UserID" != CurrentUserID THEN
      RETURN ('{"ErrNo" : "5", "Description" : "Permission denied.  User is not responsible for this message."}');
    END IF;

    -- Does the user have read permission in the group
    IF GroupPermissions = 2 THEN
      --User is write only in this group
      RETURN ('{"ErrNo" : "6", "Description" : "Permission denied.  User is read only in this group."}');
    END IF;
  END IF;

  UPDATE "Messages" SET "UserGroupID" = NULL WHERE "Messages"."ID" = "inMessageID";

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 h   DROP FUNCTION public.remove_message_from_usergroup("inToken" character varying, "inMessageID" integer);
       public       postgres    false    1    4            �	           0    0 Z   FUNCTION remove_message_from_usergroup("inToken" character varying, "inMessageID" integer)    ACL     }   GRANT ALL ON FUNCTION public.remove_message_from_usergroup("inToken" character varying, "inMessageID" integer) TO oahu_user;
            public       postgres    false    310            7           1255    20262 (   search_messages(character varying, json)    FUNCTION     �   CREATE FUNCTION public.search_messages("inToken" character varying, "inCriteria" json) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN get_limited_search("inToken","inCriteria",0,0);
END;$$;
 V   DROP FUNCTION public.search_messages("inToken" character varying, "inCriteria" json);
       public       postgres    false    4    1            �	           0    0 H   FUNCTION search_messages("inToken" character varying, "inCriteria" json)    ACL     k   GRANT ALL ON FUNCTION public.search_messages("inToken" character varying, "inCriteria" json) TO oahu_user;
            public       postgres    false    311            8           1255    20263 B   self_enroll_student(character varying, character varying, integer)    FUNCTION     x  CREATE FUNCTION public.self_enroll_student("inToken" character varying, "inStudentEnrollKey" character varying, "inCourseID" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  CurrCourse record;
BEGIN
  -- check if session is valid
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- check if course exists
  SELECT * INTO CurrCourse FROM "Courses" WHERE "ID" = "inCourseID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "2", "Description" : "The CourseID is not valid."}');
  END IF;

  -- check if the course is active
  IF NOT (NOW() > CurrCourse."StartDate" AND NOW() < CurrCourse."EndDate") THEN
    RETURN ('{"ErrNo" : "3", "Description" : "The course is not currently active."}');
  END IF;

  -- Check if the user has already been added to the class
  IF EXISTS (SELECT 1 FROM "CourseMembers" WHERE "UserID"= CurrentUserID AND "CourseID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "The student is already added to the course."}');
  END IF;

  -- Check if the key is correct for the class
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID" AND "SetupKey" = "inStudentEnrollKey") THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Self Enrollment key is invalid."}');
  END IF;

  -- The inputs should be valid at this point so insert user
  INSERT INTO "CourseMembers" ("UserID","CourseID","UserType") 
    VALUES (CurrentUserID,"inCourseID", 1);
  RETURN concat('{"ErrNo" : "0", "Description" : "Success", "UserID": "', CurrentUserID, '"}');

END;$$;
 �   DROP FUNCTION public.self_enroll_student("inToken" character varying, "inStudentEnrollKey" character varying, "inCourseID" integer);
       public       postgres    false    4    1            �	           0    0 w   FUNCTION self_enroll_student("inToken" character varying, "inStudentEnrollKey" character varying, "inCourseID" integer)    ACL     �   GRANT ALL ON FUNCTION public.self_enroll_student("inToken" character varying, "inStudentEnrollKey" character varying, "inCourseID" integer) TO oahu_user;
            public       postgres    false    312            9           1255    20264 n   set_course_default_setting(character varying, integer, character varying, character varying, integer, integer)    FUNCTION     �  CREATE FUNCTION public.set_course_default_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN set_course_default_tsetting("inToken","inCourseID","inSettingName","inSettingValue","inPermission","inVisibility",NULL);
END;$$;
 �   DROP FUNCTION public.set_course_default_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION set_course_default_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_course_default_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer) TO oahu_user;
            public       postgres    false    313            :           1255    20265 x   set_course_default_tsetting(character varying, integer, character varying, character varying, integer, integer, integer)    FUNCTION     3  CREATE FUNCTION public.set_course_default_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  SettingRank0Rec record;
  CurrentUserSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;
  
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

 CurrentUserSchool = db_get_school(CurrentUserID);
 
  -- must be an admin, instructor, or ta to create course_default_settings.
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 2  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to alter this course."}');
  END IF;

  -- must have better permissions than the system_default settings to write.
  SELECT * INTO SettingRank0Rec FROM "Settings" WHERE "Name" = "inSettingName" AND "Rank" = 0;
  IF FOUND THEN
    IF SettingRank0Rec."Permission" > Permissions THEN
      RETURN ('{"ErrNo" : "4", "Description" : "User does not have sufficient permission to alter this setting."}');
    END IF;
  END IF;


  -- Check if setting name is empty
  IF "inSettingName" = '' OR "inSettingName" IS NULL THEN
    RETURN ('{"ErrNo" : "5", "Description" : "Setting Name cannot be an empty field."}');
  END IF;

  -- check if setting value is empty
  IF "inSettingValue" = '' OR "inSettingValue" IS NULL THEN
    RETURN ('{"ErrNo" : "6", "Description" : "Setting Value cannot be an empty field."}');
  END IF;

  -- check if inPermission is valid
  IF NOT ("inPermission" = 999 OR ("inPermission">=1 AND "inPermission" <=3) ) THEN
    RETURN ('{"ErrNo" : "7", "Description" : "New permission is not valid."}');
  END IF;

  -- check if inVisibility is valid
  IF NOT ("inVisibility" = 999 OR ("inVisibility">=1 AND "inVisibility" <=3) ) THEN
    RETURN ('{"ErrNo" : "8", "Description" : "New visibility is not valid."}');
  END IF;


  -- Make sure I am not setting a higher permission level than I can write
  IF "inPermission" > Permissions THEN
    RETURN ('{"ErrNo" : "9", "Description" : "Cannot set permission requirements higher than your own."}');
  END IF;    

  -- Make sure visibility is <= permission
  IF "inVisibility" > "inPermission" THEN
    RETURN ('{"ErrNo" : "7", "Description" : "Cannot set visibility requirements higher than permission."}');
  END IF;  

  -- Check if course_default level setting already exists
  IF EXISTS (SELECT 1 FROM "Settings" WHERE "CourseID" = "inCourseID" AND "Name" = "inSettingName" AND "Rank" = 2) THEN
    -- This setting already exists.
    UPDATE "Settings" SET "Value" = "inSettingValue", "Permission" = "inPermission", "Visibility" = "inVisibility" 
      WHERE "CourseID" = "inCourseID" AND "Name" = "inSettingName" AND "Rank" = 2;
  ELSE
    -- It does not currently exist so create a new one
    INSERT INTO "Settings" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type","School")
      VALUES (2,null,"inCourseID","inSettingName","inSettingValue","inPermission","inVisibility","inType",CurrentUserSchool);
  END IF;    

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.set_course_default_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION set_course_default_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer)    ACL       GRANT ALL ON FUNCTION public.set_course_default_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) TO oahu_user;
            public       postgres    false    314            ;           1255    20266 C   set_group_member_type(character varying, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.set_group_member_type("inToken" character varying, "inGroupID" integer, "inUserID" integer, "inNewType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  GroupPermissions integer;
  UserGroupRec record;
BEGIN
  -- check if session is valid
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  --Check if GroupID is valid
  SELECT * INTO UserGroupRec FROM "UserGroups" WHERE "ID" = "inGroupID";
  IF NOT FOUND THEN
    RETURN ('{"ErrNo" : "1", "Description" : "This GroupID is not valid."}');
  END IF;  

   -- check if current user is an admin for the group.
  GroupPermissions = db_get_group_permissions(UserGroupRec."ID",CurrentUserID);
  RAISE NOTICE 'UserID:%  GroupID:%  GroupPermissions: %',CurrentUserID,UserGroupRec."ID",GroupPermissions;
  IF GroupPermissions != 1  THEN
    RETURN ('{"ErrNo" : "3", "Description" : "This user does not have permission to set member type."}');
  END IF;   

  --Check if userID is in group
  IF NOT EXISTS (SELECT 1 FROM "UserGroupMembers" WHERE "UserID" = "inUserID" AND "GroupID" = "inGroupID") THEN
    RETURN ('{"ErrNo" : "4", "Description" : "User is not in this group."}');
  END IF;  

  -- check if usertype is valid
  IF "inNewType" < 1 OR "inNewType" > 4 THEN
    RETURN ('{"ErrNo" : "6", "Description" : "User type is invalid."}');
  END IF;

  UPDATE "UserGroupMembers" SET "UserType" = "inNewType" WHERE "UserID" = "inUserID" AND "GroupID" = "inGroupID";
  
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.set_group_member_type("inToken" character varying, "inGroupID" integer, "inUserID" integer, "inNewType" integer);
       public       postgres    false    4    1            �	           0    0 y   FUNCTION set_group_member_type("inToken" character varying, "inGroupID" integer, "inUserID" integer, "inNewType" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_group_member_type("inToken" character varying, "inGroupID" integer, "inUserID" integer, "inNewType" integer) TO oahu_user;
            public       postgres    false    315            <           1255    20267 n   set_school_default_setting(character varying, character varying, character varying, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.set_school_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE	
  ThisSchool integer;
BEGIN
  ThisSchool = db_get_school(db_get_user_id_from_session("inToken"));
  RETURN db_set_global_setting("inToken","inSettingName","inSettingValue","inPermission","inVisibility","inType",ThisSchool);
END;$$;
 �   DROP FUNCTION public.set_school_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION set_school_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_school_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) TO oahu_user;
            public       postgres    false    316            �            1255    20268 e   set_system_default_setting(character varying, character varying, character varying, integer, integer)    FUNCTION     u  CREATE FUNCTION public.set_system_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN db_set_global_setting("inToken","inSettingName","inSettingValue","inPermission","inVisibility",NULL,NULL);
END;$$;
 �   DROP FUNCTION public.set_system_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION set_system_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_system_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer) TO oahu_user;
            public       postgres    false    237            �            1255    20269 o   set_system_default_tsetting(character varying, character varying, character varying, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.set_system_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN db_set_global_setting("inToken","inSettingName","inSettingValue","inPermission","inVisibility","inType",NULL);
END;$$;
 �   DROP FUNCTION public.set_system_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION set_system_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_system_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inPermission" integer, "inVisibility" integer, "inType" integer) TO oahu_user;
            public       postgres    false    238            �            1255    20270 Q   set_user_default_setting(character varying, character varying, character varying)    FUNCTION     $  CREATE FUNCTION public.set_user_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN set_user_default_tsetting("inToken","inSettingName","inSettingValue",NULL);
END;$$;
 �   DROP FUNCTION public.set_user_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION set_user_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying)    ACL     �   GRANT ALL ON FUNCTION public.set_user_default_setting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying) TO oahu_user;
            public       postgres    false    239            �            1255    20271 [   set_user_default_tsetting(character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.set_user_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  CurrentUserSchool integer;
  Permissions integer;
  SettingRank0Rec record;
BEGIN
  
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  CurrentUserSchool = db_get_school(CurrentUserID);
  
  -- Check if setting name is empty
  IF "inSettingName" = '' OR "inSettingName" IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Setting Name cannot be an empty field."}');
  END IF;

  -- check if setting value is empty
  IF "inSettingValue" = '' OR "inSettingValue" IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "Setting Value cannot be an empty field."}');
  END IF;

  SELECT * INTO SettingRank0Rec FROM "Settings" WHERE "Name" = "inSettingName" AND "Rank" = 0;

  IF FOUND THEN
    IF SettingRank0Rec."Permission" > 1 AND NOT db_is_admin(CurrentUserID) THEN
      RETURN ('{"ErrNo" : "4", "Description" : "User does not have sufficient permission to alter this setting."}');
    END IF;
  END IF;

  -- Check if setting exists
  IF EXISTS (SELECT 1 FROM "Settings" WHERE "UserID" = CurrentUserID AND "Name" = "inSettingName" AND "Rank" = 1) THEN
    -- This setting already exists.
    UPDATE "Settings" SET "Value" = "inSettingValue" 
      WHERE "UserID" = CurrentUserID AND "Name" = "inSettingName" AND "Rank" = 1;
  ELSE
    -- It does not currently exist so create a new one
    INSERT INTO "Settings" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type","School")
      VALUES (1,CurrentUserID,NULL,"inSettingName","inSettingValue",1,1,"inType",CurrentUserSchool);
  END IF;
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.set_user_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION set_user_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_user_default_tsetting("inToken" character varying, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer) TO oahu_user;
            public       postgres    false    240            �            1255    20272 R   set_user_setting(character varying, integer, character varying, character varying)    FUNCTION     7  CREATE FUNCTION public.set_user_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN set_user_tsetting("inToken","inCourseID","inSettingName","inSettingValue",NULL);
END;$$;
 �   DROP FUNCTION public.set_user_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION set_user_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying)    ACL     �   GRANT ALL ON FUNCTION public.set_user_setting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying) TO oahu_user;
            public       postgres    false    241            u           1255    20273 \   set_user_tsetting(character varying, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.set_user_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
  CurrentUserID integer;
  Permissions integer;
  SettingRank0Rec record;
  SettingRank2Rec record;
  CurrentUserSchool integer;
BEGIN
  -- check if course exists
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "1", "Description" : "The ClassID is not valid."}');
  END IF;
    
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Invalid Session."}');
  END IF;

 CurrentUserSchool = db_get_school(CurrentUserID);

  -- get user permissions
  Permissions = db_get_permission("inCourseID",CurrentUserID);

  -- Check if setting name is empty
  IF "inSettingName" = '' OR "inSettingName" IS NULL THEN
    RETURN ('{"ErrNo" : "3", "Description" : "Setting Name cannot be an empty field."}');
  END IF;

  -- check if setting value is empty
  IF "inSettingValue" = '' OR "inSettingValue" IS NULL THEN
    RETURN ('{"ErrNo" : "4", "Description" : "Setting Value cannot be an empty field."}');
  END IF;

  -- must have better permissions than the system_default settings to write.
  SELECT * INTO SettingRank0Rec FROM "Settings" WHERE "Name" = "inSettingName" AND "Rank" = 0;
  IF FOUND THEN
    IF SettingRank0Rec."Permission" = 999 AND NOT db_is_admin(CurrentUserID) THEN
      RETURN ('{"ErrNo" : "5", "Description" : "User does not have sufficient permission to alter this setting."}');
    END IF;
  END IF;

  -- must have better permissions than the course_default required permissions to write.
  SELECT * INTO SettingRank2Rec FROM "Settings" WHERE "Name" = "inSettingName" AND "Rank" = 2;
  IF FOUND THEN
    IF SettingRank2Rec."Permission" > Permissions THEN
      RETURN ('{"ErrNo" : "6", "Description" : "User does not have sufficient permission to alter this setting."}');
    END IF;
  END IF;

  -- User must have permission and values are valid so write the setting.
  -- Check if setting exists
  IF EXISTS (SELECT 1 FROM "Settings" WHERE "UserID" = CurrentUserID AND "CourseID" = "inCourseID" AND "Name" = "inSettingName" AND "Rank" = 3) THEN
    -- This setting already exists.
    UPDATE "Settings" SET "Value" = "inSettingValue" 
      WHERE "UserID" = CurrentUserID AND "CourseID" = "inCourseID" AND "Name" = "inSettingName" AND "Rank" = 3;
  ELSE
    -- It does not currently exist so create a new one
    INSERT INTO "Settings" ("Rank","UserID","CourseID","Name","Value","Permission","Visibility","Type","School")
      VALUES (3,CurrentUserID,"inCourseID","inSettingName","inSettingValue",NULL,NULL,"inType",CurrentUserSchool);
  END IF;
  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
  
END;$$;
 �   DROP FUNCTION public.set_user_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer);
       public       postgres    false    1    4            �	           0    0 �   FUNCTION set_user_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer)    ACL     �   GRANT ALL ON FUNCTION public.set_user_tsetting("inToken" character varying, "inCourseID" integer, "inSettingName" character varying, "inSettingValue" character varying, "inType" integer) TO oahu_user;
            public       postgres    false    373            v           1255    20274    test_clear_db()    FUNCTION     �  CREATE FUNCTION public.test_clear_db() RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN
  DELETE FROM "CourseMembers";
  DELETE FROM "Courses";
  DELETE FROM "MessageGroups";
  DELETE FROM "MessageGroupMembers";
  DELETE FROM "MessagePollItem";
  DELETE FROM "MessagePollVote";
  DELETE FROM "MessageVotes";
  DELETE FROM "Messages";
  DELETE FROM "Sessions";
  DELETE FROM "Settings";
  DELETE FROM "UserGroups";
  DELETE FROM "UserGroupMembers";
  DELETE FROM "Users";
  DELETE FROM "LocalLogin";

  PERFORM setval('"Courses_ID_seq"'::regclass,1);
  PERFORM setval('"Messages_ID_seq"'::regclass,1);
  PERFORM setval('"Groups_ID_seq"'::regclass,1);
  PERFORM setval('"MessagePollItem_ID_seq"'::regclass,1);
  PERFORM setval('"MessagePollVote_ID_seq"'::regclass,1);
  PERFORM setval('"MessageVote_ID_seq"'::regclass,1);
  PERFORM setval('"User_ID_seq"'::regclass,1);

  SELECT db_set_global_setting(NULL,'DB_SETTING_ALLOW_GROUP_CREATION','2',3,1,1,NULL);

END

    
$$;
 &   DROP FUNCTION public.test_clear_db();
       public       postgres    false    4    1            �	           0    0    FUNCTION test_clear_db()    ACL     ;   GRANT ALL ON FUNCTION public.test_clear_db() TO oahu_user;
            public       postgres    false    374            w           1255    20275 @   test_db_statement(character varying, integer, character varying)    FUNCTION     �  CREATE FUNCTION public.test_db_statement("inTestID" character varying, "inExpectedResult" integer, "inTestStatement" character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$DECLARE
  result json;
  errorNum integer;
BEGIN
  EXECUTE "inTestStatement" INTO result;
  errorNum = db_get_err_no(result);
  IF errorNum = inExpectedResult THEN
    RETURN "inTestID" || ' -> SUCCESS';
  ELSE
    RETURN "inTestID" || ' -> FAILED';
  END IF;
END;$$;
 �   DROP FUNCTION public.test_db_statement("inTestID" character varying, "inExpectedResult" integer, "inTestStatement" character varying);
       public       postgres    false    4    1            �	           0    0 y   FUNCTION test_db_statement("inTestID" character varying, "inExpectedResult" integer, "inTestStatement" character varying)    ACL     �   GRANT ALL ON FUNCTION public.test_db_statement("inTestID" character varying, "inExpectedResult" integer, "inTestStatement" character varying) TO oahu_user;
            public       postgres    false    375            �            1255    20276    test_setup_test_db()    FUNCTION     D  CREATE FUNCTION public.test_setup_test_db() RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

PERFORM test_clear_db();
PERFORM db_admin_add_admin('admin','gtdefault','brian','brian123');
PERFORM db_admin_delete_admin('brian','brian123','admin');
PERFORM db_admin_create_class('brian','brian123','CS32721','Intro to Database Testing','SECRETC0D3','2018-8-1','2018-12-15');
PERFORM db_admin_create_class('brian','brian123','CS1401','Intro to Computer Science','NEWSECRETC0D3','2018-8-1','2018-12-15');  
PERFORM db_admin_create_class('brian','brian123','CS1401','Intro to Computer Science','NEWSECRETC0D3','2017-8-1','2017-12-15');
PERFORM db_admin_add_instructor('brian','brian123','swise2',2);
PERFORM db_admin_add_ta('brian','brian123','bking18',2);
PERFORM db_admin_add_student('brian','brian123','bdavis327',2);

END;$$;
 +   DROP FUNCTION public.test_setup_test_db();
       public       postgres    false    4    1            �	           0    0    FUNCTION test_setup_test_db()    ACL     @   GRANT ALL ON FUNCTION public.test_setup_test_db() TO oahu_user;
            public       postgres    false    244            =           1255    20277    testing_setup_test_database()    FUNCTION     �  CREATE FUNCTION public.testing_setup_test_database() RETURNS json
    LANGUAGE plpgsql
    AS $$BEGIN
PERFORM test_clear_db();
PERFORM db_admin_add_admin('admin','gtdefault','brian','brian123');
PERFORM db_admin_change_password('brian','brian123','admin','test123');
PERFORM db_admin_add_admin('admin','test123','testuser','test123');
PERFORM db_admin_delete_admin('brian','brian123','testuser');
PERFORM db_admin_delete_admin('brian','brian123','admin');
PERFORM db_admin_create_course('brian','brian123','CS32721','Intro to Database Testing','SECRETC0D3','2018-8-1','2018-12-15');
PERFORM db_admin_create_course('brian','brian123','CS1401','Intro to Computer Science','NEWSECRETC0D3','2018-8-1','2018-12-15');
PERFORM db_admin_create_course('brian','brian123','CS1401','Intro to Computer Science','NEWSECRETC0D3','2017-8-1','2017-12-15');
PERFORM db_admin_add_instructor('brian','brian123','swise2',2);
PERFORM db_admin_add_ta('brian','brian123','bking18',2);
PERFORM db_admin_add_student('brian','brian123','bdavis327',2);
PERFORM init_user('weoin2340io','bdavis327','Brian','Davis','ringzero.d9@gmail.com');
PERFORM init_user('gome902pds','bking18','Brandon','King','bking18@gatech.edu');
PERFORM init_user('34tg8hdzsds','tryan3','Terrance','Ryan','tryan3@gatech.edu');
PERFORM init_user('34908haes;l','swise2','Sam','Wise','swise2@gatech.edu');
PERFORM login('weoin2340io','bdavis327');
PERFORM self_enroll_student('weoin2340io','NEWSECRETC0D3',3);
PERFORM delete_user_from_course('34908haes;l','bdavis327',2);
PERFORM delete_user_from_course('34908haes;l','bking18',2);
PERFORM add_ta_to_course('34908haes;l','bking18',2); 
PERFORM add_student_to_course('34908haes;l','bdavis327',2);




RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 4   DROP FUNCTION public.testing_setup_test_database();
       public       postgres    false    4    1            �	           0    0 &   FUNCTION testing_setup_test_database()    ACL     I   GRANT ALL ON FUNCTION public.testing_setup_test_database() TO oahu_user;
            public       postgres    false    317            �            1255    20278 d   update_course_settings(character varying, integer, character varying, character varying, date, date)    FUNCTION     �  CREATE FUNCTION public.update_course_settings("inToken" character varying, "inCourseID" integer, "inClassNumber" character varying, "inClassName" character varying, "inStartDate" date, "inEndDate" date) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
   newIndex integer;
   CurrentUserID integer;
   Permissions integer;
BEGIN
  -- Check Token
  CurrentUserID = db_get_user_id_from_session("inToken");
  IF CurrentUserID IS NULL THEN
    RETURN ('{"ErrNo" : "1", "Description" : "Invalid Session."}');
  END IF;

  -- check if current user is an admin or instructor for the course.
  Permissions = db_get_permission("inCourseID",CurrentUserID);
  IF Permissions < 2  THEN
    RETURN ('{"ErrNo" : "2", "Description" : "Only and admin or instructor can alter this course."}');
  END IF;

  -- check if inCourseID is valid
  IF NOT EXISTS (SELECT 1 FROM "Courses" WHERE "ID" = "inCourseID") THEN
    RETURN ('{"ErrNo" : "3", "Description" : "The Course ID does not exist."}');
  END IF;

  UPDATE "Courses" SET "Number" = "inClassNumber", "Name" = "inClassName", "StartDate" = "inStartDate", "EndDate" = "inEndDate"
      WHERE "ID" = "inCourseID";

  RETURN ('{"ErrNo" : "0", "Description" : "Success"}');
END;$$;
 �   DROP FUNCTION public.update_course_settings("inToken" character varying, "inCourseID" integer, "inClassNumber" character varying, "inClassName" character varying, "inStartDate" date, "inEndDate" date);
       public       postgres    false    4    1            �	           0    0 �   FUNCTION update_course_settings("inToken" character varying, "inCourseID" integer, "inClassNumber" character varying, "inClassName" character varying, "inStartDate" date, "inEndDate" date)    ACL     �   GRANT ALL ON FUNCTION public.update_course_settings("inToken" character varying, "inCourseID" integer, "inClassNumber" character varying, "inClassName" character varying, "inStartDate" date, "inEndDate" date) TO oahu_user;
            public       postgres    false    249            �            1259    20279    CourseMembers    TABLE     n   CREATE TABLE public."CourseMembers" (
    "UserID" integer,
    "CourseID" integer,
    "UserType" integer
);
 #   DROP TABLE public."CourseMembers";
       public         postgres    false    4            �	           0    0    TABLE "CourseMembers"    ACL     8   GRANT ALL ON TABLE public."CourseMembers" TO oahu_user;
            public       postgres    false    201            �            1259    20282    Courses    TABLE     �   CREATE TABLE public."Courses" (
    "ID" integer NOT NULL,
    "Number" character varying(15),
    "Name" character varying(60),
    "StartDate" date,
    "EndDate" date,
    "SetupKey" character varying(100),
    "School" integer
);
    DROP TABLE public."Courses";
       public         postgres    false    4            �	           0    0    TABLE "Courses"    ACL     2   GRANT ALL ON TABLE public."Courses" TO oahu_user;
            public       postgres    false    202            �            1259    20285    Courses_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Courses_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."Courses_ID_seq";
       public       postgres    false    4    202            �	           0    0    Courses_ID_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public."Courses_ID_seq" OWNED BY public."Courses"."ID";
            public       postgres    false    203            �	           0    0    SEQUENCE "Courses_ID_seq"    ACL     <   GRANT ALL ON SEQUENCE public."Courses_ID_seq" TO oahu_user;
            public       postgres    false    203            �            1259    20287 
   UserGroups    TABLE     �   CREATE TABLE public."UserGroups" (
    "ID" integer NOT NULL,
    "CourseID" integer,
    "GroupName" character varying(200),
    "Visibility" integer,
    "MessageGroupID" integer
);
     DROP TABLE public."UserGroups";
       public         postgres    false    4            �	           0    0    TABLE "UserGroups"    ACL     5   GRANT ALL ON TABLE public."UserGroups" TO oahu_user;
            public       postgres    false    204            �            1259    20290    Groups_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Groups_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Groups_ID_seq";
       public       postgres    false    4    204            �	           0    0    Groups_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Groups_ID_seq" OWNED BY public."UserGroups"."ID";
            public       postgres    false    205            �	           0    0    SEQUENCE "Groups_ID_seq"    ACL     ;   GRANT ALL ON SEQUENCE public."Groups_ID_seq" TO oahu_user;
            public       postgres    false    205            �            1259    20292 
   LocalLogin    TABLE       CREATE TABLE public."LocalLogin" (
    "Email" character varying,
    "FirstName" character varying,
    "LastName" character varying,
    "ValidationKey" character varying,
    "Created" timestamp with time zone,
    "UserName" character varying,
    "Password" character varying
);
     DROP TABLE public."LocalLogin";
       public         postgres    false    4            �	           0    0    TABLE "LocalLogin"    ACL     5   GRANT ALL ON TABLE public."LocalLogin" TO oahu_user;
            public       postgres    false    206            �            1259    20298    MessageGroupMembers    TABLE     w   CREATE TABLE public."MessageGroupMembers" (
    "MessageGroupID" integer NOT NULL,
    "MessageID" integer NOT NULL
);
 )   DROP TABLE public."MessageGroupMembers";
       public         postgres    false    4            �	           0    0    TABLE "MessageGroupMembers"    ACL     >   GRANT ALL ON TABLE public."MessageGroupMembers" TO oahu_user;
            public       postgres    false    207            �            1259    20301    MessageGroups    TABLE     �   CREATE TABLE public."MessageGroups" (
    "ID" integer NOT NULL,
    "CourseID" integer,
    "UserID" integer,
    "Name" character varying(200)
);
 #   DROP TABLE public."MessageGroups";
       public         postgres    false    4            �	           0    0    TABLE "MessageGroups"    ACL     8   GRANT ALL ON TABLE public."MessageGroups" TO oahu_user;
            public       postgres    false    208            �            1259    20304    MessageGroupTypes_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."MessageGroupTypes_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."MessageGroupTypes_ID_seq";
       public       postgres    false    208    4            �	           0    0    MessageGroupTypes_ID_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."MessageGroupTypes_ID_seq" OWNED BY public."MessageGroups"."ID";
            public       postgres    false    209            �	           0    0 #   SEQUENCE "MessageGroupTypes_ID_seq"    ACL     F   GRANT ALL ON SEQUENCE public."MessageGroupTypes_ID_seq" TO oahu_user;
            public       postgres    false    209            �            1259    20306    MessagePollItem    TABLE     �   CREATE TABLE public."MessagePollItem" (
    "ID" integer NOT NULL,
    "MessageID" integer,
    "Name" character varying(200)
);
 %   DROP TABLE public."MessagePollItem";
       public         postgres    false    4            �	           0    0    TABLE "MessagePollItem"    ACL     :   GRANT ALL ON TABLE public."MessagePollItem" TO oahu_user;
            public       postgres    false    210            �            1259    20309    MessagePollItem_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."MessagePollItem_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."MessagePollItem_ID_seq";
       public       postgres    false    210    4            �	           0    0    MessagePollItem_ID_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."MessagePollItem_ID_seq" OWNED BY public."MessagePollItem"."ID";
            public       postgres    false    211            �	           0    0 !   SEQUENCE "MessagePollItem_ID_seq"    ACL     D   GRANT ALL ON SEQUENCE public."MessagePollItem_ID_seq" TO oahu_user;
            public       postgres    false    211            �            1259    20311    MessagePollVote    TABLE     �   CREATE TABLE public."MessagePollVote" (
    "MessagePollItemID" integer,
    "VotingUserID" integer,
    "Value" integer,
    "ID" integer NOT NULL,
    "MessageID" integer
);
 %   DROP TABLE public."MessagePollVote";
       public         postgres    false    4             
           0    0    TABLE "MessagePollVote"    ACL     :   GRANT ALL ON TABLE public."MessagePollVote" TO oahu_user;
            public       postgres    false    212            �            1259    20314    MessagePollVote_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."MessagePollVote_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."MessagePollVote_ID_seq";
       public       postgres    false    212    4            
           0    0    MessagePollVote_ID_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."MessagePollVote_ID_seq" OWNED BY public."MessagePollVote"."ID";
            public       postgres    false    213            
           0    0 !   SEQUENCE "MessagePollVote_ID_seq"    ACL     D   GRANT ALL ON SEQUENCE public."MessagePollVote_ID_seq" TO oahu_user;
            public       postgres    false    213            �            1259    20316    MessageVotes    TABLE     �   CREATE TABLE public."MessageVotes" (
    "MessageID" integer,
    "UserID" integer,
    "Score" integer,
    "ID" integer NOT NULL
);
 "   DROP TABLE public."MessageVotes";
       public         postgres    false    4            
           0    0    TABLE "MessageVotes"    ACL     7   GRANT ALL ON TABLE public."MessageVotes" TO oahu_user;
            public       postgres    false    214            �            1259    20319    MessageVote_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."MessageVote_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public."MessageVote_ID_seq";
       public       postgres    false    214    4            
           0    0    MessageVote_ID_seq    SEQUENCE OWNED BY     P   ALTER SEQUENCE public."MessageVote_ID_seq" OWNED BY public."MessageVotes"."ID";
            public       postgres    false    215            
           0    0    SEQUENCE "MessageVote_ID_seq"    ACL     @   GRANT ALL ON SEQUENCE public."MessageVote_ID_seq" TO oahu_user;
            public       postgres    false    215            �            1259    20321    Messages    TABLE     �  CREATE TABLE public."Messages" (
    "ID" integer NOT NULL,
    "ParentID" integer,
    "CourseID" integer,
    "UserID" integer,
    "TimeCreated" timestamp with time zone,
    "Title" character varying(200),
    "Message" text,
    "hasAttachment" boolean,
    "ChildCount" integer,
    "DeletedBy" integer,
    "EditedBy" integer,
    "UserGroupID" integer,
    "LastEditedBy" character varying,
    "PollType" integer,
    "Type" text,
    "Setting" text
);
    DROP TABLE public."Messages";
       public         postgres    false    4            
           0    0    TABLE "Messages"    ACL     3   GRANT ALL ON TABLE public."Messages" TO oahu_user;
            public       postgres    false    216            �            1259    20327    Messages_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Messages_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Messages_ID_seq";
       public       postgres    false    216    4            
           0    0    Messages_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Messages_ID_seq" OWNED BY public."Messages"."ID";
            public       postgres    false    217            
           0    0    SEQUENCE "Messages_ID_seq"    ACL     =   GRANT ALL ON SEQUENCE public."Messages_ID_seq" TO oahu_user;
            public       postgres    false    217            �            1259    20329    Sessions    TABLE     �   CREATE TABLE public."Sessions" (
    "Ticket" character varying(500),
    "UserLoginName" character varying(100),
    "StartTime" timestamp with time zone,
    "LastUpdate" timestamp with time zone,
    "UserID" integer
);
    DROP TABLE public."Sessions";
       public         postgres    false    4            	
           0    0    TABLE "Sessions"    ACL     3   GRANT ALL ON TABLE public."Sessions" TO oahu_user;
            public       postgres    false    218            �            1259    20335    Settings    TABLE       CREATE TABLE public."Settings" (
    "Rank" integer NOT NULL,
    "UserID" integer,
    "CourseID" integer,
    "Name" text NOT NULL,
    "Value" text NOT NULL,
    "Permission" integer,
    "Visibility" integer,
    "Type" integer,
    "School" integer
);
    DROP TABLE public."Settings";
       public         postgres    false    4            

           0    0    TABLE "Settings"    ACL     3   GRANT ALL ON TABLE public."Settings" TO oahu_user;
            public       postgres    false    219            �            1259    20345    UserGroupMembers    TABLE     p   CREATE TABLE public."UserGroupMembers" (
    "GroupID" integer,
    "UserID" integer,
    "UserType" integer
);
 &   DROP TABLE public."UserGroupMembers";
       public         postgres    false    4            
           0    0    TABLE "UserGroupMembers"    ACL     ;   GRANT ALL ON TABLE public."UserGroupMembers" TO oahu_user;
            public       postgres    false    220            �            1259    20348    Users    TABLE     Z  CREATE TABLE public."Users" (
    "ID" integer NOT NULL,
    "LoginName" character varying(50) NOT NULL,
    "EmailAddr" character varying(254),
    "FirstName" character varying(128),
    "LastName" character varying(128),
    "FirstLogin" boolean,
    "ReadGroupID" integer,
    "Active" boolean,
    "IsAdmin" boolean,
    "School" integer
);
    DROP TABLE public."Users";
       public         postgres    false    4            
           0    0    TABLE "Users"    ACL     0   GRANT ALL ON TABLE public."Users" TO oahu_user;
            public       postgres    false    221            �            1259    20354    User_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."User_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."User_ID_seq";
       public       postgres    false    221    4            
           0    0    User_ID_seq    SEQUENCE OWNED BY     B   ALTER SEQUENCE public."User_ID_seq" OWNED BY public."Users"."ID";
            public       postgres    false    222            
           0    0    SEQUENCE "User_ID_seq"    ACL     9   GRANT ALL ON SEQUENCE public."User_ID_seq" TO oahu_user;
            public       postgres    false    222            �           2604    20356 
   Courses ID    DEFAULT     n   ALTER TABLE ONLY public."Courses" ALTER COLUMN "ID" SET DEFAULT nextval('public."Courses_ID_seq"'::regclass);
 =   ALTER TABLE public."Courses" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    203    202            �           2604    20357    MessageGroups ID    DEFAULT     ~   ALTER TABLE ONLY public."MessageGroups" ALTER COLUMN "ID" SET DEFAULT nextval('public."MessageGroupTypes_ID_seq"'::regclass);
 C   ALTER TABLE public."MessageGroups" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    209    208            �           2604    20358    MessagePollItem ID    DEFAULT     ~   ALTER TABLE ONLY public."MessagePollItem" ALTER COLUMN "ID" SET DEFAULT nextval('public."MessagePollItem_ID_seq"'::regclass);
 E   ALTER TABLE public."MessagePollItem" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    211    210            �           2604    20359    MessagePollVote ID    DEFAULT     ~   ALTER TABLE ONLY public."MessagePollVote" ALTER COLUMN "ID" SET DEFAULT nextval('public."MessagePollVote_ID_seq"'::regclass);
 E   ALTER TABLE public."MessagePollVote" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    213    212            �           2604    20360    MessageVotes ID    DEFAULT     w   ALTER TABLE ONLY public."MessageVotes" ALTER COLUMN "ID" SET DEFAULT nextval('public."MessageVote_ID_seq"'::regclass);
 B   ALTER TABLE public."MessageVotes" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    215    214            �           2604    20361    Messages ID    DEFAULT     p   ALTER TABLE ONLY public."Messages" ALTER COLUMN "ID" SET DEFAULT nextval('public."Messages_ID_seq"'::regclass);
 >   ALTER TABLE public."Messages" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    217    216            �           2604    20362    UserGroups ID    DEFAULT     p   ALTER TABLE ONLY public."UserGroups" ALTER COLUMN "ID" SET DEFAULT nextval('public."Groups_ID_seq"'::regclass);
 @   ALTER TABLE public."UserGroups" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    205    204            �           2604    20363    Users ID    DEFAULT     i   ALTER TABLE ONLY public."Users" ALTER COLUMN "ID" SET DEFAULT nextval('public."User_ID_seq"'::regclass);
 ;   ALTER TABLE public."Users" ALTER COLUMN "ID" DROP DEFAULT;
       public       postgres    false    222    221            D	          0    20279    CourseMembers 
   TABLE DATA               K   COPY public."CourseMembers" ("UserID", "CourseID", "UserType") FROM stdin;
    public       postgres    false    201   ��      E	          0    20282    Courses 
   TABLE DATA               i   COPY public."Courses" ("ID", "Number", "Name", "StartDate", "EndDate", "SetupKey", "School") FROM stdin;
    public       postgres    false    202   ��      I	          0    20292 
   LocalLogin 
   TABLE DATA               |   COPY public."LocalLogin" ("Email", "FirstName", "LastName", "ValidationKey", "Created", "UserName", "Password") FROM stdin;
    public       postgres    false    206   H�      J	          0    20298    MessageGroupMembers 
   TABLE DATA               N   COPY public."MessageGroupMembers" ("MessageGroupID", "MessageID") FROM stdin;
    public       postgres    false    207   ��      K	          0    20301    MessageGroups 
   TABLE DATA               M   COPY public."MessageGroups" ("ID", "CourseID", "UserID", "Name") FROM stdin;
    public       postgres    false    208   ;�      M	          0    20306    MessagePollItem 
   TABLE DATA               F   COPY public."MessagePollItem" ("ID", "MessageID", "Name") FROM stdin;
    public       postgres    false    210   �      O	          0    20311    MessagePollVote 
   TABLE DATA               l   COPY public."MessagePollVote" ("MessagePollItemID", "VotingUserID", "Value", "ID", "MessageID") FROM stdin;
    public       postgres    false    212   7�      Q	          0    20316    MessageVotes 
   TABLE DATA               N   COPY public."MessageVotes" ("MessageID", "UserID", "Score", "ID") FROM stdin;
    public       postgres    false    214   T�      S	          0    20321    Messages 
   TABLE DATA               �   COPY public."Messages" ("ID", "ParentID", "CourseID", "UserID", "TimeCreated", "Title", "Message", "hasAttachment", "ChildCount", "DeletedBy", "EditedBy", "UserGroupID", "LastEditedBy", "PollType", "Type", "Setting") FROM stdin;
    public       postgres    false    216   q�      U	          0    20329    Sessions 
   TABLE DATA               d   COPY public."Sessions" ("Ticket", "UserLoginName", "StartTime", "LastUpdate", "UserID") FROM stdin;
    public       postgres    false    218   ��      V	          0    20335    Settings 
   TABLE DATA               �   COPY public."Settings" ("Rank", "UserID", "CourseID", "Name", "Value", "Permission", "Visibility", "Type", "School") FROM stdin;
    public       postgres    false    219   /�      W	          0    20345    UserGroupMembers 
   TABLE DATA               M   COPY public."UserGroupMembers" ("GroupID", "UserID", "UserType") FROM stdin;
    public       postgres    false    220   y�      G	          0    20287 
   UserGroups 
   TABLE DATA               e   COPY public."UserGroups" ("ID", "CourseID", "GroupName", "Visibility", "MessageGroupID") FROM stdin;
    public       postgres    false    204   ��      X	          0    20348    Users 
   TABLE DATA               �   COPY public."Users" ("ID", "LoginName", "EmailAddr", "FirstName", "LastName", "FirstLogin", "ReadGroupID", "Active", "IsAdmin", "School") FROM stdin;
    public       postgres    false    221   �      
           0    0    Courses_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Courses_ID_seq"', 5, true);
            public       postgres    false    203            
           0    0    Groups_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Groups_ID_seq"', 19, true);
            public       postgres    false    205            
           0    0    MessageGroupTypes_ID_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public."MessageGroupTypes_ID_seq"', 137, true);
            public       postgres    false    209            
           0    0    MessagePollItem_ID_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."MessagePollItem_ID_seq"', 1, true);
            public       postgres    false    211            
           0    0    MessagePollVote_ID_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."MessagePollVote_ID_seq"', 1, true);
            public       postgres    false    213            
           0    0    MessageVote_ID_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public."MessageVote_ID_seq"', 1, true);
            public       postgres    false    215            
           0    0    Messages_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Messages_ID_seq"', 27, true);
            public       postgres    false    217            
           0    0    User_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."User_ID_seq"', 21, true);
            public       postgres    false    222            �           2606    20365 ,   MessageGroupMembers MessageGroupMembers_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."MessageGroupMembers"
    ADD CONSTRAINT "MessageGroupMembers_pkey" PRIMARY KEY ("MessageGroupID", "MessageID");
 Z   ALTER TABLE ONLY public."MessageGroupMembers" DROP CONSTRAINT "MessageGroupMembers_pkey";
       public         postgres    false    207    207            D	   <   x�%��  ��tO@wq�9D�i�L1q���Q��(4
M�Vʟ�,��&��Op�n      E	   d   x�3�tV0420���+)�W(�Wp�420��5��5��0�@L�`���Ԓ҂��JNC.c�f#�
F��"i7�������������S�Pw� ��;�      I	   �  x�u�˒�0�>�,zۘ��P�xC�j6#��� ����8�\ʞ��N%������S���O���=�d���ԛ�뽯^H_!|E�UT����W@z�_�_{�S�܃��3��Φ۴Cau��88�]�yr�f�fa�Qy�nG������ֽЃ��DE��	�C��8�g�����q8j�!<�ǰ6ʈ:%A�g�I�R���}�}��6z�ѳM��� 
��٨��+:�d�2�5xK��.87h֎��'��r�h5�Mu�ݍ�UE��_]��?����snY@�D��B���`g;a�w��Y���n�;-8DJ��4w��d�,��D��g�3h5���ѓ��[V��CI�����۪����D�I�Q��2�	��*���a��;���5=x��g[|��g[�Ur�YR��;{�q�[;ml|�x��`�Z})����Ɲ�j��V#����]��Ɵ�T� c����c}Z.�w��n�L;k�/�hdR>��tg�����l�b�"�^?k6�(
��2|���߭'�&N74��6|�po�٭����8���V�Z�r�c?�b̍���$�xy��[Z��($��>�;�vͪ?o@�@�� �<���]#�ɷ�X�)������ ��O�{�pY��qp5���A t?.~���W����J      J	   .   x�344�4�2�&`Ҙ��؄��1���
�*eh����� 2M	F      K	   �   x�}�M
� ൞"'(�7f��'��Ԑ
%)����IK�0�>oYk�p%���]ܺ4~q���n�6Y��ۺ?)k���K�C��H�(b���$�Q��
��8(�*	J���R�4�o��t���:0&��!<�e�;�2�`�����'��~}_zQ��-��{���������
���������wU/��	�G�pܼž�p�����      M	      x������ � �      O	      x������ � �      Q	      x������ � �      S	     x����N�0��sy�� Mg�5��x���B�"�.l�$��"+dע1i����$;>1d��*J$&
R
i�<�ҰC��nL�����?����9�c�D��*; ssd�P^X��W"�	��s���%��̇x9}����S�k��j���ÿy}����lP&����&t�ۮ�U{�5o�~��n�ޛ�F$a�������G���}@AF)cW�nhU�˳�%���x|o�����d��
�N�_�p��������(�O����      U	   �  x����n�0E��W�b��>��S�$��
���4�JU ��@&�6��KBU�h�H��e��6�t��$��s���x�r��QP�	�b�*�$�[s�e�" ���R���I�U�t��ܸ�Y�S�lw�	�r���e`AP�֍R��s��r�.h��8U#B�T���)Aʭ�B[ �*��4Su
����܆���
�T��tvc ��*Jfѥ����SP�4��D?⤗���у0�^z�q�S�b�4h���|���'11��y���x�F��u��y�Yr���GC\x�,	;Ag,x�e�����{���Sљw�xv�}������o����?�7�7��u~�{��ݼN�t��I6I:;N7����j�,i��>^���H˵�2@�_��'55 B��8��q�ww�      V	   :   x�3���!��`אO?�xG��x� �Ѐx� W�O?N#NcNC����� ���      W	   6   x�3�4�4�2�44S�& ���2�4�24� R�&�"
�5����� 2��      G	   C   x�3�4�I-.1L/�/-�4�442�24����'��:��$&g����AT�p�p��qqq Ee�      X	   �   x�u��
�0 �s�0ô���x���tn΢v�U>�Yӂ2d%��K�v
�Aۦ�Pߌ햝v�����֡��<\ %8zPd`���wǖ��V��^I�3+'����F�l��=P��"KM�g�ˈ�)�3�<V���p�qqN�W�{��N���n�^���j�[+b��ó������w;�IS-��6���?�d׃�6�eƩ]ŗ�!�٫�L     