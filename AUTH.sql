insert into roles(id_role,nombre) values(1,'ROLE_ADMIN');
insert into roles(id_role,nombre) values(2,'ROLE_USER');
commit;
select * from roles;

INSERT INTO USUARIOS(ID_USUARIO,EMAIL,NOMBRE,NOMBRE_USUARIO,PASSWORD) VALUES (USUARIOS_SEQ.NEXTVAL,'a@a.a','admin','admin','$2a$10$d6dVwkf9H4FpDqLZH9PIZ.Op9GEV4jMAu/J70Am61Ei6qbmDtiIUm');
commit;
select * from usuarios;

INSERT INTO USUARIOS_ROLES(ID_USUARIO,ID_ROL) VALUES (1,1);
INSERT INTO USUARIOS_ROLES(ID_USUARIO,ID_ROL) VALUES (1,2);
commit;
SELECT * FROM USUARIOS_ROLES;


