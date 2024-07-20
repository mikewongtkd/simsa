drop table if exists document;

create table document (
	uuid text primary key,
	class text not null,
	data text_json default '{}',
	deleted text default null,
	created text default current_timestamp,
	modified text default current_timestamp,
	seen text default current_timestamp
);

drop table if exists sessions;

create table sessions (
    id text primary key,
    seen int default (strftime( '%s', 'now' )),
    data text
);

