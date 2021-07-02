select * from USUARIOS_ROLES;
SELECT * FROM USUARIOS;
select * from tipos_incidencia;
select * from tipos_incidencia_tecnicos;
select * from tecnicos;
select * from cuadrillas;
select * from zonas_cuadrillas;
select * from zonas;
select * from tipos_cliente;
select * from clientes;
select * from incidencias;
select * from ordenes_atencion;

delete from incidencias;
delete from tipos_incidencia;
purge recyclebin; ---borrar secuancia generada por el sistema




------JOINS-----
--cliente con tipo de cliente
SELECT * FROM CLIENTES CL INNER JOIN TIPOS_CLIENTE TC ON CL.ID_TIPO_CLIENTE=TC.ID_TIPO_CLIENTE WHERE CL.ID_CLIENTE=2;
SELECT CL.IDENTIFICACION,CL.ID_ZONA,TC.PRIORIDAD FROM CLIENTES CL INNER JOIN TIPOS_CLIENTE TC ON CL.ID_TIPO_CLIENTE=TC.ID_TIPO_CLIENTE WHERE CL.ID_CLIENTE=2;

----------Daño con cliente para obtener tipo cliente-----------
SELECT CL.ID_CLIENTE CLIENTE,TD.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,RD.FECHA_REGISTRO FROM INCIDENCIAS RD 
INNER JOIN TIPOS_INCIDENCIA TD 
    ON  RD.ID_TIPO_INCIDENCIA=TD.ID_TIPO_INCIDENCIA
INNER JOIN CLIENTES CL
    ON RD.ID_CLIENTE=CL.ID_CLIENTE
INNER JOIN TIPOS_CLIENTE TC
    ON TC.ID_TIPO_CLIENTE=CL.ID_TIPO_CLIENTE
   -- ORDER BY  P_TCLIENTE ASC,P_TDAÑO ASC, FECHA_REGISTRO ASC
ORDER BY P_TDAÑO ASC, P_TCLIENTE ASC, FECHA_REGISTRO ASC
fetch first 1 row only;



--------------------------------------------------------------------------------------
----------ORDENES DE ATENCION ORGANIZADAS POR PRIORIDADES--------------------------------
SELECT ORT.ID_ORDEN_ATENCION,ORT.AGENDADO,I.DESCRIPCION FROM ORDENES_ATENCION ORT INNER JOIN INCIDENCIAS I ON (ORT.ID_INCIDENCIA=I.ID_INCIDENCIA);

explain plan for
SELECT /* +USE_nl(ort i ti) */ CL.ID_CLIENTE CLIENTE,TI.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,CL.ID_ZONA,I.FECHA_REGISTRO,ORT.ID_ORDEN_ATENCION FROM ORDENES_ATENCION ORT 
INNER JOIN INCIDENCIAS I
    ON (ORT.ID_INCIDENCIA=I.ID_INCIDENCIA)
INNER JOIN TIPOS_INCIDENCIA TI
    ON (I.ID_TIPO_INCIDENCIA=TI.ID_TIPO_INCIDENCIA)
INNER JOIN CLIENTES CL
    ON (I.ID_CLIENTE=CL.ID_CLIENTE)
INNER JOIN TIPOS_CLIENTE TC
    ON (CL.ID_TIPO_CLIENTE=TC.ID_TIPO_CLIENTE)
WHERE ORT.AGENDADO=0
ORDER BY P_TDAÑO ASC, P_TCLIENTE ASC, FECHA_REGISTRO ASC
fetch first 1 row only;
--------------------------------------------------------------------------
  
EXPLAIN PLAN FOR 
SELECT /*+ LEADING(ti) USE_nl(ort i ti) */ CL.ID_CLIENTE CLIENTE,TI.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,CL.ID_ZONA,I.FECHA_REGISTRO,ORT.ID_ORDEN_ATENCION 
FROM ORDENES_ATENCION ORT,INCIDENCIAS I,TIPOS_INCIDENCIA TI,CLIENTES CL,TIPOS_CLIENTE TC
WHERE ORT.ID_INCIDENCIA=I.ID_INCIDENCIA
  AND I.ID_TIPO_INCIDENCIA=TI.ID_TIPO_INCIDENCIA
  AND I.ID_CLIENTE=CL.ID_CLIENTE
  AND CL.ID_TIPO_CLIENTE=TC.ID_TIPO_CLIENTE
AND ORT.AGENDADO=0
ORDER BY P_TDAÑO ASC, P_TCLIENTE ASC, FECHA_REGISTRO ASC;


    
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



---------ENCONTRAR A TECNICOS- POR PRIORIDAD Y ZONA DE ATENCION----------------------------------------------
SELECT tc.nombre,TC.ID_TECNICO,TP.NOMBRE,z.nombre,TP.PRIORIDAD FROM TECNICOS TC 
INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
WHERE TC.BORRADO=0 AND TP.PRIORIDAD=1 AND Z.ID_ZONA=1;

