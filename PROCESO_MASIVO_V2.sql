  select id_tecnico from agendas where id_tecnico not in (select tc.id_tecnico FROM TECNICOS TC 
            INNER JOIN TIPOS_INCIDENCIA_TECNICOS TIT ON (TC.ID_TECNICO=TIT.ID_TECNICO)
            INNER JOIN TIPOS_INCIDENCIA TP ON (TP.ID_TIPO_INCIDENCIA=TIT.ID_TIPO_INCIDENCIA)
            INNER JOIN ZONAS_CUADRILLAS ZC ON (ZC.ID_CUADRILLA=TC.ID_CUADRILLA)
            INNER JOIN ZONAS Z ON (Z.ID_ZONA=ZC.ID_ZONA)
            WHERE TC.BORRADO=0 AND TP.PRIORIDAD=1 AND Z.ID_ZONA=1);
            
            
     --------------------BUSCAR TECNICOS--------------------------
create or replace function BUSCAR_TECNICOS(pr tipos_incidencia.prioridad%type,zona zonas.id_zona%type,dia_inicio date,dia_fin date)
return sys_refcursor
is
TYPE ref_cursor IS REF CURSOR;
cur ref_cursor;
begin
    open cur for select tec.id_tecnico, coalesce(sum(ag.t_atencion),0) ag from agendas ag right join (select tc.id_tecnico FROM TECNICOS TC 
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
       

select buscar_tecnicos(1,1,2,6) from dual;

--------------------------AGENDAR---------------------------------------

create or replace 
FUNCTION GENaGENDA(id_orden NUMBER,id_tec NUMBER,t_aten number,dia_inicio date, dia_fin date)
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
    dbms_output.put_line('--FUNCION AGENDAR ORDENES: '|| dia_inicio);
    for cnt in to_number(to_char(dia_inicio,'D'))..to_number(to_char(dia_fin,'D'))
    loop
       select coalesce(sum(t_atencion),0) into suma from agendas where id_tecnico=id_tec and to_char(fecha,'D')=to_char(cnt);
       dbms_output.put_line('---TNecesitado: ' || t_aten || '|  TDisponible: '|| (8-suma) || ' Dia de la semana: '|| to_char(TO_CHAR(TO_DATE(trunc(dia_inicio)+(cnt-to_number(to_char(dia_inicio,'D'))), 'DD/MM/YYYY'), 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
        if(cnt=to_number(to_char(dia_fin,'D')) and (8-suma)<t_aten)then
            return 0;
        end if;
            
        if((8-suma)>=t_aten and suma>0) then
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
set SERVEROUTPUT on;



----------------------------AGENDAMIENTO VERSION UNO----------------------------------------
set SERVEROUTPUT on;
DECLARE
    ref_cursor SYS_REFCURSOR;
    ref_cursor_tecnicos SYS_REFCURSOR;
    TYPE ordenes IS RECORD(
        id_orden_atencion number,
        TIEMPO_ATENCION number,
        CLIENTE number,
        P_TDAÑO number,
        P_TCLIENTE number,
        ID_ZONA number,
        FECHA_REGISTRO timestamp
    );
    
    TYPE tec_agenda IS RECORD(
        id_tecnico number,
        horas_semanales number
    );
    orden ordenes; --Ordenes de atencion organizadas por prioridad
    tecnico tec_agenda;--Almacenar tecnico diponibles para atender orden organizados por tiempo agendado
    agenda number(1);--Falg indicado de agendamiento exitos de orden
    
    dia_actual date:=to_date('2021-07-3','YYYY-MM-DD');
    inicio_semana number:=2; --Lunes
    fin_semana number:=6; --Viernes
    dia_inicio date;  --Dia desde el cual se empieza a agendar  
    dia_fin date;
    h_semanales_d number;--calculo de horas semanales disponibles por tecnico 
   
BEGIN
    if(to_char(dia_actual,'D')>=inicio_semana and to_char(dia_actual,'D')<fin_semana)then
        dia_inicio:=dia_actual+1;
        dia_fin:=next_day(dia_actual,'VIERNES');
    else
        dia_inicio:=next_day(dia_actual,'LUNES');
        dia_fin:=next_day(dia_inicio,'VIERNES');
    end if;

    ref_cursor:=ORDENES_ORGANIZADAS;---Obtener ordenes de atencion organizadas por prioridad
    loop
        FETCH ref_cursor INTO orden;
        EXIT WHEN ref_cursor%NOTFOUND;
        --DBMS_OUTPUT.PUT_LINE(orden.CLIENTE || '| ' || orden.P_TDAÑO || '| ' || orden.P_TCLIENTE || '| ' || orden.ID_ZONA || '| ' || orden.FECHA_REGISTRO);
        DBMS_OUTPUT.PUT_LINE('Orden  ==> Cliente:' || orden.CLIENTE);
       ref_cursor_tecnicos:=BUSCAR_TECNICOS(orden.P_TDAÑO,orden.ID_ZONA,dia_inicio,dia_fin);---Obtener tecnicos que pueden atender cada orden de atencion zona||tipo incidencia
       loop
            FETCH ref_cursor_tecnicos into tecnico;
            EXIT WHEN ref_cursor_tecnicos%NOTFOUND;
            dbms_output.put_line('-Id tecnico: ' || tecnico.id_tecnico || ' | tAgendado: ' || tecnico.horas_semanales);
            dbms_output.put_line('inicio:' || dia_inicio || ' dia fin: ' || dia_fin || 'resta: ' ||to_char(to_number(to_char(dia_fin,'D'))-to_number(to_char(dia_inicio,'D'))));
            h_semanales_d:=((to_number(to_char(dia_fin,'D'))-to_number(to_char(dia_inicio,'D')))+1)*8;
            if((h_semanales_d-tecnico.horas_semanales)>=orden.tiempo_atencion)then
                agenda:=genagenda(orden.id_orden_atencion,tecnico.id_tecnico,orden.tiempo_atencion,dia_inicio,dia_fin);
                exit when agenda=1;
            end if;
         end loop;
       agenda:=0;--inicializar indicador de estado de agendamiento
   end loop;--Fin loop ordenes
END;
     