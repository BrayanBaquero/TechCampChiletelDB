
----------ORDENES DE ATENCION ORGANIZADAS POR PRIORIDADES----_----------
CREATE OR REPLACE FUNCTION ORDENES_ORGANIZADAS RETURN SYS_REFCURSOR
IS
    TYPE ref_cursor IS REF CURSOR;
    v_ref ref_cursor;
BEGIN
    OPEN v_ref FOR SELECT ORT.ID_ORDEN_ATENCION,TI.TIEMPO_ATENCION,CL.ID_CLIENTE CLIENTE,TI.PRIORIDAD P_TDAÑO,TC.PRIORIDAD P_TCLIENTE,CL.ID_ZONA,I.FECHA_REGISTRO FROM ORDENES_ATENCION ORT 
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

----------------------BUSCAR TECNICO POR ZONA DE ATENCION Y TIPO DE DAÑO-----------
CREATE OR REPLACE 
FUNCTION BUSCAR_TECNICOS(P_TINCIDENCIA NUMBER,ZONA NUMBER)
RETURN SYS_REFCURSOR
IS
    TYPE ref_cursor IS REF CURSOR;
    v_ref ref_cursor;
BEGIN
    OPEN v_ref FOR SELECT TC.ID_TECNICO FROM TECNICOS TC 
            INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
            INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
            INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
            INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
            WHERE TC.BORRADO=0 AND TP.PRIORIDAD=P_TINCIDENCIA AND Z.ID_ZONA=ZONA;
    RETURN v_ref;
END;
-----------------------------------------------------------------------------------------------
SELECT BUSCAR_TECNICOS(1,1) FROM DUAL;
-------------------------------------------------------------------------------------------

CREATE OR REPLACE
FUNCTION AGENDAR(id_orden NUMBER,id_tec NUMBER,t_atencion number)
RETURN NUMBER
IS
    TYPE ref_cursor IS REF CURSOR;
    h_inicio timestamp;
    h_final timestamp;
    v_ref ref_cursor;
    fecha_actual date;
    PR timestamp;
    ant timestamp;
    resta number;
BEGIN
    fecha_actual:=to_char(sysdate);
    --fecha_ultimodia:=to_char(fecha_actual,'D');
    OPEN v_ref FOR SELECT h_inicio,h_final from agendas where id_tecnico=id_tec and TO_CHAR(FECHA,'D')>=TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<6 order by h_final asc;
    loop
        fetch v_ref into h_inicio,h_final;
        EXIT WHEN v_ref%NOTFOUND;
        dbms_output.put_line('hora inicio: ' || h_inicio ||'hora final: ' || h_final || ' idtecnico: ' || id_tec);
        ant:=pr;
        pr:=h_final;
        --resta:=round((to_date(h_final,'DD-MM-YYYY hh24:mi:ss')-to_date(h_inicio,'DD-MM-YYYY hh24:mi:ss'))*24);
        IF(v_ref%ROWCOUNT>1 and to_char(h_inicio,'D')=to_char(ant,'D')) THEN
          resta:=trunc(to_number(to_char(h_inicio,'hh24'))-to_number(to_char(ant,'hh24'))); --h_inicio presente - h_final anterior
          dbms_output.put_line('Resta: : ' || resta);
        END IF;
        
    end loop;
    return 1;
    --RETURN v_ref;
END;

SELECT AGENDAR(1,2,3) FROM DUAL;

--------------------------------------------AGENDAMIENTO DE ORDENES A TECNICOS-----------------------------------------------------------

create or replace 
FUNCTION GENaGENDA(id_orden NUMBER,id_tec NUMBER,t_aten number)
RETURN NUMBER
IS
    PRAGMA autonomous_transaction;
    suma number; --Suma de horas agendadas diarias
    cont number; --contero de filas, para verificar que el dia tenga agenda asignada
    inicio_semana number;
    fin_semana number;
    dia_actual number;
    h_init number; --Hora inicio jornada laboral
    h_fin number; --Hora fin jornada laboral
    h_agenda_ult timestamp;--Ultima hora del dia en agenda de tecnico
    fecha_insertar date; --Usada para calcular fecha a insertar en tabla agenda
    hi_insertar timestamp; --Usada para calculo de hora inicio a insertar en agenda
    hf_insertar timestamp; --Usada para calcular hora final a insertar en agenda
