% 
% Written by Matthew Visnovsky
% Contact: matt@visnovsky.us
% 19 October, 2014
%
% USAGE
%   This function is useful for sifting through folders with delimited data
%   files (.txt, .dat, etc.) and outputting a cell matrix containing a)the
%   outputs of the processed data, b)the position of the files of
%   interest within the data containing folder, and c)a directory listing of 
%   the data containing folder. Note that data files will be processed in their 
%   directory listing sort order (whether by name, date, etc.).
%
% INPUTS
%   folder_name: directory of data containing folder 
%       (eg. 'S:\Program Files\MATLAB\R2014a\data') [string]
%   extension: cell of strings of the file extension(s) (eg. ".dat" or ".txt") 
%       [cell array of strings]
%   keywords: cell of strings, these are the repeated words within the
%       named data files [cell array of strings]
%   operation: called as a function, this operation is carried out on every
%       cell of every array of every file found in the data folder with the
%       specified keywords [function handle, or string]
%
% RETURNS
%   DataCell: This is a matrix containing the data that was processed using
%       the inputted function. The data columns are in order of inputted keywords.
%   ListCell: This is a cell matrix of strings listing the names of all of the
%       files within the data containing folder that are found to contain
%       the specified key words. [cell array of strings]
%
% EXAMPLE USAGE
%   extension = '.dat';
%   keywords = {'DYN' 'STA' 'TOT' 'EP'}; 
%   operation = @mean;
%   folder_name = uigetdir(pwd,'Select Data Containing Folder');
%
%   [Data,List] = dataprocess(folder_name,extension,keywords,operation);
%

function [DataCell,ListCell] = dataprocess(folder_name,extension,keywords,operation)
% Check inputs
if isa(folder_name, 'char') == 0 && isa(folder_name, 'cell') == 0, error('Please input folder name as a string (eg. ''S:\Program Files\MATLAB\R2014a\data'''),end
if isa(keywords, 'char') == 0 && isa(keywords, 'cell') == 0, error('Inputted keywords were not a cell or string'), end
if isa(keywords, 'char') == 1 keywords = {keywords},end

%Check for files
if  isempty(dir(folder_name)) == 1, error('No files were found with the specified extension'),end

%If operation is specified
if nargin ==4
    if isa(operation, 'char') == 1
        operation = str2func(operation);
    elseif isa(operation, 'function_handle') == 0
        error('Inputted operation was not a string or function handle')
    end
end

%List data containging folder's contents
if  size(extension(1)) > 1 %If more than one extension is specified
    i=1;
    for k = 1:length(extension)
        ext{i} = strread(sprintf('*%s\n',extension{i}),'%s'); %appends wildcard to beginnging of string
        List{i} = dir(fullfile(folder_name, cell2mat(ext{i}))); %creates structure based on folder listing
        List{i} = {List{i}.name}'; %throws out date, filesize, etc. and creates simple char array of filenames
        i=i+1;
    end
    
    %Check for files with proper extension(s)
    i=1;
    for k = 1:length(extension)
        if isempty(List{i}) == 1, error('There are no files with the extension "%s" in %s',ext{i},folder_name),end
    end
    
    %Transpose and combine files with extension into single 1xn cell array
    i=1;
    for k = length(extension)+1
        List = [List{i}; List{i+1}];
        i=i+1;
    end
    
else %If only one extension is specified
    if isa(extension, 'char') == 1 %if extension is inputted as string
        ext = strread(sprintf('*%s\n',extension),'%s'); 
        List = dir(fullfile(folder_name, ext{1})); 
        List = {List.name}'; 
    end
    if isa(extension, 'cell') == 1 %if extension is inputted as cell
        extension = cell2mat(extension);
        ext = strread(sprintf('*%s\n',extension),'%s'); 
        List = dir(fullfile(folder_name, ext{1})); 
        List = {List.name}';
    end
    if isempty(List) == 1, error('There are no files with the extension "%s" in %s',ext{1},folder_name),end
end

i = 1;
for k = 1:length(keywords)
    CellIndex{i} = strfind(List,keywords{i}); %creates a boolean array for filenames containing keyword at i
    Idx{i} = find(not(cellfun('isempty', CellIndex{i}))); %creates an index array stating location of found files
    i=i+1;
end

%Check for empty cells, indicating discrepancy
for k = 1:length(keywords)
    if isempty(Idx{k}) == 1, 
        error('One or more of the specified keywords was not found. Please check for typos. Dataprocess is case sensitive.')
    end
end

%Convert Idx from cell array to matrix, uneven arrays are padded with NaN's
Idx = cellfun(@transpose,Idx,'UniformOutput',false); % Transpose each cell
maxSize = max(cellfun(@numel,Idx));    % Get the maximum vector size
fcn = @(x) [x NaN(1,maxSize-numel(x))];  % Create an anonymous function
Index = cellfun(fcn,Idx,'UniformOutput',false);  % Pad each cell with NaNs
Index = vertcat(Index{:});                  % Vertically concatenate cells
Index = Index'; % UnTranspose each cell

%Simply load the files if Operation is not specified. 
% if nargin == 3
    i=1; j=1;
    for i = 1:length(Index)
        for j = 1:length(keywords)
            if Index(i,j) > 0
            directory{i,j} = sprintf('%s\\%s',folder_name,List{Index(i,j)});
            DataCell{i,j} = load(directory{i,j});
            ListCell{i,j} = List{Index(i,j)}; %saves a new directory listing, isolating files by keyword
            end
        j=j+1;  %
        end     %next iteration
        i=i+1;  %
    end
% end

%Otherwise perform math on Datamat using Operation
if nargin == 4 
    i=1; j=1;
    for i = 1:length(Index)
        for j = 1:length(keywords)
            if Index(i,j) > 0
            directory{i,j} = sprintf('%s\\%s',folder_name,List{Index(i,j)});
            Datamat(i,j) = operation(load(directory{i,j})); %operation is called as function
            ListCell{i,j} = List{Index(i,j)}; %saves a new directory listing, isolating files by keyword
            else Datamat(i,j) = nan();
            end
        j=j+1;  %
        end     %next iteration
        i=i+1;  %
    end
    %Remove NaN's and convert output back to cell array
    i=size(Datamat,2);
    DataCell = cell(i,1);
    for i = 1:size(Datamat,2);
    DataCell{i} = Datamat(~isnan(Datamat(:,i)),i);
    end
end

end %end function


