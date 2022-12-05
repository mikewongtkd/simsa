drop table if exists login;

create table login (
	uuid text primary key,
	email text unique not null,
	pwhash text,
	role text
)

drop table if exists user;

create table user (
	uuid text primary key,
	id text not null,
	fname text not null,
	lname text not null,
	email text not null,
	dob text,
	gender text,
	rank text_json,
	noc text,
	info text_json,
	foreign key( email ) references login( email )
);

drop table if exists promotion_test;

create table promotion_test (
	uuid text primary key,
	name text,
	poster text,
	host text,
	address1 text,
	address2 text,
	city text,
	country text,
	daystart text,
	daystop text,
	schedule text_json,
	description text,
	url text,
	info text_json,
	foreign key( poster ) references user( uuid )
);

drop table if exists panel;

create table panel (
	uuid text primary key,
	test text not null,
	area text,
	name text,
	info text_json,
	foreign key( test ) references promotion_test( uuid )
);

drop table if exists promotion_group;

create table promotion_group (
	uuid text primary key,
	test text not null,
	panel text,
	area text not null,
	name text,
	description text,
	info text_json,
	foreign key( test ) references promotion_test( uuid ),
	foreign key( panel ) references panel( uuid )
);

drop table if exists official;

create table official (
	uuid text primary key,
	user text not null,
	test text not null,
	role text,
	foreign key( user ) references user( uuid ),
	foreign key( test ) references promotion_test( uuid )
);

drop table if exists examinee;

create table examinee (
	uuid text primary key,
	user text not null,
	test text not null,
	id int,
	`group` text,
	subgroup int,
	info text_json,
	foreign key( user ) references user( uuid ),
	foreign key( test ) references promotion_test( uuid ),
	foreign key( `group` ) references promotion_group( uuid )
);

drop table if exists examiner;

create table examiner (
	uuid text primary key,
	user text not null,
	test text not null,
	info text_json,
	foreign key( user ) references user( uuid ),
	foreign key( test ) references promotion_test( uuid )
);

drop table if exists score;

create table score (
	uuid text primary key,
	given text_json,
	examinee text not null,
	examiner text not null,
	info text_json,
	foreign key( examinee ) references examinee( uuid ),
	foreign key( examiner ) references examiner( uuid )
)

