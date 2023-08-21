CREATE SCHEMA IF NOT EXISTS auditoria ;
CREATE SEQUENCE IF NOT EXISTS public.cliente_seq ;
CREATE TABLE IF NOT EXISTS public.cliente (
  id BIGINT DEFAULT nextval('cliente_seq'::regclass) NOT NULL,
  nome VARCHAR(50),
  email VARCHAR(50),
  cpf VARCHAR(14),
  CONSTRAINT cliente_pkey PRIMARY KEY(id)
) ;

CREATE SEQUENCE IF NOT EXISTS auditoria.aud_cliente_seq; 
CREATE TABLE IF NOT EXISTS auditoria.aud_cliente (
  idaud BIGINT DEFAULT nextval('auditoria.aud_cliente_seq'::regclass),
  operacao VARCHAR(1),
  data_auditoria TIMESTAMP WITHOUT TIME ZONE,
  host_auditoria VARCHAR(50),
  login_auditoria VARCHAR(50),
  id BIGINT,
  nome VARCHAR(50),
  email VARCHAR(50),
  cpf VARCHAR(14)
) ;

CREATE OR REPLACE FUNCTION auditoria.func_aud_cliente (
)
RETURNS trigger AS
$body$
begin 
  if TG_OP = 'UPDATE' then 
    insert into auditoria.aud_cliente 
    select nextval('auditoria.aud_cliente_seq'::text), 
    'U', now(), 
    inet_client_addr(), 
    session_user, NEW.*; 
   
      
      return null; 
  
  elsif TG_OP = 'INSERT' then 
    insert into auditoria.aud_cliente 
    select nextval('auditoria.aud_cliente_seq'::text), 
    'I', now(), 
    inet_client_addr(), 
    session_user, NEW.*; 
    if not found then 
  
      return null; 
  else 
    insert into auditoria.aud_cliente 
    select nextval('auditoria.aud_cliente_seq'::text), 
    'D', now(), 
    inet_client_addr(), 
    session_user, OLD.*; 
    if not found then 
  
      return null; 
  end if; 


  return null; 
end;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
PARALLEL UNSAFE
COST 100;
/**/

  CREATE TRIGGER  auditoria
    AFTER INSERT OR UPDATE OR DELETE 
    ON public.cliente
    
  FOR EACH ROW 
    EXECUTE PROCEDURE auditoria.func_aud_cliente();

  /**/


/**/

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


