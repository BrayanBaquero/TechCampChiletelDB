
/*==================================================================================
--------------------------FUNCION FN_AGENDAR_ORDEN----------------------------------
====================================================================================
Funcion encargada de agendar una orden atencción a un tecnico. Se valida en cada día
de la semana que tiempo de disponibilidad tiene el técnico para agendar una orden de
atención.  
-----------------------------------------------------------------------------------*/
create or replace FUNCTION fn_agendar_orden (
    id_orden    ordenes_atencion.id_orden_atencion%TYPE,
    id_tec      tecnicos.id_tecnico%TYPE,
    t_aten      integer,
    dia_inicio  DATE,
    dia_fin     DATE
    ) RETURNS integer
    as $$
    DECLARE
        suma integer; --Suma de horas agendadas diarias
        cont integer; --conteo de filas, para verificar que el dia tenga agenda asignada
        h_agenda_ult timestamp;--Ultima hora del dia en agenda de tecnico
        fecha_insertar date; --Usada para calcular fecha a insertar en tabla agenda
        hi_insertar timestamp; --Usada para calculo de hora inicio a insertar en agenda
        hf_insertar timestamp; --Usada para calcular hora final a insertar en agenda
    BEGIN
        /*Recorrer la semana para validar la disponibilidad diaria del técnico*/
        for cnt in to_char(dia_inicio,'D')..to_char(dia_fin,'D')
        loop
            /*Encortar las horas que se han agendado al tecnico durante el dia y duardarlas en la variable suma*/
           select /*+ index(agendas,idx_agendas_1) */coalesce(sum(t_atencion),0) into suma from agendas where id_tecnico=id_tec and to_char(fecha,'D')=cnt::varchar;
           /*Validar si ya se llego al dia final de la semana y no tiene tiempo disponible en el dia, si es afirmativo no agenda nada */
            if(cnt=to_number(to_char(dia_fin,'D'),'0') and (8-suma)<t_aten)then
                return 0;
            end if;
            /*Se entra en la condicion si hay tiempo disponible en el dia, lo cual fn_agendar_ordena
            la orden ese mismo dia despues de la ultima orden agendada*/    
            if((8-suma)>=t_aten and suma>0) then
                /*Encontrar la ultima hora agendada en el dia*/
                select h_final,fecha into h_agenda_ult,fecha_insertar from agendas where id_tecnico=id_tec and to_char(fecha,'D')=cnt::varchar order by h_final desc fetch first 1 row only;
                hi_insertar:=h_agenda_ult; --Hora de inicio de agendamiento de orden es igual a la hora final de la ultima orden agendada
                hf_insertar:=hi_insertar+(t_aten::varchar||' hours')::interval; ----Hora final de la orden se calcula sumandole a la hora de inicio el tiempo de atencion segun el tipo de incidencia que tenga la orden.
                UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;--Actualizar el campo agendado=1 para indicar que la orden se agendo
                insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (nextval('agendas_seq'),id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
              --  commit;
                return 1;
            /*Si el dia no tiene nada agendado se fn_agendar_ordena la orden ese dia desde las 8 AM*/
            elsif(suma=0)then
                fecha_insertar:=dia_inicio+(((cnt-to_number(to_char(dia_inicio,'D'),'0'))::varchar)||' days')::interval;
                hi_insertar:=fecha_insertar+interval '8 hours';
                hf_insertar:=fecha_insertar+(((8+t_aten)::varchar)||' hours')::interval;
                insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (nextval('agendas_seq'),id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
                UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;
               -- commit;
                return 1;
            end if;
        end loop;
        
        /*
        EXCEPTION
        WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('Error:'||SQLCODE||SQLERRM);
            RAISE NOTICE 'Error:%',sqlstate;
           -- rollback;
            RETURN 0;*/
    END  $$ language plpgsql;
    
/*==================================================================================
--------------------------PROCEDIMIENTO ALMACENADO ORQUESTADOR---------------------
====================================================================================
El procedimiento almacenado de encarga de invocar la otran funciones y aplicar la logica
correspondiente para el agendamiento de las ordenes. Mediente dbsm_lock se establecion un
bloqueo a la ejecución del contenido del procedimiento para inpedir que se ejecute al mismo tiempo
en la misma sesión,o en diferentes seciones.
*/
CREATE OR REPLACE FUNCTION sp_main () 
    returns integer AS $$
    DECLARE
        agenda            INTEGER;--Flag indicado de agendamiento exitoso de orden
    
        dia_actual        DATE;--:=to_date('2021-06-28','YYYY-MM-DD');
        inicio_semana     INTEGER := 2; --Lunes
        fin_semana        INTEGER := 6; --Viernes
        dia_inicio        DATE;  --Dia desde el cual se empieza a fn_agendar_orden  
        dia_fin           DATE;
        h_semanales_d     INTEGER;--calculo de horas semanales disponibles por tecnico 
    
/*==================================================================================
 --------------------------FUNCION FN_ORDENES_ORGANIZADAS---------------------------
====================================================================================
 Función encargada de de organizar ordenes de atencion en base a las siguientes 
 prioridades en el orden descrito.
 --Prioridad tipo de daño
 --Prioridad tipo de cliente
 --Fecha de registro de incidencia (daño)
 ------------------------------------------------------------------------------------*/
        cur_ordenes_organizadas CURSOR FOR  SELECT /*use_hash(ort i ti cl tc) index(i,incidencias_pk)*/ ORT.ID_ORDEN_ATENCION,TI.TIEMPO_ATENCION,CL.ID_CLIENTE CLIENTE,TI.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,CL.ID_ZONA,I.FECHA_REGISTRO FROM ORDENES_ATENCION ORT 
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
        orden RECORD;
/*==================================================================================
 --------------------------FUNCION FN_BUSCAR_TÉCNICOS--------------------------------
====================================================================================
Funcion encargada de buscar los técnicos que pueden atender la incidencia en dependencia
de la zona a la cual este asignada la cuadrilla a la que pertenece y el tipo de incidencia 
que puede resolver. La funcion retorna una lista de tecnicos que pueden atender determinada 
orden de atencion y la cantidad de horas semanales agendadas.
----------------------------------------------------------------------------------------*/
        cur_tecnicos CURSOR(pr          tipos_incidencia.prioridad%TYPE,
                            zona        zonas.id_zona%TYPE,
                            dia_inicio  DATE,
                            dia_fin     DATE) 
                    FOR select tec.id_tecnico, coalesce(sum(ag.t_atencion),0) horas_semanales from agendas ag right join (select /*+ use_hash(tc tit tp zc z)*/ tc.id_tecnico FROM TECNICOS TC 
                    INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
                    INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
                    INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
                    INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
                    WHERE TC.BORRADO=0 AND TP.PRIORIDAD=pr AND Z.ID_ZONA=zona) tec
                    on ag.id_tecnico=tec.id_tecnico
                    and FECHA>=dia_inicio
                    AND FECHA<=dia_fin
                group by tec.id_tecnico
                order by horas_semanales asc;
            tecnico RECORD;
    BEGIN
        dia_actual := current_date;
     
     /*Validar fecha de agendamiento, el dia que se ejecute el SP se valida si esta entra lunes y viernes si es valida la opción 
     la fecha en la cual se va a fn_agendar_orden será desde el día siguiente hasta el viernes. Si se va a relizar el proceso de agendamiento 
     un sabado o domingo, se va a fn_agendar_orden de lunes a viernes de la siguiente semana */
        IF (
            to_number(to_char(dia_actual, 'D'),'0') >= inicio_semana
            AND to_number(to_char(dia_actual, 'D'),'0') < fin_semana
        ) THEN
            dia_inicio := dia_actual + 1;
            dia_fin := (dia_actual-to_char(dia_actual,'D')::integer)+6+interval '1 week';
        ELSE
            dia_inicio :=(dia_actual-to_char(dia_actual,'D')::integer)+2+interval '1 week';
            dia_fin := (dia_inicio-to_char(dia_inicio,'D')::integer)+6;
        END IF;
    -------------------------------------------------------------------------------------
        FOR orden IN cur_ordenes_organizadas LOOP
            OPEN cur_tecnicos(orden.P_TDAÑO, orden.ID_ZONA, dia_inicio, dia_fin);
            LOOP
                FETCH cur_tecnicos INTO tecnico;
                EXIT WHEN NOT FOUND; 
                /*fn_agendar_orden ordenes de atencion llamando a la funcion fn_agendar_orden*/
                --------------------------------------------------------------------
                h_semanales_d := ( ( to_number(to_char(dia_fin, 'D'),'0') - to_number(to_char(dia_inicio, 'D'),'0') ) + 1 ) * 8;
        
                IF ( ( h_semanales_d - tecnico.horas_semanales ) >= orden.tiempo_atencion ) THEN
                    agenda := fn_agendar_orden(orden.id_orden_atencion, tecnico.id_tecnico, orden.tiempo_atencion, dia_inicio, dia_fin);
                    --raise notice 'tecnico: %   tiempo atencion: %',tecnico.id_tecnico,orden.tiempo_atencion;
                    EXIT WHEN agenda = 1;--Salir del loop cuando la orden fue agendada y paras a la siguiente
                END IF;
                ---------------------------------------------------------------------
            END LOOP;--fin loop tecnicos
            CLOSE cur_tecnicos;--cerrar cursor
            agenda := 0;--inicializar indicador de estado de agendamiento
        END LOOP;--Fin FOR for ordenes
        return 1;
    /*
    EXCEPTION
        WHEN OTHERS THEN
        RAISE NOTICE 'Error:%',sqlstate;*/
    end $$ language 'plpgsql';