drop table if exists document;

create table document (
	uuid text primary key,
	class text not null,
	data text_json
);

drop table if exists key;

create table key (
	plural text not null,
	singular text not null
);

