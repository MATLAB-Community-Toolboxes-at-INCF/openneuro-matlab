classdef BIDSDataStore < matlab.io.Datastore
% BIDSDataStore inherits from matlab.io.Datastore and implements an 
% interface between a file folder validly organized to the BIDS 
% (https://bids.neuroimaging.io/) data organization standard and the 
% MATLAB datastore type
%
% USAGE EXAMPLE:
% 
%                   dataset = BIDS(bucket, ID, modality)
%           myBIDSDataStore = dataset.BIDSData{num}
%                      data = myBIDSDataStore.read(c)
%
%
% 07.8.2023 - Alex Estrada - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    properties (Access = public)
        extension           string
        modality            string
        files               table
    end

    properties (Access = private)
        CurrentFileIndex    double
        FileSet             matlab.io.datastore.DsFileSet
        TblReadSettings     struct
    end

    methods
        
        function ds = BIDSDataStore(extension, modality, path)
            %BIDSDataStore contains subject data
            %   Initialized with BIDS class to hold pointers to location of
            %   individual data files.

            arguments
                extension       string
                modality        string
                path            string
            end
            
            % set extension / modality
            ds.extension = extension;
            ds.modality = modality;
            
            % set table reading settings
            ds.TblReadSettings = getTblSet(ds);

            % create datastore object
            try
                ds.FileSet = matlab.io.datastore.DsFileSet(path, ...
                             'IncludeSubfolders',true, ...
                             'FileExtensions',extension);
                ds.CurrentFileIndex = 1;

                ds.files = viewall(ds);
                reset(ds);
            catch
                warning("File extension "+ extension + " not found. Continuing...");
            end

        end

        function data = read(ds, c)
            % Reads files specified by variable 'c'
            %
            % :param c: specified selection from BIDSDataStore Object to
            %           load.
            % :type c: string | integer | numeric array | table
            %
            % :returns: data : cell : loaded dataset with respective name 
            %                         of the loaded dataset.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Initializing output
            data = [];

            % parse input
            option = 'default';
            if nargin > 1
                option = c;
            else
                option = 'default';
            end
            
            % check extension
            if any(strcmpi(ds.extension, {'.json', '.tsv'}))
                fprintf("Reading from %s BIDSDataStore with extension(s): %s\n", ...
                        upper(ds.modality), ds.extension);
            else
                warning("Extension %s not yet supported.\nPlease try " + ...
                        "another BIDSDataStore.\n", ds.extension);
                return
            end
        
            % Check the type of the second input
            if ischar(option) || isstring(option)

                if strcmpi(option, 'default')
                    % Update
                    fprintf("Specification: none\n")

                    % Read the first available file name on the data store table
                    fprintf("Sequencially reading first available file...\n")
                    table_file = nextfile(ds.FileSet);
                    if hasdata(ds)
                        tbl2load = table_file;
                        ds.CurrentFileIndex = ds.CurrentFileIndex + 1;
                    end
                else
                    % Read the file name specified as a string
                    warning("Input '%s' not yet supported. Try again.", ...
                            option)
                end

            elseif isnumeric(option)
                % Attempt to read the file name at the specified index
                % TODO: boolean array
                
                % Update
                fprintf("Specification: Numeric\n")

                % Check dimension
                if size(option,3) > 1
                    warning("Numeric matrices not supported.\nMake another" + ...
                            "numeric selection as single integer (index) or " + ...
                            "as an array (i.e [1:5]) indicating multi-file selection")
                    return
                end
                num = length(option);
                
                % Distinguish on selection
                if num == 1 
                    % single file index
                    index = option;
                    if index > 0 && index <= numel(ds.files)
                        % Create table
                        tbl2load = table(ds.files.FileName(index), ...
                                   'VariableNames', {'FileName'});
                    else                    
                        error('Invalid index specified.')
                    end
                elseif num > 1 && max(option) <= numel(ds.files) && min(option) > 0
                    % multi-selection
                    tbl2load = table(ds.files.FileName(option), ...
                               'VariableNames', {'FileName'});
                end

                % load
                if ~isempty(tbl2load)
                    data = ds.MySpecialFileReader(tbl2load, ds.extension);
                else
                    error('Numeric selection error. Try different selection.')
                end
                

            elseif istable(option)
                % Update
                fprintf("Specification: Table\n")

                % Collect the column names from user input table
                columnNames = option.Properties.VariableNames;
                
                % Get members
                dl_idx = ismember(ds.TblReadSettings.colNames, columnNames);
                dl_c = ds.TblReadSettings.colNames(dl_idx);
                
                % Find similar naming files
                if numel(any(dl_idx)) > 0
                    matched_names = "";
                    for i = dl_c
                        desired_names = option.(i{:});
                        if strcmp(matched_names, "")   % if first time
                            matched_idx = contains(ds.files.FileName, desired_names);
                            matched_names = ds.files.FileName(matched_idx);
                        else                           % sequencial filter
                            matched_idx = contains(matched_names, desired_names);
                            matched_names = matched_names(matched_idx);
                        end
                    end

                else % No matching delimiters to parse DS table
                    sprintf("Check input table column names.\n" + ...
                            "Only supports: '%s', '%s'", ...
                            ds.TblReadSettings.colNames{:})
                    return
                end

                % Create table
                tbl2load = table(matched_names, 'VariableNames', {'FileName'});
            else
                error('Invalid second input type.');
            end

            % Load data
            if ~isempty(tbl2load)
                data = ds.MySpecialFileReader(tbl2load, ds.extension);
                fprintf("Load Complete!\n")
            else
                error('Loading error. Received empty table to load.')
            end
        end
        
        function reset(ds)
            % implement reset method
            % reset the datastore to the first file
            reset(ds.FileSet);
            ds.CurrentFileIndex = 1;
        end
        
        function t = getTblSet(ds)
            % Set table search settings for reading data
            t = struct;
            switch ds.modality
                case 'mri'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
                case 'eeg'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
            end

        end

        function [info, er] = preview(ds)
            % implement preview method
            % preview the first file in the datastore
        end

        function table = viewall(ds)
            % Implements 'resolve' function to view all files
            table = resolve(ds.FileSet);
        end
        
        function tf = hasdata(ds)
            % implement hasdata method
            % check if there is more data to read

            % Return true if more data is available.
            tf = hasfile(ds.FileSet);
        end
        
        function data = readall(ds)
            % Reads all files in BIDSDataStore
            data = ds.MySpecialFileReader(ds.files, ds.extension);
        end

        function subds = partition(ds,n,ii)
             subds = copy(ds);
             subds.FileSet = partition(ds.FileSet,n,ii);
             reset(subds);         
        end
        
        function data = MySpecialFileReader(~, tbl2load, extension)
            % Loads data based on table input
            
            % Update
            fprintf("Reading %d files from BIDSDataStore...\n", height(tbl2load))

            % Initializing
            data = cell(height(tbl2load),2);

            % Read (assumming same extension for all)
            switch extension
                case ".json"
                    for i = 1:height(tbl2load)
                        data{i,1} = jsondecode(fileread(tbl2load.FileName(i)));
                        data{i,2} = tbl2load.FileName{i};
                    end
                case ".tsv"
                    for i = 1:height(tbl2load)
                        data{i,1} = readtable(tbl2load.FileName(i), 'FileType', 'delimitedtext');
                        data{i,2} = tbl2load.FileName{i};
                    end
            end
        end

    end

     methods (Access = protected)
         function n = maxpartitions(ds) 
            n = maxpartitions(ds.FileSet); 
         end     
    end 
end