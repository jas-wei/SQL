--ROLLBACK;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS "Rating";
DROP TABLE IF EXISTS "WatchTopic";
DROP TABLE IF EXISTS "WatchPost";
DROP TABLE IF EXISTS "Activity";
DROP TABLE IF EXISTS "TopicTag";
DROP TABLE IF EXISTS "Tag";
DROP TABLE IF EXISTS "Post";
DROP TABLE IF EXISTS "Topic";
DROP TABLE IF EXISTS "User";
DROP TABLE IF EXISTS "Category";


CREATE TABLE "Category" (
    "CategoryID"          SERIAL  NOT NULL PRIMARY KEY,
    "CategoryName"        TEXT    NOT NULL UNIQUE,
    "CategoryDescription" TEXT    NOT NULL DEFAULT ('') 
);

CREATE TABLE "User" (
    "UserID"          SERIAL    NOT NULL PRIMARY KEY,
    "DisplayName"     TEXT      NOT NULL,
    "Email"           TEXT      NOT NULL UNIQUE,
    "Password"        TEXT      NOT NULL,
    "Salt"            TEXT      NOT NULL,
    "IsBanned"        BOOLEAN   NOT NULL DEFAULT FALSE,
    "IsModerator"     BOOLEAN   NOT NULL DEFAULT FALSE,
    "IsAdministrator" BOOLEAN   NOT NULL DEFAULT FALSE,
    "RegisteredOn"    TIMESTAMP NOT NULL DEFAULT NOW(),
    "AvatarUrl"       TEXT
);

CREATE TABLE "Topic" (
    "TopicID"        SERIAL    PRIMARY KEY NOT NULL,
    "TopicName"      TEXT      NOT NULL,
    "AuthorUserID"   INTEGER   REFERENCES "User" ("UserID") ON DELETE SET NULL,
    "CategoryID"     INTEGER   NOT NULL REFERENCES "Category" ("CategoryID") ON DELETE RESTRICT,
    "IsPinned"       BOOLEAN   NOT NULL DEFAULT FALSE,
    "CreatedOn"      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE "Post" (
    "PostID"       SERIAL    NOT NULL PRIMARY KEY,
    "PostContent"  TEXT      NOT NULL,
    "TopicID"      INTEGER   NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
    "CreatedOn"    TIMESTAMP NOT NULL DEFAULT NOW(),
    "ModifiedOn"   TIMESTAMP, 
    "ParentPostID" INTEGER   REFERENCES "Post" ("PostID"),
    "AuthorUserID" INTEGER   REFERENCES "User" ("UserID") ON DELETE SET NULL
);

CREATE TABLE "Tag" (
    "TagID"   SERIAL  NOT NULL PRIMARY KEY,
    "TagName" TEXT    NOT NULL UNIQUE
);

CREATE TABLE "TopicTag" (
    "TopicID"  INTEGER NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
    "TagID"    INTEGER NOT NULL REFERENCES "Tag" ("TagID") ON DELETE CASCADE,
    PRIMARY KEY ("TopicID", "TagID")
);

CREATE TABLE "Activity" (
    "UserID"   INTEGER   NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
    "TopicID"  INTEGER   NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
    "ViewedOn" TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("UserID", "TopicID")
);

CREATE TABLE "WatchPost" (
    "PostID"             INTEGER   NOT NULL REFERENCES "Post" ("PostID") ON DELETE CASCADE,
    "UserID"             INTEGER   NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
    "StartingWatchingOn" TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("PostID", "UserID")
);

CREATE TABLE "WatchTopic" (
    "TopicID"            INTEGER   NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
    "UserID"             INTEGER   NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
    "StartingWatchingOn" TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("TopicID", "UserID")
);

CREATE TABLE "Rating" (
    "RatingID"      SERIAL PRIMARY KEY NOT NULL,
    "PostID"        INTEGER REFERENCES "Post" ("PostID") ON DELETE CASCADE NOT NULL,
    "RatedByUserID" INTEGER REFERENCES "User" ("UserID") ON DELETE SET NULL,
    "Rating"        INTEGER CHECK ("Rating" IN ( -1, 0, 1)) DEFAULT (0) NOT NULL
);

COMMIT;