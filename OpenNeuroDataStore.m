classdef (Abstract) OpenNeuroDataStore < matlab.io.Datastore

    % Customized abstract matlab.io.Datastore class. 
    % accepts the data set ID and the subject ID as input parameters.
    %
    

    properties (Access = private)
        CurrentFileIndex    double
        FileSet             matlab.io.datastore.DsFileSet
        TblReadSettings     struct
        files               struct
    end

    methods
        
        function ds = OpenNeuroDataStore(varargin)
        %function ds = OpenNeuroDataStore(ds_ID, modality, extension)
            %BIDSDataStore contains subject data
            %   Initialized with BIDS class to hold pointers to location of
            %   individual data files.

            if nargin ==0
            

            elseif nargin == 1
                b = obj;
                path = b.encoding.dir + "/" + b.sub_IDs{1}
                ds.FileSet = matlab.io.datastore.DsFileSet(path, ...
                             'IncludeSubfolders',true);

                ds.CurrentFileIndex = 1;

                %ds.files = viewall(ds);
                ds.files = viewall(ds)
                reset(ds);
            
            elseif nargin == 2
                ds.encoding.modality = modality;
                
            end
            if nargin > 2
                ds.encoding.data_type = varargin{1};
                ds.encoding.extension = varargin{2};
                %ds.files  = varargin{2};
            
            % set table reading settings
            ds.TblReadSettings = getTblSet(ds);

            if nargin > 4
                ds.encoding.subID = varargin{3};
                path = 's3://openneuro.org/'+dsID+'/'+subID;
            %path = 'https://github.com/OpenNeuroDatasets/ds004698/tree/main/derivatives/freesurfer'
            else
                path = 's3://openneuro.org/'+ds_ID;
            end

            %subIDs = participants{"participant_id"}
            % create datastore object
            try
                %path = 's3://openneuro.org/ds003104/'
                ds.FileSet = matlab.io.datastore.DsFileSet(path, ...
                             'IncludeSubfolders',true, ...
                             'FileExtensions',ds.encoding.extension);
                ds.CurrentFileIndex = 1;

                %ds.files = viewall(ds);
                ds.files = viewall(ds)
                reset(ds);
            catch
                warning("File extension "+ ds.encoding.extension + " not found. Continuing...");
            
            end
            end
            
        end
        
        function create_path
        end

        function ds = crawl(ds)
           b = ds;
           path = b.encoding.dir + "/" + b.sub_IDs{1}
           ds.FileSet = matlab.io.datastore.DsFileSet(path, ...
                             'IncludeSubfolders',true);

            ds.CurrentFileIndex = 1;
            ds.addprop('table');
            ds.table = viewall(ds)
            reset(ds);

            create_dic(ds)
        end
       
        function modality_dictionary = pass_info()
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
                fprintf("Reading from %s OpenNeuroDataStore with extension(s): %s\n", ...
                        upper(ds.modality), ds.extension);
            else
                warning("Extension %s not yet supported.\nPlease try " + ...
                        "another OpenNeuroDataStore.\n", ds.extension);
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
                case ".stats"
                    print("derivatives")
            
            end
        end

        function data = readall(ds)
            % Reads all files in BIDSDataStore
            data = ds.MySpecialFileReader(ds.files, ds.extension);
        end

       function reset(ds)
            % implement reset method
            % reset the datastore to the first file
            reset(ds.FileSet);
            ds.CurrentFileIndex = 1;
       end

       function tf = hasdata(ds)
            % implement hasdata method
            % check if there is more data to read

            % Return true if more data is available.
            tf = hasfile(ds.FileSet);
       end

       function table = viewall(ds)
            % Implements 'resolve' function to view all files
            table = resolve(ds.FileSet);
       end

       function t = getTblSet(ds)
            % Set table search settings for reading data
            t = struct;
            switch ds.encoding.modality
                case 'mri'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
                case 'eeg'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
            end
            
       end
              

    end

    methods (Hidden = true)          
        % Define the progress method
        function frac = progress(myds)
            % Determine percentage of data read from datastore
            if hasdata(myds) 
               frac = (myds.CurrentFileIndex-1)/...
                             myds.FileSet.NumFiles; 
            else 
               frac = 1;  
            end 
        end
    end
end