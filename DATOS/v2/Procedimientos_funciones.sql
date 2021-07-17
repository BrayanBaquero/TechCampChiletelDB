 ----------------ORDENES ORGANIZADAS POR PRIORIDAD-------------------
 create or replace FUNCTION ORDENES_ORGANIZADAS RETURN SYS_REFCURSOR
IS
    TYPE ref_cursor IS REF CURSOR;
    v_ref ref_cursor;
BEGIN
    OPEN v_ref FOR SELECT /*use_hash(ort i ti cl tc) index(i,incidencias_pk)*/ ORT.ID_ORDEN_ATENCION,TI.TIEMPO_ATENCION,CL.ID_CLIENTE CLIENTE,TI.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,CL.ID_ZONA,I.FECHA_REGISTRO FROM ORDENES_ATENCION ORT 
        INNER JOIN INCIDENCIAS I
            ON (ORT.ID_INCIDENCIA=I.ID_INCIDENCIA)
        INNER JOIN TIPOS_INCIDENCIA TI
            ON (I.ID_TIPO_INCIDENCIA=TI.ID_TIPO_INCIDENCIA)
        INNER JOIN CLIENTES CL
            ON (I.ID_CLIENTE=CL.ID_CLIENTE)
        INNER JOIN TIPOS_CLIENTE TC
            ON (CL.ID_TIPO_CLIENTE=TC.ID_TIPO_CLIENTE)
        WHERE ORT.AGENDADO=0
        ORDER BY P_TDAÑO ASC, P_TCLIENTE ASC, FECHA_REGISTRO ASC;
    RETURN v_ref;
END;
 
 /
--------------------FUNCION BUSCAR TECNICOS--------------------------
create or replace function BUSCAR_TECNICOS( pr          tipos_incidencia.prioridad%type,
                                            zona        zonas.id_zona%type,
                                            dia_inicio  date,
                                            dia_fin     date)
return sys_refcursor
is
TYPE ref_cursor IS REF CURSOR;
cur ref_cursor;
begin
    open cur for select tec.id_tecnico, coalesce(sum(ag.t_atencion),0) ag from agendas ag right join (select /*+ use_hash(tc tit tp zc z)*/ tc.id_tecnico FROM TECNICOS TC 
                INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
                INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
                INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
                INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
                WHERE TC.BORRADO=0 AND TP.PRIORIDAD=pr AND Z.ID_ZONA=zona) tec
                on ag.id_tecnico=tec.id_tecnico
                and FECHA>=dia_inicio
                AND FECHA<=dia_fin
            group by tec.id_tecnico
            order by ag asc; 
    return cur;
end;            
   
/
-------------------------FUNCION AGENDAR---------------------------------------

create or replace 
FUNCTION AGENDAR(
                id_orden ordenes_atencion.id_orden_atencion%type,
                id_tec tecnicos.id_tecnico%type,
                t_aten number,
                dia_inicio date, 
                dia_fin date)
RETURN NUMBER
IS
    PRAGMA autonomous_transaction;
    suma number; --Suma de horas agendadas diarias
    cont number; --conteo de filas, para verificar que el dia tenga agenda asignada
    h_agenda_ult timestamp;--Ultima hora del dia en agenda de tecnico
    fecha_insertar date; --Usada para calcular fecha a insertar en tabla agenda
    hi_insertar timestamp; --Usada para calculo de hora inicio a insertar en agenda
    hf_insertar timestamp; --Usada para calcular hora final a insertar en agenda
