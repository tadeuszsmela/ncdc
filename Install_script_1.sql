Rem  PL/SQL instalation script
Rem Tadeusz Smela
Rem email: tadeusz_smela@comrad.pl
REM 2018-09-15 
REM 
REM Scrip create:
REM 			table DOCUMENTS 
REM				sequence documents_seq 
REM				trigger INSERT_UPDATE_DOCUMENTS
REM				Package package_TS containing:	
REM								procedure print_documents
REM								function  validate_pesel 


spool ..\log\ts_script.log;


Create table documents (
	document_id Number CONSTRAINT pk_document_id PRIMARY KEY,
	document_name Varchar2(50) NOT NULL,
	document_description Varchar2(4000),
	Record_Timestamp TIMESTAMP(6) WITH LOCAL TIME ZONE NOT NULL,
	Timestamp Timestamp(6) NOT NULL,
	Record_User_id Varchar2(50) NOT NULL,
	User_id Varchar2(50) NOT NULL
);

CREATE  SEQUENCE  documents_seq  INCREMENT BY 1 START WITH 1 ORDER;

create or replace TRIGGER INSERT_UPDATE_DOCUMENTS

BEFORE INSERT OR UPDATE ON DOCUMENTS FOR EACH ROW
	BEGIN
	if inserting then 
		:NEW.document_id := documents_seq.NEXTVAL;
		:NEW.record_timestamp:=SYSDATE;
		:NEW.record_user_id:=USER;
	end if; 
	:NEW.timestamp:=SYSDATE;
	:NEW.user_id:=USER;
END; 
/

create or replace PACKAGE package_TS
is
procedure print_documents;
function validate_pesel(pesel varchar2) return Boolean;
end;
/

create or replace package body package_TS is
    procedure print_documents 
    is
    doc documents%rowtype;
    cursor docs is 
    select * from documents;
    begin
        for doc in docs loop
            if doc.document_description is null 
            then  dbms_output.put_line('No Description');
            else  dbms_output.put_line(doc.document_name);
            end if;
        end loop;
    end;
    
    function validate_pesel (pesel in varchar2) 
    return Boolean
    IS
        control_digit Integer:=0;
        result Boolean:=False;
        Begin 
        control_digit:= to_number(SUBSTR(pesel,1,1));
        control_digit:=control_digit + 3*to_number(SUBSTR(pesel,2,1));
        control_digit:=control_digit + 7*to_number(SUBSTR(pesel,3,1));
        control_digit:=control_digit + 9*to_number(SUBSTR(pesel,4,1));
        control_digit:=control_digit + to_number(SUBSTR(pesel,5,1));
        control_digit:=control_digit + 3*to_number(SUBSTR(pesel,6,1));
        control_digit:=control_digit + 7*to_number(SUBSTR(pesel,7,1));
        control_digit:=control_digit + 9*to_number(SUBSTR(pesel,8,1));
        control_digit:=control_digit + to_number(SUBSTR(pesel,9,1));
        control_digit:=control_digit + 3*to_number(SUBSTR(pesel,10,1));
        control_digit:=10-mod(control_digit,10);
        control_digit:=mod(control_digit,10);
        if control_digit=to_number(SUBSTR(pesel,11,1)) then result:= True;
        else  result:=False; 
        end if;
        Return result;
    end;
end;
/


insert into documents (document_name, document_description) values ('Doc no 1', 'description od doc 1');
insert into documents (document_name) values ('Doc no 2');
insert into documents (document_name, document_description) values ('Doc no 3', 'description od doc 3');
insert into documents (document_name) values ('Doc no 4');
insert into documents (document_name, document_description) values ('Doc no 5', 'description od doc 5');
insert into documents (document_name) values ('Doc no 6');
COMMIT;

spool off;