BEGIN
    dbms_output.put_line('-FUNCION AGENDAR ORDENES');
    inicio_semana:=2; --Lunes
    fin_semana:=6; --Viernes
    dia_actual:=to_char(sysdate,'D');
    h_init:=8;
    h_fin:=16;

    for cnt in dia_actual..fin_semana
    loop
        select count(*) into cont from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt);
        if(cont<>0) then
            select sum(t_atencion) into suma from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt);
            dbms_output.put_line('---TNecesitado: ' || t_aten || '|  TDisponible: '|| (8-suma) || ' Dia de la semana: '|| to_char(TO_CHAR(TO_DATE(trunc(sysdate)+(cnt-dia_actual), 'DD/MM/YYYY'), 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
            if((8-suma)>=t_aten) then
                select h_final into h_agenda_ult from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt) order by fecha desc fetch first 1 row only;
                fecha_insertar:=trunc(h_agenda_ult);
                hi_insertar:=h_agenda_ult;
                hf_insertar:=hi_insertar+(t_aten/24);
                dbms_output.put_line('--------UltimaHora: ' || h_agenda_ult);
                dbms_output.put_line('--------Dia disponible=>' || 'Fecha: ' || fecha_insertar || ' | Hora inicio: ' || hi_insertar || ' | Hora final: ' ||  hf_insertar);
                UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;
                insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (agendas_seq.nextval,id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
                commit;
                return 1;
            end if;
        else
            fecha_insertar:=trunc(sysdate)+(cnt-dia_actual);
            hi_insertar:=fecha_insertar+(8/24);
            hf_insertar:=fecha_insertar+((8+t_aten)/24);
            dbms_output.put_line('--------Nuevo dia=>   ' ||'Tecnico: ' || id_tec|| ' | Fecha: ' || fecha_insertar || ' | Hora inicio: ' || hi_insertar || ' | Hora final: ' ||  hf_insertar);
            insert into agendas(id_agenda,id_orden_atencion,id_tecnico,h_final,h_inicio,fecha,t_atencion) values (agendas_seq.nextval,id_orden,id_tec,hf_insertar,hi_insertar,fecha_insertar,t_aten);
            UPDATE ordenes_atencion set agendado=1 where id_orden_atencion=id_orden;
            commit;
            return 1;
        end if;
    end loop;

    RETURN 1;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error'||SQLCODE||SQLERRM);
        rollback;
        RETURN 0;
END;

/

-----------------------------------------------------------------------------------------------
set SERVEROUTPUT on;
DECLARE
    ref_cursor SYS_REFCURSOR;
    ref_cursor_tecnicos SYS_REFCURSOR;
    TYPE ordenes IS RECORD(
        CLIENTE number,
        P_TDAÑO number,
        P_TCLIENTE number,
        ID_ZONA number,
        FECHA_REGISTRO timestamp
    );
    
    orden ordenes;
    tecnico number;
BEGIN
    ref_cursor:=ORDENES_ORGANIZADAS;
    
    loop
        FETCH ref_cursor INTO orden;
        EXIT WHEN ref_cursor%NOTFOUND;
       -- DBMS_OUTPUT.PUT_LINE(orden.CLIENTE || '| ' || orden.P_TDAÑO || '| ' || orden.P_TCLIENTE || '| ' || orden.ID_ZONA || '| ' || orden.FECHA_REGISTRO);
        DBMS_OUTPUT.PUT_LINE('Cliente:' || orden.CLIENTE);
       ref_cursor_tecnicos:=BUSCAR_TECNICOS(orden.P_TDAÑO,orden.ID_ZONA);
       loop
            FETCH ref_cursor_tecnicos into tecnico;
            EXIT WHEN ref_cursor_tecnicos%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('--id tecnico:' || tecnico);
            -----Agendar-----
            
       end loop;
       
    end loop;
END;



----------------------------AGENDAMIENTO VERSION UNO----------------------------------------
DECLARE
    ref_cursor SYS_REFCURSOR;
    ref_cursor_tecnicos SYS_REFCURSOR;
    refc_tecnico_tdisponible sys_refCursor;
    TYPE ordenes IS RECORD(
        id_orden_atencion number,
        TIEMPO_ATENCION number,
        CLIENTE number,
        P_TDAÑO number,
        P_TCLIENTE number,
        ID_ZONA number,
        FECHA_REGISTRO timestamp
    );
    
    TYPE AG_TEC_TIEMPO IS RECORD(
        id_tecnico number,
        horas_semanales number
    );
    orden ordenes; --Ordenes de atencion organizadas por prioridad
    htecnico AG_TEC_TIEMPO; --
    Q_Tecnicos_tiempo varchar2(500);
    Q_Id_tecnico varchar2(500);
    tecnico number;
    agenda number;
    cont_horas number;
   
BEGIN
    ref_cursor:=ORDENES_ORGANIZADAS;---Obtener ordenes de atencion organizadas por prioridad
    loop
        FETCH ref_cursor INTO orden;
        EXIT WHEN ref_cursor%NOTFOUND;
       -- DBMS_OUTPUT.PUT_LINE(orden.CLIENTE || '| ' || orden.P_TDAÑO || '| ' || orden.P_TCLIENTE || '| ' || orden.ID_ZONA || '| ' || orden.FECHA_REGISTRO);
        DBMS_OUTPUT.PUT_LINE('Orden  ==> Cliente:' || orden.CLIENTE);
       ref_cursor_tecnicos:=BUSCAR_TECNICOS(orden.P_TDAÑO,orden.ID_ZONA);---Obtener tecnicos que pueden atender cada orden de atencion zona||tipo incidencia
       loop
            FETCH ref_cursor_tecnicos into tecnico;
            EXIT WHEN ref_cursor_tecnicos%NOTFOUND;
            select coalesce(sum(t_atencion),0) into cont_horas from agendas where id_tecnico=tecnico and TO_CHAR(FECHA,'D')>=TO_CHAR(SYSDATE,'D') AND TO_CHAR(FECHA,'D')<=6;
            dbms_output.put_line('-id tecnico: ' || tecnico ||' | Horas en agenda: '|| cont_horas);
            if(cont_horas=0)then
                agenda:=genagenda(orden.id_orden_atencion,tecnico,orden.tiempo_atencion);
                exit when agenda=1;
            end if;
            Q_Id_Tecnico:=Q_Id_Tecnico || 'id_tecnico=' || tecnico || ' or ';--Query dinamica para obtener el tiempo disponible de cada tecnico ordenado de menor a mayor (concatenar id tecnicos)
       end loop;
       
       --Si no se a agendado ninguna orden continuar el proceso
       if(agenda=0)then
           Q_Id_Tecnico:=rtrim(Q_Id_Tecnico,' or ');---Quitar ' or ' que queda de ultima iteracion
           --Armar query con los where para buscar tecnicos y organizarlos por tiempo de agenda
           Q_Tecnicos_tiempo:='SELECT ID_TECNICO,SUM(T_ATENCION) HORAS_SEMANALES FROM AGENDAS  WHERE 
                                    '||Q_Id_Tecnico||' and 
                                    TO_CHAR(FECHA,''D'')>=TO_CHAR(SYSDATE,''D'') AND 
                                    TO_CHAR(FECHA,''D'')<=6
                                GROUP BY ID_TECNICO
                                ORDER BY HORAS_SEMANALES ASC';
           Q_Id_Tecnico:='';--Limpiar para proxima iteracion
           --DBMS_OUTPUT.PUT_LINE('Query: ' || Q_Tecnicos_tiempo);
           
           open refc_tecnico_tdisponible for Q_Tecnicos_tiempo;
           loop 
                fetch refc_tecnico_tdisponible into htecnico;
                --DBMS_OUTPUT.PUT_LINE('count: '|| refc_tecnico_tdisponible%ROWCOUNT);
                EXIT WHEN refc_tecnico_tdisponible%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('---id tecnico: ' || htecnico.id_tecnico || ' | horas trabajadas: ' || htecnico.horas_semanales);
                agenda:=genagenda(orden.id_orden_atencion,htecnico.id_tecnico,orden.tiempo_atencion);
                EXIT WHEN AGENDA=1; --Salir del loop si se agendó
           end loop;
       end if;
       agenda:=0;--inicializar indicador de estado de agendamiento
   end loop;--Fin loop ordenes
END;


delete from agendas;
update ordenes_atencion set agendado=0;
