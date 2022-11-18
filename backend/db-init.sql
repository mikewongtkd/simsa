drop table if exists user;

create table user (
	uuid text primary key,
	fname text not null,
	lname text not null,
	email text unique not null,
	password text,
	dob text,
	gender text,
	rank text_json,
	noc text,
	info text_json
);

drop table if exists promotion_test;

create table promotion_test (
	uuid text primary key,
	name text,
	schedule text_json,
	description text,
	url text,
	info text_json
);

drop table if exists promotion_group;

create table promotion_group (
	uuid text primary key,
	test text,
	name text,
	description text,
	info text_json,
	foreign key( test ) references promotion_test( uuid ) on delete cascade
);

drop table if exists examinee;

create table examinee (
	uuid text primary key,
	user text,
	test text,
	id int,
	`group` text,
	subgroup int,
	info text_json,
	foreign key( user ) references user( uuid ) on delete cascade,
	foreign key( test ) references promotion_test( uuid ) on delete cascade,
	foreign key( `group` ) references promotion_group( uuid ) on delete cascade
);

drop table if exists examiner;

create table examiner (
	uuid text primary key,
	user text,
	test text,
	info text_json,
	foreign key( user ) references user( uuid ) on delete cascade,
	foreign key( test ) references promotion_test( uuid ) on delete cascade
);

drop table if exists score;

create table score (
	uuid text primary key,
	area text,
	given text_json,
	examinee text,
	examiner text,
	info text_json,
	foreign key( examinee ) references examinee( uuid ) on delete cascade,
	foreign key( examiner ) references examiner( uuid ) on delete cascade
)

