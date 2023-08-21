
CREATE SCHEMA IF NOT EXISTS auditoria;


CREATE SEQUENCE IF NOT EXISTS auditoria.aud_cliente_seq; 
CREATE TABLE IF NOT EXISTS auditoria.aud_cliente (
  idaud BIGINT DEFAULT nextval('auditoria.aud_cliente_seq'::regclass),
  tipoaud VARCHAR(1),
  dataaud TIMESTAMP WITHOUT TIME ZONE,
  hostaud VARCHAR(50),
  loginaud VARCHAR(50),
  id BIGINT,
  nome VARCHAR(50),
  email VARCHAR(50),
  cpf VARCHAR(14)
) ;

CREATE SEQUENCE IF NOT EXISTS public.cliente_seq ;
CREATE TABLE IF NOT EXISTS public.cliente (
  id BIGINT DEFAULT nextval('public.cliente_seq'::regclass),
  nome VARCHAR(50),
  email VARCHAR(50),
  cpf VARCHAR(14),
  CONSTRAINT cliente_pkey PRIMARY KEY(id)
) ;

/**/
CREATE OR REPLACE  RULE rule_cliente_insert AS 
ON INSERT TO public.cliente 
DO  (
insert into auditoria.aud_cliente 
select nextval('auditoria.aud_cliente_seq'::text), 
    'I', now(), 
    case when inet_client_addr() is null then 'localhost' 
    else inet_client_addr()::varchar ||':'||inet_client_port() end, 
    session_user, NEW.*; );


CREATE OR REPLACE  RULE rule_cliente_update AS 
ON UPDATE TO public.cliente 
DO ( 
insert into auditoria.aud_cliente 
select nextval('auditoria.aud_cliente_seq'::text), 
    'U', now(), 
    case when inet_client_addr() is null then 'localhost' 
    else inet_client_addr()::varchar ||':'||inet_client_port() end, 
    session_user, NEW.*; 
);

CREATE OR REPLACE  RULE rule_cliente_delete AS 
ON DELETE TO public.cliente 
DO  (
insert into auditoria.aud_cliente 
    select nextval('auditoria.aud_cliente_seq'::text), 
    'D', now(), 
    case when inet_client_addr() is null then 'localhost' 
    else inet_client_addr()::varchar ||':'||inet_client_port() end, 
    session_user, OLD.*;);
   

/**/


CREATE OR REPLACE FUNCTION public.teste_performance_insert_row (
)
RETURNS integer AS
$body$
DECLARE
iCount INT := 0 ; 
BEGIN 

WHILE iCount <10000
LOOP 
INSERT INTO public.cliente (id , nome , email , cpf) VALUES (iCount, 'testes','testes de performance','418.068.108-08' );
iCount := iCount+1; 

END LOOP;



iCount  := 0 ; 
WHILE iCount <10000
LOOP 
UPDATE public.cliente SET nome ='testados' WHERE id =iCount ;
iCount := iCount+1; 

END LOOP;

iCount  := 0 ; 
WHILE iCount <10000
LOOP 
DELETE FROM public.cliente  WHERE id = iCount ;
iCount := iCount+1; 

END LOOP;

iCount  := 0 ; 


RETURN 1;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
PARALLEL UNSAFE
COST 100;


