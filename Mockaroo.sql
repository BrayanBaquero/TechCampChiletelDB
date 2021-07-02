-------------------------ZONAS------------------------------------------------------------------
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Valdivia');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Corral');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Lanco');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Los lagos');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Marfil');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Maviqina');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Paillaco');
insert into zonas(id_zona,nombre) values (zonas_seq.nextval,'Panquipulli');


-------------------------TIPOS DE CLIENTE-------------------------------------------
INSERT INTO TIPOS_CLIENTE (ID_TIPO_CLIENTE,NOMBRE,PRIORIDAD) VALUES (TIPOS_CLIENTE_SEQ.nextval,'Hospitales',1);
INSERT INTO TIPOS_CLIENTE (ID_TIPO_CLIENTE,NOMBRE,PRIORIDAD) VALUES (TIPOS_CLIENTE_SEQ.nextval,'Entidades gubernamentales',2);
INSERT INTO TIPOS_CLIENTE (ID_TIPO_CLIENTE,NOMBRE,PRIORIDAD) VALUES (TIPOS_CLIENTE_SEQ.nextval,'Personas VIP',3);
INSERT INTO TIPOS_CLIENTE (ID_TIPO_CLIENTE,NOMBRE,PRIORIDAD) VALUES (TIPOS_CLIENTE_SEQ.nextval,'Empresas de taxi',4);
INSERT INTO TIPOS_CLIENTE (ID_TIPO_CLIENTE,NOMBRE,PRIORIDAD) VALUES (TIPOS_CLIENTE_SEQ.nextval,'Persona normal',5);


-------------------------------TIPOS INCIDENCIA-------------------------------------
INSERT INTO TIPOS_INCIDENCIA (ID_TIPO_INCIDENCIA,NOMBRE,PRIORIDAD,TIEMPO_ATENCION) VALUES (TIPOS_INCIDENCIA_SEQ.NEXTVAL,'total',1,1);
INSERT INTO TIPOS_INCIDENCIA (ID_TIPO_INCIDENCIA,NOMBRE,PRIORIDAD,TIEMPO_ATENCION) VALUES (TIPOS_INCIDENCIA_SEQ.NEXTVAL,'parcial',2,2);
INSERT INTO TIPOS_INCIDENCIA (ID_TIPO_INCIDENCIA,NOMBRE,PRIORIDAD,TIEMPO_ATENCION) VALUES (TIPOS_INCIDENCIA_SEQ.NEXTVAL,'esporadica',3,3);



------------------------CUADRILLAS----------------------------------------------------------------
insert into Cuadrillas (id_cuadrilla, nombre, borrado) values (cuadrillas_seq.nextval, 'Hyundai', 0);
insert into Cuadrillas (id_cuadrilla, nombre, borrado) values (cuadrillas_seq.nextval, 'Audi', 0);
insert into Cuadrillas (id_cuadrilla, nombre, borrado) values (cuadrillas_seq.nextval, 'Nissan', 0);
insert into Cuadrillas (id_cuadrilla, nombre, borrado) values (cuadrillas_seq.nextval, 'Mercury', 0);
insert into Cuadrillas (id_cuadrilla, nombre, borrado) values (cuadrillas_seq.nextval, 'Pontiac', 0);



