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

drop table if exists document_link;

create table document_link (
	a text not null,
	b text not null,
	class text not null,
	deleted text default null,
	created text default current_timestamp,
	modified text default current_timestamp,
	seen text default current_timestamp,
	primary key (a, b)
);

drop index if exists document_class;

create index document_class on document (class);

drop index if exists document_link_class;

create index document_link_class on document_link (class);

drop index if exists document_link_a;

create index document_link_a on document_link (a);

drop index if exists document_link_b;

create index document_link_b on document_link (b);
