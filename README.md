# INEGI-Dataset-Arrangement
>This codes create a dataset with format and information used by INEGI (Instituto Nacional de Estadítica y Geografía). This format includes variables used by SESNA (Secretaría Ejecutiva del Sistema Nacional Anticorrupción) for modifing its databases. 

## Objectives
- Create a new dataset arrangement using data from INEGI official information. This new arrangement will be apply in the SESNA system.
- Build a code structure that can be operate with anly dataset from INEGI official information.
- Design more than one proposal for building the dataset required.

## Used tools
* SAS code.
* SAS macros.
  
## Files 
### 1. Transpose.SAS
Transpose.SAS is a program that needs the inicial public data located in INEGI's official webside. The user can download all this information. The program needs the information clasified by State and Town. The main process in this program is the used of Transpose sentence. All the variable's values are organized by Transpose sentence to figure out in the corresponding variable. Finally, the program export a file which contains all data points classified and ordered in the proper way for SESNA to apply it.


### 2. Macros.SAS
Macros.SAS is a program that requires INEGI's official information, too. The process and objetives are similar to Transpose.SAS. However, the difference betweeen both is the utilization of macros in SAS. There are several macros in the code, they treat and classified all data for the corresponding requirement or conditions SESNA needs to contemplate abput their datasets. 
These conditions are: 
- Enter all data and relate them with the corresponding variable.
- Identify if the type data point in the variable "Value" is integer, cathegorical or binary. 







>Note: In the comments' file there are instrucctions of how to implement the programs correctly.
