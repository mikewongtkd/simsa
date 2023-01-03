drop table if exists login;

create table login (
	uuid text primary key,
	email text unique not null,
	pwhash text,
	info text_json
);

drop table if exists user;

create table user (
	uuid text primary key,
	id text not null,
	fname text not null,
	lname text not null,
	login text not null,
	dob text,
	gender text,
	rank text_json,
	noc text,
	info text_json,
	foreign key( login ) references login( uuid )
);

drop table if exists examination;

create table examination (
	uuid text primary key,
	name text,
	poster text,
	host text,
	address text_json,
	start text,
	schedule text_json,
	description text,
	url text,
	permissions text_json,
	info text_json,
	foreign key( poster ) references user( uuid )
);

drop table if exists panel;

create table panel (
	uuid text primary key,
	exam text not null,
	name text,
	info text_json,
	foreign key( exam ) references examination( uuid )
);

drop table if exists panel_examiner;

create table panel_examiner (
	uuid text primary key,
	panel text not null,
	examiner text not null,
	start text,
	stop text,
	foreign key( panel ) references panel( uuid ),
	foreign key( examiner ) references examiner( uuid )
);

drop table if exists cohort;

create table cohort (
	uuid text primary key,
	exam text not null,
	panel text,
	area text not null,
	name text,
	description text,
	parent text,
	info text_json,
	foreign key( exam ) references examination( uuid ),
	foreign key( panel ) references panel( uuid )
	foreign key( parent ) references cohort( uuid )
);

drop table if exists official;

create table official (
	uuid text primary key,
	user text not null,
	exam text not null,
	role text,
	info text_json,
	foreign key( user ) references user( uuid ),
	foreign key( exam ) references examination( uuid )
);

drop table if exists examinee;

create table examinee (
	uuid text primary key,
	user text not null,
	exam text not null,
	id text not null,
	cohort text,
	info text_json,
	foreign key( user ) references user( uuid ),
	foreign key( exam ) references examination( uuid ),
	foreign key( cohort ) references cohort( uuid )
);

drop table if exists examiner;

create table examiner (
	uuid text primary key,
	user text not null,
	exam text not null,
	info text_json,
	foreign key( user ) references user( uuid ),
	foreign key( exam ) references examination( uuid )
);

drop table if exists score;

create table score (
	uuid text primary key,
	given text_json,
	examinee text not null,
	examiner text not null,
	time text default CURRENT_TIMESTAMP,
	info text_json,
	foreign key( examinee ) references examinee( uuid ),
	foreign key( examiner ) references examiner( uuid )
)