-------------------TECNICOS-------------------------------------------------------------
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Carmelle', 'Kelshaw', '5286695043', 'ckelshaw0@usa.gov', '8948557556', '212 Harper Road', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Cristin', 'Doerr', '3182125214', 'cdoerr1@odnoklassniki.ru', '3903759181', '465 Elka Hill', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Ula', 'Drewes', '4804440666', 'udrewes2@shareasale.com', '5294547127', '1973 Elka Crossing', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Brannon', 'Ghelardoni', '2720461903', 'bghelardoni3@icq.com', '4738417590', '91 Londonderry Parkway', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Deni', 'Gosney', '1102616125', 'dgosney4@uol.com.br', '4762939476', '2 Nelson Lane', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Rivkah', 'Tollerfield', '6522970066', 'rtollerfield5@addthis.com', '5361651483', '812 Anniversary Trail', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Godart', 'Majury', '1313799300', 'gmajury6@etsy.com', '1901068449', '51 Thackeray Way', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Olenka', 'Klaes', '7781239636', 'oklaes7@xing.com', '3377046906', '850 Lighthouse Bay Lane', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Rancell', 'Petrecz', '8366550605', 'rpetrecz8@icq.com', '1551531256', '826 Roxbury Trail', 1, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Alonzo', 'Gammade', '3406392679', 'agammade9@alibaba.com', '1551012045', '2 Schlimgen Court', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Julee', 'Spoor', '4955634699', 'jspoora@phpbb.com', '8011230199', '77 Utah Alley', 1, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Kristoforo', 'Fowkes', '1109913184', 'kfowkesb@cnbc.com', '4928835820', '042 Rockefeller Avenue', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Rhea', 'Corsar', '3769677730', 'rcorsarc@google.com.br', '5449415075', '70334 Express Alley', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Teador', 'Dorn', '2850675660', 'tdornd@un.org', '5116547953', '65 Sugar Drive', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Emilee', 'Burles', '2584613026', 'eburlese@telegraph.co.uk', '8086510586', '1506 Duke Lane', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Antoinette', 'Kiddle', '7881577673', 'akiddlef@psu.edu', '9679471200', '71 Prairieview Hill', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Rochella', 'Kauscher', '4115544880', 'rkauscherg@si.edu', '4057547627', '32517 Chinook Street', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Eziechiele', 'Ketteridge', '6757374846', 'eketteridgeh@foxnews.com', '8695509626', '87874 Oakridge Parkway', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Purcell', 'Pettigree', '4082143858', 'ppettigreei@wikia.com', '9827282507', '6787 Scofield Road', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Tabby', 'Le Guin', '3663378896', 'tleguinj@studiopress.com', '2934137678', '220 Carey Circle', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Vivianne', 'Fowlds', '7219128681', 'vfowldsk@cdc.gov', '5727396689', '91751 Shoshone Point', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Emylee', 'Gumby', '7719057732', 'egumbyl@fastcompany.com', '6057250395', '7808 Cottonwood Avenue', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Waylon', 'Chalcroft', '6717130229', 'wchalcroftm@examiner.com', '8574468159', '081 Hauk Lane', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Florian', 'Childerhouse', '5833083117', 'fchilderhousen@cocolog-nifty.com', '2651500427', '57713 Meadow Ridge Road', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Evelyn', 'Just', '3844893032', 'ejusto@admin.ch', '7092997741', '3063 Charing Cross Junction', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Tonye', 'McGlone', '1662311885', 'tmcglonep@geocities.com', '3986557703', '433 Nelson Way', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Domini', 'Doelle', '1021878553', 'ddoelleq@mozilla.com', '2256673776', '20669 Dorton Pass', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Waldon', 'Shird', '5345518025', 'wshirdr@rakuten.co.jp', '7141505939', '733 Daystar Drive', 1, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Nicolas', 'Nacci', '4808137798', 'nnaccis@squarespace.com', '6611771619', '2612 Arizona Pass', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Aldous', 'Chaloner', '5075464343', 'achalonert@surveymonkey.com', '5374877906', '65783 Pearson Trail', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Ginger', 'Linnemann', '7449662035', 'glinnemannu@craigslist.org', '3751118079', '849 Evergreen Junction', 1, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Fionnula', 'Munn', '7964870092', 'fmunnv@joomla.org', '9893776477', '27533 Tennessee Parkway', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Kayne', 'Caffery', '4223750402', 'kcafferyw@dropbox.com', '6101357734', '1 Schiller Crossing', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Cobb', 'De Normanville', '6999251754', 'cdenormanvillex@wired.com', '8851818721', '53 Straubel Circle', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Cordelia', 'Moloney', '1136083243', 'cmoloneyy@netscape.com', '1011849795', '66388 Havey Point', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Kellen', 'Wayper', '7594398602', 'kwayperz@princeton.edu', '2134965272', '5 Lotheville Hill', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Paula', 'Gamwell', '0751230057', 'pgamwell10@techcrunch.com', '5094183077', '96 Jay Alley', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Carleen', 'Niles', '1033159840', 'cniles11@sohu.com', '3563917487', '21 Badeau Pass', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Brew', 'McMenamin', '1617762059', 'bmcmenamin12@salon.com', '8045655924', '8 Pennsylvania Plaza', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Minda', 'Jouannin', '8635544331', 'mjouannin13@icq.com', '8758891042', '5 Hudson Pass', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Veriee', 'Nimmo', '3816323758', 'vnimmo14@icq.com', '5389004813', '0464 Merchant Hill', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Glen', 'Hickeringill', '7791160358', 'ghickeringill15@creativecommons.org', '3195059973', '90 Merrick Place', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Jocko', 'Lohrensen', '5440852395', 'jlohrensen16@jiathis.com', '3654987366', '1348 Golden Leaf Park', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Sutherlan', 'Bene', '9172972955', 'sbene17@hhs.gov', '7704070887', '65247 Amoth Pass', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Rori', 'Brosch', '2443413799', 'rbrosch18@salon.com', '8841082081', '06 Nobel Pass', 2, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Bridget', 'Darbon', '3789834505', 'bdarbon19@tinyurl.com', '4454062004', '748 Independence Trail', 3, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Judon', 'Harroway', '5379445160', 'jharroway1a@ezinearticles.com', '9726344265', '77 Granby Plaza', 5, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Annis', 'Jouanny', '6805884594', 'ajouanny1b@cbc.ca', '4038937344', '9 Raven Plaza', 1, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Win', 'Feakins', '3703322551', 'wfeakins1c@sina.com.cn', '7701439428', '46 Burrows Plaza', 4, 0);
insert into Tecnicos (id_tecnico, nombre, apellido, identificacion, email, telefono, direccion, id_cuadrilla, borrado) values (tecnicos_seq.nextval, 'Zaria', 'Gladtbach', '0397870507', 'zgladtbach1d@booking.com', '6187692519', '18 Fairfield Circle', 3, 0);

-----------------------ZONAS CUADRILLAS---------------------------
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (6, 5);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (1, 2);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (1, 3);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (3, 2);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (4, 5);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (3, 1);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (5, 4);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (6, 4);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (2, 2);
insert into zonas_cuadrillas (id_zona, id_cuadrilla) values (5, 3);

--------------------------TECNICO_TIPOS_INCIDENCIA-------------
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (45, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (1, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (19, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (7, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (21, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (1, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (6, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (44, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (3, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (10, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (24, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (14, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (14, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (15, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (48, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (3, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (16, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (43, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (29, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (28, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (39, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (33, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (33, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (4, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (22, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (2, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (9, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (37, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (34, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (41, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (30, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (3, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (25, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (25, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (12, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (20, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (46, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (44, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (29, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (4, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (33, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (39, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (17, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (26, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (2, 3);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (12, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (30, 1);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (19, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (38, 2);
insert into tipos_incidencia_tecnicos (id_tecnico, id_tipo_incidencia) values (5, 3);






--------------CLIENTES-------------------
@CLIENTES.sql;

-----------------------------INCIDENCIAS------------------------------------
@INCIDENCIAS.SQL

------------------------------ORDENES---------------------------------------
@ORDENES_ATENCION.sql


------------------------------AGENDA--------------------------------------