BEGIN
    --dbms_output.put_line('--FUNCION AGENDAR ORDENES: '|| dia_inicio);
    
    /*Recorrer la semana para validar la disponibilidad diaria del técnico*/
    for cnt in to_number(to_char(dia_inicio,'D'))..to_number(to_char(dia_fin,'D'))
    loop
        /*Encortar las horas que se han agendado al tecnico durante el dia y duardarlas en la variable suma*/
       select /*+ index(agendas,idx_agendas_1) */coalesce(sum(t_atencion),0) into suma from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt);
       --dbms_output.put_line('---TNecesitado: ' || t_aten || '|  TDisponible: '|| (8-suma) || ' Dia de la semana: '|| to_char(TO_CHAR(TO_DATE(trunc(dia_inicio)+(cnt-to_number(to_char(dia_inicio,'D'))), 'DD/MM/YYYY'), 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
        
        /*Validar si ya se llego al dia final de la semana y no tiene tiempo disponible en el dia, si es afirmativo no agenda nada */
        if(cnt=to_number(to_char(dia_fin,'D')) and (8-suma)<t_aten)then
            return 0;
        end if;
        
        /*Se entra en la condicion si hay tiempo disponible en el dia, lo cual agendara
        la orden ese mismo dia despues de la ultima orden agendada*/    
        if((8-suma)>=t_aten and suma>0) then
            /*Encontrar la ultima hora agendada en el dia*/
            select h_final into h_agenda_ult from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt) order by h_final desc fetch first 1 row only;
            fecha_insertar:=trunc(h_agenda_ult);--calcular el campo Fecha de agenda
            hi_insertar:=h_agenda_ult; --Hora de inicio de agendamiento de orden es igual a la hora final de la ultima orden agendada
            hf_insertar:=hi_insertar+(t_aten/24); ----Hora final de la orden se calcula sumandole a la hora de inicio el tiempo de atencion segun el tipo de incidencia que tenga la orden.
            dbms_output.put_line('--------UltimaHora: ' || h_agenda_ult);
            dbms_output.put_line('--------Dia disponible=>' || 'Fecha: ' || fecha_insertar || ' | Hora inicio: ' || hi_insertar || ' | Hora final: ' ||  hf_insertar);
            UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;--Actualizar el campo agendado=1 para indicar que la orden se agendo
            insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (agendas_seq.nextval,id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
            commit;
            return 1;
        /*Si el dia no tiene nada agendado se agendara la orden ese dia desde las 8 AM*/
        elsif(suma=0)then
            fecha_insertar:=trunc(dia_inicio)+(cnt-to_number(to_char(dia_inicio,'D')));
            hi_insertar:=fecha_insertar+(8/24);
            hf_insertar:=fecha_insertar+((8+t_aten)/24);
            dbms_output.put_line('--------Nuevo dia=>   ' ||'Tecnico: ' || id_tec|| ' | Fecha: ' || fecha_insertar || ' | Hora inicio: ' || hi_insertar || ' | Hora final: ' ||  hf_insertar);
            insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (agendas_seq.nextval,id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
            UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;
            commit;
            return 1;
        end if;
    end loop;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error:'||SQLCODE||SQLERRM);
        rollback;
        RETURN 0;
END;


/     
----------------------------PROCEDIMIENTO ALMACENADO--------------------------------

CREATE OR REPLACE PROCEDURE pa_agendar_ordenes (
    estado OUT INTEGER
) IS

    ref_cur_ordenes   SYS_REFCURSOR;--Cursor para recibir valores de la funcion ORDENES_ATENCION 
    ref_cur_tecnicos  SYS_REFCURSOR;--Cursor para recibir resultado de funcion BUSCAR_TECNICOS

    TYPE ordenes_rc IS RECORD (
        id_orden_atencion  ordenes_atencion.id_orden_atencion%TYPE,
        tiempo_atencion    tipos_incidencia.tiempo_atencion%TYPE,
        cliente            clientes.id_cliente%TYPE,
        p_tdaño            tipos_incidencia.prioridad%TYPE,
        p_tcliente         tipos_cliente.prioridad%TYPE,
        id_zona            zonas.id_zona%TYPE,
        fecha_registro     incidencias.fecha_registro%TYPE
    );
    TYPE ordenes_tb IS
        TABLE OF ordenes_rc;
    TYPE tec_agenda IS RECORD (
        id_tecnico       tecnicos.id_tecnico%TYPE,
        horas_semanales  NUMBER
    );
    orden             ordenes_tb; --Ordenes de atencion organizadas por prioridad
    tecnico           tec_agenda;--Almacenar tecnico diponibles para atender orden organizados por tiempo agendado
    agenda            NUMBER(1);--Falg indicado de agendamiento exitos de orden

    dia_actual        DATE;--:=to_date('2021-06-28','YYYY-MM-DD');
    inicio_semana     NUMBER := 2; --Lunes
    fin_semana        NUMBER := 6; --Viernes
    dia_inicio        DATE;  --Dia desde el cual se empieza a agendar  
    dia_fin           DATE;
    h_semanales_d     NUMBER;--calculo de horas semanales disponibles por tecnico 
BEGIN
    dia_actual := sysdate;
 
 /*Validar fecha de agendamiento, el dia que se ejecute el SP se valida si esta entra lunes y viernes si es valida la opción 
 la fecha en la cual se va a agendar será desde el día siguiente hasta el viernes. Si se va a relizar el proceso de agendamiento 
 un sabado o domingo, se va a agendar de lunes a viernes de la siguiente semana */
    IF (
        to_char(dia_actual, 'D') >= inicio_semana
        AND to_char(dia_actual, 'D') < fin_semana
    ) THEN
        dia_inicio := dia_actual + 1;
        dia_fin := next_day(dia_actual, 'VIERNES');
    ELSE
        dia_inicio := next_day(dia_actual, 'LUNES');
        dia_fin := next_day(dia_inicio, 'VIERNES');
    END IF;
-------------------------------------------------------------------------------------
    ref_cur_ordenes := ordenes_organizadas;---Obtener ordenes de atencion organizadas por prioridad
    LOOP
        FETCH ref_cur_ordenes BULK COLLECT INTO orden;
        FOR i IN 1..orden.count LOOP
             --DBMS_OUTPUT.PUT_LINE(orden.CLIENTE || '| ' || orden(i).P_TDAÑO || '| ' || orden(i).P_TCLIENTE || '| ' || orden(i).ID_ZONA || '| ' || orden(i).FECHA_REGISTRO);
            --DBMS_OUTPUT.PUT_LINE('Orden  ==> Cliente:' || orden(i).CLIENTE);
            ref_cur_tecnicos := buscar_tecnicos(orden(i).p_tdaño, orden(i).id_zona, dia_inicio, dia_fin);---Obtener tecnicos que pueden atender cada orden de atencion zona||tipo incidencia
            LOOP
                FETCH ref_cur_tecnicos INTO tecnico;
                EXIT WHEN ref_cur_tecnicos%notfound;
              --  dbms_output.put_line('-Id tecnico: ' || tecnico.id_tecnico || ' | tAgendado: ' || tecnico.horas_semanales);
              --  dbms_output.put_line('inicio:' || dia_inicio || ' dia fin: ' || dia_fin || 'resta: ' ||to_char(to_number(to_char(dia_fin,'D'))-to_number(to_char(dia_inicio,'D'))));
                
                /*Agendar ordenes de atencion llamando a la funcion AGENDAR*/
                --------------------------------------------------------------------
                h_semanales_d := ( ( to_number(to_char(dia_fin, 'D')) - to_number(to_char(dia_inicio, 'D')) ) + 1 ) * 8;

                IF ( ( h_semanales_d - tecnico.horas_semanales ) >= orden(i).tiempo_atencion ) THEN
                    agenda := agendar(orden(i).id_orden_atencion, tecnico.id_tecnico, orden(i).tiempo_atencion, dia_inicio, dia_fin);

                    EXIT WHEN agenda = 1;--Salir del loop cuando la orden fue agendada y paras a la siguiente
                END IF;
                ---------------------------------------------------------------------
            END LOOP;--fin loop tecnicos

            CLOSE ref_cur_tecnicos;--cerrar cursor
            agenda := 0;--inicializar indicador de estado de agendamiento

        END LOOP;--Fin loop for ordenes

        EXIT WHEN ref_cur_ordenes%notfound;--salir Loop cursor ordenes
    END LOOP;--Fin loop bulk ordenes
    CLOSE ref_cur_ordenes;--cerrar cursor
    estado := 1;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20001, sqlerrm);
END;
/  