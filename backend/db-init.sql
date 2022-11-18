drop table if exists user;

create table user (
	uuid text primary key,
	fname text not null,
	lname text not null,
	email text unique not null,
	password text,
);
