% 
% Written by Matthew Visnovsky
% Contact: matt.visnovsk@gmail.com
% 19 October, 2014
%
% USAGE
%   This function is useful for sifting through folders with delimited data
%   files (.txt, .dat, etc.) and outputting a cell matirx containing a)the
%   outputs of the processed data, b)the position of the files of
%   interest within the data containing folder, and c)a directory listing of 
%   the data containing folder. Data files will be processed in their 
%   directory listing sort order (by name, date, etc.).
%
% INPUTS
%   folder_name: directory of data containing folder 
%       (eg. 'S:\Program Files\MATLAB\R2014a\data') [string]
%   extension: name of file extension (eg. ".dat" or ".txt") [string]
%   keywords: cell of strings, these are the repeated words within the
%       named data files [cell array of strings]
%   operation: called as a function, this operation is carried out on every
%       cell of every array of every file found in the data folder with the
%       specified keywords [function handle, or string]
%
% RETURNS
%   Datamat: This is a matrix containing the data that was processed using
%       the inputted function. The data columns are in order of inputted keywords.
%   Index: array of index of file position. For example there are 20 files within
%       the data containing folder, the file containing the keyword is number
%       10 in the directory listing. The output of Index will then be a
%       1x1 matrix, and the value will be [10]. [array]
%   List: This is a cell matrix of strings listing the names of all of the
%       files within the data containing folder. [cell array of strings]
%   

 
function [Datacell,Index,List] = dataprocess(folder_name,extension,keywords,operation)
%Check inputs
if isempty(extension) == 1
    error('Please specify filetype extension as a string (eg. ''.dat'')')
elseif isempty(keywords) == 1
    error('Please specify key words as strings (eg. ''DAT'')')
%Check for proper inputs
elseif isa(folder_name, 'char') == 0
    error('Please input folder name as a string (eg. ''S:\Program Files\MATLAB\R2014a\data''')
elseif isa(operation, 'char') == 1
    operation = str2func(operation);
    warning('The specified operation was inputted as a string, and was converted a function handle')
elseif isa(operation, 'function_handle') == 0
    error('Inputted operation was not a string or function handle')
elseif isa(keywords, 'char') == 0
    error('Inputted keywords were not a string')
%Check for files
elseif  isempty(dir(folder_name)) == 1, error('There are no files in this folder')
end

%List data containging folder's contents
ext = strread(sprintf('*%s\n',extension),'%s'); %appends wildcard to beginnging of string
List = dir(fullfile(folder_name, ext{1})); %creates structure based on folder listing
List = {List.name}'; %throws out date, filesize, etc. and creates simple char array of filenames

%Check for files with proper extension
if isempty(List) == 1, error('There are no files with the extension "%s" in %s',ext{1},folder_name), end

j = 1;
for k = 1:length(keywords)
    CellIndex{j} = strfind(List,keywords{j}); %creates a boolean array for filenames containing keyword at i
    Idx{j} = find(not(cellfun('isempty', CellIndex{j}))); %creates an index array stating location of found files
    j=j+1;
end

%Convert Idx from cell array to matrix, uneven arrays are padded with NaN's
Idx = cellfun(@transpose,Idx,'UniformOutput',false); % Transpose each cell
maxSize = max(cellfun(@numel,Idx));    % Get the maximum vector size
fcn = @(x) [x NaN(1,maxSize-numel(x))];  % Create an anonymous function
Index = cellfun(fcn,Idx,'UniformOutput',false);  % Pad each cell with NaNs
Index = vertcat(Index{:});                  % Vertically concatenate cells
Index = Index'; % UnTranspose each cell

%Perform math on Datamat using fcn
i=1; j=1;
for i = 1:length(Index) %nested for loop FTW! :D
    for j = 1:length(keywords)
        if Index(i,j) > 0
        directory{i,j} = sprintf('%s\\%s',folder_name,List{Index(i,j)});
        Datamat(i,j) = operation(load(directory{i,j})); %operation is called as function
        else Datamat(i,j) = nan();
        end
    j=j+1;  %
    end     %next iteration
    i=i+1;  %
end

%Remove NaN's and convert output back to cell array
i=size(Datamat,2);
Datacell = cell(i,1);
for i = 1:size(Datamat,2);
    Datacell{i} = Datamat(~isnan(Datamat(:,i)),i);
end
end