----------------------------------------------------------------------------------------------------------------
SELECT CL.ID_CLIENTE CLIENTE,TD.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,RD.FECHA_REGISTRO FROM INCIDENCIAS RD 
INNER JOIN TIPOS_INCIDENCIA TD 
    ON  RD.ID_TIPO_INCIDENCIA=TD.ID_TIPO_INCIDENCIA
INNER JOIN CLIENTES CL
    ON RD.ID_CLIENTE=CL.ID_CLIENTE
INNER JOIN TIPOS_CLIENTE TC
    ON TC.ID_TIPO_CLIENTE=CL.ID_TIPO_CLIENTE
ORDER BY P_TDAÑO ASC, P_TCLIENTE ASC, FECHA_REGISTRO ASC
fetch first 1 row only;

---------VER VALOR SECUANCIA--------------
SELECT CLIENTE_SEQ.NEXTVAL FROM DUAL;
SELECT CLIENTE_SEQ.CURRVAL FROM DUAL;
SELECT CLIENTE_SEQ.CURRVAL FROM DUAL;
select cuadrillas_seq.currval from dual;



-------------count cuadrillas-------------

select count(*) "Nombre" from tecnicos;

select * from  cuadrillas t left join tecnicos tc on (t.id_cuadrilla=tc.id_cuadrilla) where tc.borrado=0;

select c.id_cuadrilla,c.nombre,c.borrado, count(tc.id_cuadrilla) as nTecnicos from cuadrillas c 
left join tecnicos tc 
    on tc.id_cuadrilla=c.id_cuadrilla
where tc.borrado=0
group by c.id_cuadrilla, c.nombre, c.borrado
order by nTecnicos;


-------------------FINAL---CONTEO DE TECNICOS POR CUADRILLAS-----------------------------------------
select c.nombre, count(tc.id_cuadrilla) as miembros from cuadrillas c 
left join tecnicos tc 
    on tc.id_cuadrilla=c.id_cuadrilla
where tc.borrado=0
group by  c.nombre, c.borrado
order by miembros;

select c.nombre,c.id_cuadrilla, count(tc.id_cuadrilla) as miembros from cuadrillas c 
left join tecnicos tc 
    on tc.id_cuadrilla=c.id_cuadrilla
where tc.borrado=0
group by c.nombre,c.id_cuadrilla
order by c.id_cuadrilla;
----------------------------------------------------------------------------





select to_char(sysdate, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH') from dual;
select DECODE(RTRIM(LTRIM(to_char(sysdate, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH'))),
'LUNES', 0, 'MARTES', 1, 'MIERCOLES', 2, 'JUEVES', 3,
'VIERNES', 4, 'SABADO', 5, 6)
from dual;

SELECT (TO_CHAR(TO_DATE('2021-06-26T5:50:14Z',  'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'D')) FROM DUAL;


------------------------------FECHAS----------------------------------------
------FILTRAR POR TECNICO Y POR RANGO DINA SEMANA
DIA_SEMANA:=TO_CHAR(SYSDATE,'D');
SELECT * FROM AGENDAS WHERE ID_TECNICO=2 OR ID_TECNICO=3 AND TO_CHAR(FECHA,'D')>=TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<6;

SELECT SUM(T_ATENCION) FROM AGENDAS WHERE ID_TECNICO=2 AND TO_CHAR(FECHA,'D')>TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<6;

SELECT ID_TECNICO TC,SUM(T_ATENCION) T FROM AGENDAS 
    WHERE id_tecnico=2 OR ID_TECNICO=3 and TO_CHAR(FECHA,'D')>=TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<6
GROUP BY ID_TECNICO
ORDER BY T ASC;

SELECT h_inicio,h_final from agendas where id_tecnico=2 order by h_final asc;

SELECT SUM() FROM AGENDAS WHERE ID_TECNICO=2 AND TO_CHAR(FECHA,'D')>=TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<6;

select
   ROUND( 24 * (sysdate - to_date('2021-06-29 19:07', 'YYYY-MM-DD hh24:mi'))) as diff_hours
from dual;













----
/*
IMPORTANTE V FINAL DE QUERY PARA OBTENER TECNICOS POR PRIORIDAD DE ATENCION Y ZONAS CON TIEMPO 
DISPONIBLE EN AGENDA ORGANIZAR CON EL MENOR TIEMPO AGENDADO FILTRANDO DE LUNES A VIERNES
*/

select tec.id_tecnico, coalesce(sum(ag.t_atencion),0) ag from agendas ag right join (select tc.id_tecnico FROM TECNICOS TC 
                INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
                INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
                INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
                INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
                WHERE TC.BORRADO=0 AND TP.PRIORIDAD=1 AND Z.ID_ZONA=7) tec
                on ag.id_tecnico=tec.id_tecnico
                and TO_CHAR(ag.FECHA,'D')>=TO_CHAR(2)
                AND TO_CHAR(ag.FECHA,'D')<=TO_CHAR(6)
            group by tec.id_tecnico
            order by ag asc;