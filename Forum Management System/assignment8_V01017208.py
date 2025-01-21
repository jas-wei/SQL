import psycopg2
import psycopg2.extras
from psycopg2.sql import *
import hashlib

# Todo: change these settings to match your local install of postgresql.
conn = psycopg2.connect(host="localhost", database="A8", 
                        user="postgres", password="my_super_secret_password.", port=5432)
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)


# Insert a new category.
def insert_category(category_name: str, category_description: str = ""):
    cur.execute("""INSERT INTO "Category" (
                   "CategoryName", 
                   "CategoryDescription") 
                   VALUES (%s, %s)""", (category_name, category_description))
    conn.commit()


# Insert a new user.
def insert_user(display_name: str, email: str, password: str,
                is_banned: bool = False, is_moderator: bool = False, 
                is_administrator: bool = False) -> None:
    insert_query = SQL("""
    INSERT INTO "User" (
      "DisplayName",
      "Email",
      "Password",
      "Salt",
      "IsBanned",
      "IsModerator",
      "IsAdministrator"
    ) VALUES (%s, %s, %s, '', {is_banned}, {is_moderator}, {is_administrator})""".format(
        is_banned="default" if is_banned is None else Literal(is_banned).as_string(conn),
        is_moderator="default" if is_moderator is None else Literal(is_moderator).as_string(conn),
        is_administrator="default" if is_administrator is None else Literal(is_administrator).as_string(conn)
    )).as_string(conn)

    cur.execute(insert_query, (
        display_name,
        email,
        password))
    conn.commit()


# Fetch all the columns for a single user row, by the PK.
def fetch_user_details(user_id: int) -> dict:
    cur.execute("""SELECT * FROM "User" WHERE "UserID" = %s""", (user_id,))
    return cur.fetchone()


# Question 1. Return the post_id if the post was successfully inserted, 
# or False otherwise.
def insert_post(topic_id: int, user_id: int, post_content: str, parent_post_id: int = None) -> int:
    '''
    This function should INSERT a new Post into a Topic, based on the function’s parameters.
    Check the User’s permissions to see if they are banned. If they are banned, then print
    an error message and do not perform any inserts.

    Your function should return the new PostID if everything was successful, False otherwise.

    '''
    try:
        cur.execute('''
                    SELECT "IsBanned" 
                    FROM "User" 
                    WHERE "UserID" = %s
                    ''', (user_id,))
        user_status = cur.fetchone()

        if user_status is None:
            print("ERROR: User not found.")
            return False

        if user_status[0] == True:  
            print("ERROR: Cannot perform insert. User is banned.")
            return False

        cur.execute(
            '''
            INSERT INTO "Post" ("PostContent", "TopicID", "ParentPostID", "AuthorUserID")
            VALUES (%s, %s, %s, %s)
            RETURNING "PostID";
            ''', (post_content, topic_id, parent_post_id, user_id)
        )
        post_id = cur.fetchone()[0]  
        conn.commit() 

        return post_id

    except Exception as e:
        print(f"ERROR: Unable to insert post. {e}")
        conn.rollback() 
        return False


# Question 2. Return the topic_id if the topic was successfully inserted, 
# or None otherwise.
def insert_topic(user_id: int, topic_name: str, post_content: str, 
                 category_id: int = None, is_pinned: bool = False) -> int:
    """
    This function should INSERT a new Topic into the database. A Post should also be
    inserted alongside the Topic. Both should be done based on the function’s parameters.
    You should make use of the insert_post() function you implemented in the previous
    question.

    Your function should check the User’s permissions. Users that are banned should be
    unable to create topics. If the topic is going to be pinned, then check to see if the
    user creating the topic is a moderator or administrator. Perform these checks in your
    function. If any of these checks fails, then print an error message and do not perform
    any inserts.

    Returns the new TopicID if successful, or None otherwise.
    """
    try:
        cur.execute('''
                    SELECT "IsBanned", "IsModerator", "IsAdministrator" 
                    FROM "User" 
                    WHERE "UserID" = %s
                    ''', (user_id,))
        user_status = cur.fetchone()

        if user_status is None:
            print("ERROR: User not found.")
            return None

        is_banned, is_moderator, is_administrator = user_status

        if is_banned:
            print("ERROR: User is banned and cannot create topics.")
            return None

        if is_pinned and not (is_moderator or is_administrator):
            print("ERROR: Only moderators or administrators can create pinned topics.")
            return None

        cur.execute(
            '''
            INSERT INTO "Topic" ("TopicName", "AuthorUserID", "CategoryID", "IsPinned")
            VALUES (%s, %s, %s, %s)
            RETURNING "TopicID";
            ''', (topic_name, user_id, category_id, is_pinned)
        )
        topic_id = cur.fetchone()[0]  
        post_id = insert_post(topic_id, user_id, post_content)
        if not post_id:
            print("ERROR: Cannot insert post.")
            conn.rollback()
            return None

        conn.commit()  
        return topic_id

    except Exception as e:
        print(f"ERROR: Unable to insert topic. {e}")
        conn.rollback() 
        return None


