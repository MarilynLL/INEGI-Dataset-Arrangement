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

/*Se establece la variable macro numobs que contiene el número de observaciones totales en Base1.*/
data _null_;
    set Base1 end=eof;
    if eof then call symput('numobs',_N_);
run;
%put &=numobs;


/*Is es una tabla auxiliar que lleva la cuenta de las observaciones de la tabla correspondiente.*/
data work.is;
	i= 0;
	do while (i<= &numobs);
	i= i+1;
	output;
	end;
	run;
	
/* Combinamos con merge, la base inicial con is.*/
data work.Base1;
	merge Base1 is;
run;

/*Se modifica la base 1 para quitarle los encanbezados que tenía en el archivo csv, para dejar el nombre de la variable com Varn donde n es el número de variables.*/
data work.Base1;
	set work.Base1;
	if (i=1) then delete;
	drop i;
run;

/*Se crea una nueva tabla Variables para obtener el nombre de cada variable desde el diccionario.*/
data work.Variables;
	set work.Diccionario;
	ID_Variable = COLUMNA;
	drop COLUMNA--CODIGO_VALIDO;
run;

/*Se transponen los nombres de las variables para su posterior acomodo. Con esto se crea una tabla nueva Vartrans que tiene los resultados de esta operación.*/
proc transpose data= work.Variables out = work.Vartrans;
 var ID_VARIABLE;
run;

/*Se establece la variable macro numvars, que contiene el número de variables totales.*/
data _null_;
    set Variables end=eof;
    if eof then call symput('numvars',_N_);
run;
%put &=numvars;

/*Se crea una nueva tabla Tipos con los tipos de dato según lo presentado en el diccionario.*/
data work.Tipos;
	set work.Diccionario;
	
           	Tipo = TIPO_DATO; 	
	drop COLUMNA--CODIGO_VALIDO;
run;


/*Se transponen los tipos de variables dando origen a la tabla Tipostrans.*/
proc transpose data= work.Tipos out = work.Tipostrans;
 var Tipo;
run;

data work.TipoF;
	set work.TiposTRans;
	i=1;
	do while (i <= &numobs);
           	Tipo = COL1;
           	i= i+1;
		output;
		end;
		drop _NAME_ Tipo;
run;

data work.VarsF;
	set work.Vartrans;
	i=1;
	do while (i <= &numobs);
           	Tipo = TT1;
           	i= i+1;
		output;
		end;
		drop i TT1 Tipo;
run;


%macro rename_col_T(start=1,stop=&numvars);
	%do n= &start %to &stop;
	data TipoF;
	set TipoF;
	rename COL&n = TT&n;
	%end;
%mend rename_col_T;

%rename_col_T(start=1,stop=&numvars)



%macro llenadoD(start=1,stop=&numvars);
	%do n = &start %to &stop;
		data Datos&n;
		i=1;
	do while (i <= &numobs);
           	País = 'México';
           	Año = 2022;
           	i= i+1;
		output;
		end;
		keep País Año;
		run;
	
	%end;
%mend llenadoD;

%llenadoD(start=1,stop=&numvars)

%macro ID(start=1,stop=&numvars);
	%do n=&start %to &stop;
	data ID&n;
	set VarsF;
	ID_Variable = COL&n;
	keep ID_Variable;
	run;
	%end;
%mend ID;

%ID(start=1,stop=&numvars)

%macro asignar_tipo(start=1,stop=&numvars);
	%do n=&start %to &stop;
	data Tipo&n;
	set TipoF;
	Tipo_de_Variable = TT&n;
	keep Tipo_de_Variable;
	run;
	%end;
%mend asignar_tipo;

%asignar_tipo(start=1,stop=&numvars)

%macro Prueba2(start=1,stop=&numvars);
	%do n = &start %to &stop;
		data work.Pruebados&n;
	merge Base1 Tipo&n; 
run;
	%end;
%mend Prueba2;
%Prueba2(start=1,stop=&numvars)


%macro llenar_valores(start=1,stop=&numvars);
	%do n= &start %to &stop;
	data Valores&n;
	set Pruebados&n;
	if Tipo_de_Variable= "Numérico" then Valor_numérico = Var&n;
	else if Tipo_de_Variable= "Carácter" then Valor_texto = Var&n;
	else if Tipo_de_Variables = "Binario" then Valor_binario = Var&n;
	keep Valor_numérico Valor_texto Valor_binario;
	%end;
%mend llenar_valores;
%llenar_valores(start=1,stop=&numvars)


%macro MicroPlantilla(start=1,stop=&numvars);
	%do n = &start %to &stop;
		data work.Plantilla&n;
	merge ID&n Tipo&n Datos&n Valores&n;
	
run;
	
	%end;
%mend MicroPlantilla;

%MicroPlantilla(start=1,stop=&numvars)

%macro crearPlantilla(start=1,stop=&numvars);
	%do n = &start %to &stop;
	proc append base = work.Plantilla data= Plantilla&n
	FORCE;
run;
	%end;
%mend crearPlantilla;

%crearPlantilla(start=1,stop=&numvars)

/*Se exporta la tabla final como archivo .xlsx*/
proc export data = work.Plantilla
	outfile = '/home/u63456768/SS/PLANTILLA.csv'
	DBMS = xlsx
	replace;
	sheet = 'Plantilla1';
run;


