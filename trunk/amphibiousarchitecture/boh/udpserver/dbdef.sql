# dbdef.sql
# database definitions
# jcl/nyu/2009-07-19

# f1: food event
#
drop table if exists f1;
create table f1 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	event varchar(20) not null
);

# f2: fish
#
drop table if exists f2;
create table f2 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	nfish int not null,
	weight int not null,
	depth int not null
);

# f3: dissolved oxygen
#
drop table if exists f3;
create table f3 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	dissox int not null
);

# f4: food event
#
drop table if exists f4;
create table f4 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	foodtype int not null,
	weight int not null
);

# f5: sms event
#
drop table if exists f5;
create table f5 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	caller varchar(20) not null,
	msg varchar(255) not null,
	reply varchar(255) not null
);

# f6: hydrophone sound level
#
drop table if exists f6;
create table f6 (
	# standard columns
	id int not null auto_increment primary key,
	srcaddr varchar(50) null,
	stamp datetime not null,
	site int not null,
	sensor int not null,
	# table-specific columns
	# don't know what to put here
	dunno int not null
);

# end
