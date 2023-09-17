-- Copyright (c) 2020 by entr Systems, Inc. -- All rights reserved
-- Confidential and Proprietary

-- Create parent role
CREATE ROLE entr_admin NOLOGIN;
GRANT USAGE ON SCHEMA public TO entr_admin;
GRANT CREATE ON SCHEMA public TO entr_admin;

-- Create entr_app1 user
CREATE USER entr_app1 WITH PASSWORD 'entr#REDB';
-- Create entr_app2 user
CREATE USER entr_app2 WITH PASSWORD 'entr#REDB';

GRANT entr_admin TO entr_app1;
GRANT entr_admin TO entr_app2;

-- This line means that when the entr_app1 or entr_app2 user logs in, it will assume the entr_admin
-- role without us having to have SET ROLE commands at the beginning of every migration
ALTER ROLE entr_app1 SET ROLE entr_admin;
ALTER ROLE entr_app2 SET ROLE entr_admin;