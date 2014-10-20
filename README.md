dataprocess.m
===========

Matlab Dataprocessing Function

Written by Matthew Visnovsky
Contact: matt.visnovsk@gmail.com
19 October, 2014

USAGE
  This function is useful for sifting through folders with delimited data
   files (.txt, .dat, etc.) and outputting a cell matirx containing a)the
   outputs of the processed data, b)the position of the files of
   interest within the data containing folder, and c)a directory listing of 
   the data containing folder. Data files will be processed in their 
   directory listing sort order (by name, date, etc.).

 INPUTS
   folder_name: directory of data containing folder 
       (eg. 'S:\Program Files\MATLAB\R2014a\data') [string]
   extension: name of file extension (eg. ".dat" or ".txt") [string]
   keywords: cell of strings, these are the repeated words within the
       named data files [cell array of strings]
   operation: called as a function, this operation is carried out on every
       cell of every array of every file found in the data folder with the
       specified keywords [function handle, or string]

 RETURNS
   Datamat: This is a matrix containing the data that was processed using
       the inputted function. The data columns are in order of inputted keywords.
   List: This is a cell matrix of strings listing the names of all of the
       files within the data containing folder. [cell array of strings]
   
 EXAMPLE USAGE
   extension = '.dat';
   keywords = {'DYN' 'STA' 'TOT' 'EP'}; 
   operation = @mean;
   folder_name = uigetdir(pwd,'Select Data Containing Folder');

   [Data,List] = dataprocess(folder_name,extension,keywords,operation);
