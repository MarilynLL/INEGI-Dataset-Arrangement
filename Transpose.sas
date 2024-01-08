/*Se importan los datos obtenidos en la página oficial del INEGI.*/
proc import datafile= '/home/u63456768/SS/B1SS.csv'
	DBMS = csv
	OUT = work.Base1;
	GETNAMES = NO;
RUN;
/*Se importa el diccionario correspondiente a los datos.*/
proc import datafile= '/home/u63456768/SS/Diccionario1.csv'
	DBMS = csv
	OUT = work.Diccionario;
	GETNAMES = YES;
RUN;



/*Se crea una nueva tabla Variables para obtener el nombre de cada variable desde el diccionario.*/
data work.Variables;
	set work.Diccionario;
	length TIPO_D $1;
	TIPO_D = TIPO_DATO;
	drop COLUMNA--CODIGO_VALIDO;
run;

/*Se transponen los nombres de las variables para su posterior acomodo. Con esto se crea una tabla nueva Vartrans que tiene los resultados de esta operación.*/
proc transpose data= work.Variables prefix =VAR out = work.Vartrans;
 var TIPO_D;
run;



proc append base=work.Base1 data = work.Vartrans
FORCE
;

/*Se establece la variable macro numobs que contiene el número de observaciones totales en Base1.*/
data _null_;
    set Base1 end=eof;
    if eof then call symput('numobs',_N_);
run;
%put &=numobs;


/*Se establece la variable macro numvars que contiene el número de variables totales en Base1.*/
data _null_;
    set Variables end=eof;
    if eof then call symput('numvars',_N_);
run;
%put &=numvars;

/*Se realiza el acomodo de los datos por orden ascendente según la variable 2 que corresponde al estado.*/
proc sort data = Base1 out= Pruebaordenada;
by Var2;
run;

/*Se transpone Prueba1 de tal forma que los valores de las variables quedan distribuidas en las columnas, según cada relación que tengan con la clave de la entidad.*/
proc transpose data = Pruebaordenada out= Prueba1;
var Var1--Var11;
by Var2;
run;

/*Se realiza un ordenamiento ascendente con respecto a _NAME_ (nombre de las variables) y Var2.*/
proc sort data = Prueba1 out= Pruebaordenada1;
by _NAME_ Var2;
run;

/*Se realiza un reacomodo de los datos para que los valores queden en una sola columna y conserven la relación con la entidad.*/
proc transpose data = Pruebaordenada1 out= Prueba2(rename=(col1=Valores));
var COL1--COL108;
by _NAME_ Var2;
run;

/*Se agregan otros datos modificables. En esta parte se pueden agregar otras variables como Programa.*/
data work.Plantilla1;
	set work.Prueba2;
    País = "México";
    Año = 2022; 
    keep Var2 _NAME_ Valores País Año;
run;


/*Se limpia la base para quitar todas aquellas observaciones que no poseen un valor.*/
proc sql;
	create table work.Plantilla as
	select *
	from Plantilla1
	where not missing(Valores);
	quit;
	
data _null_;
    set Plantilla end=eof;
    if eof then call symput('obsP',_N_);
run;
%put &=obsP;

data work.Variables;
	set work.Variables;
	do i=1 to &obsP;
	indicardor=i;
	output;
	end;
run;


PROC SQL;
	Create Table PlantillaI as 
	Select * from work.Plantilla as a
	left join work.Variables as b
	on a._NAME_=b.NAME;
	Quit;

data work.Plantilla;
	set work.Plantilla;
	if Tipo_de_Variable= "Numérico" then Valor_numérico = Valores;
	else if Tipo_de_Variable= "Carácter" then Valor_texto = Valores;
	else if Tipo_de_Variables = "Binario" then Valor_binario = Valores;
	drop Valores;
run;

/*Se exporta la tabla final como archivo .xlsx*/
proc export data = work.Plantilla
	outfile = '/home/u63456768/SS/PLANTILLA.csv'
	DBMS = xlsx
	replace;
	sheet = 'Plantilla1';
run;
	