# Question 3.
# rating will be one of three values: 0, 1, or -1
def rate_post(user_id: int, post_id: int, rating: int) -> None:
    """
    This function should perform either an UPDATE or a INSERT to the Rating table. If
    a rating already exists (the PostID + RatedByUserID combination), then an UPDATE
    should be done, otherwise, an INSERT should be done.

    Rating must be one of 0, 1, or -1.

    Returns None.
    """
    try:
        if rating not in (0, 1, -1):
            print(f"ERROR: Rating must be 0, 1, or -1.")
            return None

        cur.execute('''
            SELECT "Rating" 
            FROM "Rating" 
            WHERE "PostID" = %s AND "RatedByUserID" = %s
        ''', (post_id, user_id))
        
        check_rating = cur.fetchone()

        if check_rating is None:
            cur.execute('''
                INSERT INTO "Rating" ("PostID", "RatedByUserID", "Rating")
                VALUES (%s, %s, %s)
            ''', (post_id, user_id, rating))
        else:
            cur.execute('''
                UPDATE "Rating" 
                SET "Rating" = %s
                WHERE "PostID" = %s AND "RatedByUserID" = %s
            ''', (rating, post_id, user_id))

        conn.commit()

    except Exception as e:
        print(f"ERROR: Unable to rate post. {e}")
        conn.rollback()

    return None


# Question 4. Delete a Category by ID, replacing that CategoryID with a 
# different CategoryID, for each Topic.
def delete_category(category_id: int, replace_with_category_id: int) -> None:
    """
    The written description describes how Categories cannot be deleted if they contain topics, 
    and instead those topics should be migrated to a new category before deletion. This
    function should implement this logic. For a given CategoryID, UPDATE that CategoryID
    with a new CategoryID for every Topic, and then DELETE the original CategoryID.

    Returns None.
    """
    try:
        cur.execute('''
            SELECT "TopicID"
            FROM "Topic"
            WHERE "CategoryID" = %s
        ''', (category_id,))

        check_category = cur.fetchone()

        if check_category is not None:
            cur.execute('''
                UPDATE "Topic"
                SET "CategoryID" = %s
                WHERE "CategoryID" = %s
            ''', (replace_with_category_id, category_id))

        cur.execute('''
            DELETE FROM "Category"
            WHERE "CategoryID" = %s
        ''', (category_id,))

        conn.commit()

    except Exception as e:
        print(f"ERROR: Cannot delete category. {e}")
        conn.rollback()

    return None


# Used to demonstrate an SQL injection attack
def unsafe_function(user_id: int):
    cur.execute("""SELECT "UserID", "DisplayName" 
                   FROM "User" WHERE "UserID" = {};""".format(user_id))
    return cur.fetchall()


# Using the unsafe function to get the passwords.
def sql_injection_attack():
    print(unsafe_function("1 UNION SELECT \"UserID\", \"Password\" FROM \"User\""))


def test_script():
    # insert_user("username", "email@gmail.com", "password", False, False, True)
    # insert_user("banned_user", "email2@gmail.com", "password2", True, False, False)
    # insert_topic(6, "new_topic", "YAHAYUAHAYUHAUYH", 3, True)
    # insert_topic(8, "new_topic2", "YAHAYUAHAYUHAUYH", 3, True)
    # rate_post(8, 3, -1)
    # rate_post(6, 3, 1)
    # insert_category("category_name", "LAKJNSDLKNALSKD")
    # delete_category(3, 4)
    pass

if __name__ == "__main__":
    test_script()
