Rem  PL/SQL instalation script of optional part of the task
Rem Tadeusz Smela
Rem email: tadeusz_smela@comrad.pl
REM 2018-09-15 
REM 
REM Scrip create:
REM 			directory CSV_DATA
REM				Package PACK_IMPORT containing procedure csv_import 
REM Procedure csv_import read two column csv file 
REM First column - 	Document name
REM Second column - Document description 
REM Separator:  semicolon 
REM As parameter procedure need file name to import (file name with path)



create or replace DIRECTORY CV_DATA as 'c:\dane'
/
create or replace PACKAGE pack_import
is
procedure csv_import(file_name varchar2);
end;
/


create or replace package body pack_import is
    procedure csv_import(file_name varchar2)
    is

	file utl_file.file_type;
	linia varchar2(500);
	type document is record(
		name varchar2(50),
		description varchar2(4000)
	);
	semicolon_pos integer;
	start_pos integer;
	doc document;
	f_exist boolean:=false;
	f_length number;
	f_blksize number;
	no_rec_imported number:=0;
	begin
	utl_file.fgetattr('CSV_DATA', file_name, f_exist, f_length, f_blksize);
	if f_exist then
		file:=utl_file.fopen('CSV_DATA',file_name,'r');
		loop
			start_pos:=1;
			utl_file.get_line(file,linia);
			semicolon_pos := instr(linia,';',start_pos);
			if semicolon_pos>0 then
				doc.name:=trim(substr(linia, start_pos,(semicolon_pos - start_pos)));
			else
				doc.name:=trim(linia);
			end if;
			start_pos:=semicolon_pos+1;
			semicolon_pos := instr(linia,';',start_pos);
			if semicolon_pos>0 then
				doc.description:=trim(substr(linia, start_pos,(semicolon_pos - start_pos)));
			else
				doc.description:='';
			end if;
			insert into documents (document_name, document_description) VALUES (doc.name,doc.description) ;
			dbms_output.put_line(doc.name || ' ' || doc.description || ' inserted');
			no_rec_imported:=no_rec_imported+1;
		end loop;		
	else
		dbms_output.put_line('File '|| file_name||' not found.');
	end if;
	exception
	when others then
	utl_file.fclose(file);
	if no_rec_imported>0 then 
		dbms_output.put_line(no_rec_imported || ' documents imported');
	else
		dbms_output.put_line('No documents imported');
	end if;
	end;
end;
/
