CREATE OR REPLACE PACKAGE pkg_agendamiento_ordenes IS
    
    FUNCTION fn_ordenes_organizadas RETURN SYS_REFCURSOR;

    FUNCTION fn_buscar_tecnicos (
        pr          tipos_incidencia.prioridad%TYPE,
        zona        zonas.id_zona%TYPE,
        dia_inicio  DATE,
        dia_fin     DATE
    ) RETURN SYS_REFCURSOR;

    FUNCTION fn_agendar_orden (
        id_orden    ordenes_atencion.id_orden_atencion%TYPE,
        id_tec      tecnicos.id_tecnico%TYPE,
        t_aten      NUMBER,
        dia_inicio  DATE,
        dia_fin     DATE
    ) RETURN NUMBER;

    PROCEDURE sp_main (
        estado OUT INTEGER
    );

END;
/

create or replace package body pkg_agendamiento_ordenes is 
    /*==================================================================================
     --------------------------FUNCION FN_ORDENES_ORGANIZADAS---------------------------
    ====================================================================================
     Función encargada de de organizar ordenes de atencion en base a las siguientes 
     prioridades en el orden descrito.
     --Prioridad tipo de daño
     --Prioridad tipo de cliente
     --Fecha de registro de incidencia (daño)
     ------------------------------------------------------------------------------------*/
    function fn_ordenes_organizadas return SYS_REFCURSOR is
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
    end fn_ordenes_organizadas;
       
    
     /*==================================================================================
     --------------------------FUNCION FN_BUSCAR_TÉCNICOS--------------------------------
    ====================================================================================
    Funcion encargada de buscar los técnicos que pueden atender la incidencia en dependencia
    de la zona a la cual este asignada la cuadrilla a la que pertenece y el tipo de incidencia 
    que puede resolver. La funcion retorna una lista de tecnicos que pueden atender determinada 
    orden de atencion y la cantidad de horas semanales agendadas.
    ----------------------------------------------------------------------------------------*/
    FUNCTION fn_buscar_tecnicos (
        pr          tipos_incidencia.prioridad%TYPE,
        zona        zonas.id_zona%TYPE,
        dia_inicio  DATE,
        dia_fin     DATE
    )
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
    end fn_buscar_tecnicos; 
    

     /*==================================================================================
    --------------------------FUNCION FN_AGENDAR_ORDEN----------------------------------
    ====================================================================================
    Funcion encargada de agendar una orden atencción a un tecnico. Se valida en cada día
    de la semana que tiempo de disponibilidad tiene el técnico para agendar una orden de
    atención.  
    -----------------------------------------------------------------------------------*/
   FUNCTION fn_agendar_orden (
    id_orden    ordenes_atencion.id_orden_atencion%TYPE,
    id_tec      tecnicos.id_tecnico%TYPE,
    t_aten      NUMBER,
    dia_inicio  DATE,
    dia_fin     DATE
    ) RETURN NUMBER
    IS
        PRAGMA autonomous_transaction;
        suma number; --Suma de horas agendadas diarias
        cont number; --conteo de filas, para verificar que el dia tenga agenda asignada
        h_agenda_ult timestamp;--Ultima hora del dia en agenda de tecnico
        fecha_insertar date; --Usada para calcular fecha a insertar en tabla agenda
        hi_insertar timestamp; --Usada para calculo de hora inicio a insertar en agenda
        hf_insertar timestamp; --Usada para calcular hora final a insertar en agenda
    BEGIN
        /*Recorrer la semana para validar la disponibilidad diaria del técnico*/
        for cnt in to_number(to_char(dia_inicio,'D'))..to_number(to_char(dia_fin,'D'))
        loop
            /*Encortar las horas que se han agendado al tecnico durante el dia y duardarlas en la variable suma*/
           select /*+ index(agendas,idx_agendas_1) */coalesce(sum(t_atencion),0) into suma from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt);
           /*Validar si ya se llego al dia final de la semana y no tiene tiempo disponible en el dia, si es afirmativo no agenda nada */
            if(cnt=to_number(to_char(dia_fin,'D')) and (8-suma)<t_aten)then
                return 0;
            end if;
            /*Se entra en la condicion si hay tiempo disponible en el dia, lo cual fn_agendar_ordena
            la orden ese mismo dia despues de la ultima orden agendada*/    
            if((8-suma)>=t_aten and suma>0) then
                /*Encontrar la ultima hora agendada en el dia*/
                select h_final into h_agenda_ult from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt) order by h_final desc fetch first 1 row only;
                fecha_insertar:=trunc(h_agenda_ult);--calcular el campo Fecha de agenda
                hi_insertar:=h_agenda_ult; --Hora de inicio de agendamiento de orden es igual a la hora final de la ultima orden agendada
                hf_insertar:=hi_insertar+(t_aten/24); ----Hora final de la orden se calcula sumandole a la hora de inicio el tiempo de atencion segun el tipo de incidencia que tenga la orden.
                UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;--Actualizar el campo agendado=1 para indicar que la orden se agendo
                insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (agendas_seq.nextval,id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
                commit;
                return 1;
            /*Si el dia no tiene nada agendado se fn_agendar_ordena la orden ese dia desde las 8 AM*/
            elsif(suma=0)then
                fecha_insertar:=trunc(dia_inicio)+(cnt-to_number(to_char(dia_inicio,'D')));
                hi_insertar:=fecha_insertar+(8/24);
                hf_insertar:=fecha_insertar+((8+t_aten)/24);
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
    END fn_agendar_orden;
    
    
    /*==================================================================================
    --------------------------PROCEDIMIENTO ALMACENADO ORQUESTADOR---------------------
    ====================================================================================
    El procedimiento almacenado de encarga de invocar la otran funciones y aplicar la logica
    correspondiente para el agendamiento de las ordenes. Mediente dbsm_lock se establecion un
    bloqueo a la ejecución del contenido del procedimiento para inpedir que se ejecute al mismo tiempo
    en la misma sesión,o en diferentes seciones.
    */
        PROCEDURE sp_main (
            estado OUT INTEGER
        ) IS
    
        ref_cur_ordenes   SYS_REFCURSOR;--Cursor para recibir valores de la funcion ORDENES_ATENCION 
        ref_cur_tecnicos  SYS_REFCURSOR;--Cursor para recibir resultado de funcion fn_buscar_tecnicos
    
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
        agenda            NUMBER(1);--Falg indicado de agendamiento exitoso de orden
    
        dia_actual        DATE;--:=to_date('2021-06-28','YYYY-MM-DD');
        inicio_semana     NUMBER := 2; --Lunes
        fin_semana        NUMBER := 6; --Viernes
        dia_inicio        DATE;  --Dia desde el cual se empieza a fn_agendar_orden  
        dia_fin           DATE;
        h_semanales_d     NUMBER;--calculo de horas semanales disponibles por tecnico 
        
        id_Bk VARCHAR2(200); --Id del bloqueo dbms_block
        state_Bk number;    --Estado del bloqueo
        release_bk number;
    BEGIN
    DBMS_LOCK.allocate_unique('Block_Agenda', id_Bk);
    state_Bk:=DBMS_LOCK.request(id_Bk, 6);
    IF  state_Bk=0 THEN ----Condicion para que no se realice el agendamiento si ya hay un proceso ejecutandose
            dia_actual := sysdate;
         
         /*Validar fecha de agendamiento, el dia que se ejecute el SP se valida si esta entra lunes y viernes si es valida la opción 
         la fecha en la cual se va a fn_agendar_orden será desde el día siguiente hasta el viernes. Si se va a relizar el proceso de agendamiento 
         un sabado o domingo, se va a fn_agendar_orden de lunes a viernes de la siguiente semana */
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
            ref_cur_ordenes := fn_ordenes_organizadas;---Obtener ordenes de atencion organizadas por prioridad
            LOOP
                FETCH ref_cur_ordenes BULK COLLECT INTO orden;
                FOR i IN 1..orden.count LOOP
                    ref_cur_tecnicos := fn_buscar_tecnicos(orden(i).p_tdaño, orden(i).id_zona, dia_inicio, dia_fin);---Obtener tecnicos que pueden atender cada orden de atencion zona||tipo incidencia
                    LOOP
                        FETCH ref_cur_tecnicos INTO tecnico;
                        EXIT WHEN ref_cur_tecnicos%notfound; 
                        /*fn_agendar_orden ordenes de atencion llamando a la funcion fn_agendar_orden*/
                        --------------------------------------------------------------------
                        h_semanales_d := ( ( to_number(to_char(dia_fin, 'D')) - to_number(to_char(dia_inicio, 'D')) ) + 1 ) * 8;
        
                        IF ( ( h_semanales_d - tecnico.horas_semanales ) >= orden(i).tiempo_atencion ) THEN
                            agenda := fn_agendar_orden(orden(i).id_orden_atencion, tecnico.id_tecnico, orden(i).tiempo_atencion, dia_inicio, dia_fin);
        
                            EXIT WHEN agenda = 1;--Salir del loop cuando la orden fue agendada y paras a la siguiente
                        END IF;
                        ---------------------------------------------------------------------
                    END LOOP;--fin loop tecnicos
                    CLOSE ref_cur_tecnicos;--cerrar cursor
                    agenda := 0;--inicializar indicador de estado de agendamiento
                END LOOP;--Fin FOR for ordenes
                EXIT WHEN ref_cur_ordenes%notfound;--salir Loop cursor ordenes
            END LOOP;--Fin loop bulk ordenes
            CLOSE ref_cur_ordenes;--cerrar cursor
            estado := 1;
            release_bk:= DBMS_LOCK.release(substr(id_Bk,1,10));---liberar bloqueo
        ELSE
             estado := 0;--indicar que ya existe otro procedimiento en ejecución
             
        END IF;--fin condicion de ejecución unica
    
    EXCEPTION
        WHEN OTHERS THEN
            release_bk:= DBMS_LOCK.release(substr(id_Bk,1,10));
            raise_application_error(-20001, sqlerrm);
    END sp_main;
    
end;
/