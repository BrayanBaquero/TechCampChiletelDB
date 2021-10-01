insert into ORDENES_ATENCION 
 select 
 nextval('ORDENES_ATENCION_seq'),
 0,
 s
 FROM generate_series(1,1000) s;