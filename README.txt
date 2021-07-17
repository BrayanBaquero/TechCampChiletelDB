
Ejecución

1.Abrir la terminal y en la carpeta DB.
2.Logearce en oracle como dba con la siguiente linea.
	sqlplus / as sysdba
3.Ejecutar el siguiente comando.
	@build.sql

Se crearan el usuario de la base de datos con sus privilegios, se creara el esquema de datos 
y cargaran datos de prueba. Si se quieren cambiar los datos de prueba modificar la linea 30 
del script build.sql teniendo las sguiente opciones.
@main.sql  ->Datos basicos, 1000 clientes, tablas parametricas.
@mainV1	   ->Datos medianos, 1000 clientes, tablas parametricas, 50 tecnicos, 100 incidencias y ordenes de atención.
@mainV2	   ->Datos grande, 10000 clientes, tablas parametricas, 50 tecnicos, 1000 incidencias y ordenes de atención

