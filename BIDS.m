classdef BIDS
%BIDS implements the skeleton for the interface between a file folder
% validly organized to the BIDS data organization standard and the
% representation of its information in structures and tables. Moreover,
% it utilizes MATLAB table and datastore types to load/show data within 
% the given AWS S3 bucket and folder.
%
% USAGE EXAMPLE:
%       
%               dataset = BIDS(bucket, ID, modality)
%
% :param bucket: base AWS S3 path
% :type bucket: string
%
% :param ID: folder within AWS S3 bucket
% :type ID: string
%
% :param modality: (optional) dataset type
% :type modality: string
%
% :returns: - :BIDS Class Object: dataset properties and information 
%              within specified S3 bucket and folder location
%
%
% 4.25.2023 - Alex Estrada - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
        participants    table   = table     % data table
        BIDSData        cell    = {}        % cell for BIDSDataStore objs
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
        folder_files    struct  = struct    % complete folder structure
        encoding        struct  = struct    % data encoding information
                                            % .bucket 
                                            % .ID
                                            % .dir
                                            % .modality
                                            % .modality_properties
    end
    
    properties (Access = private)
        modality        struct = struct('compatible', ['egg', 'mri'], ... % compatabilities
                                        'depth_initiation', 2, ... % folder depth
                                        'focus_files', false)      % true if found     
    end

    methods

        function b = BIDS(bucket, ID, modality)   % BIDS class constructor

            arguments
                bucket      string      = "openneuro.org"
                ID          string      = string
                modality    string      = string
            end
            
            % parse input
            b = checkInput(b, bucket, ID, modality);

            % load files with desired structure
            b = loadData(b);

            % initialize datastore object based on number of participants
            b = loadParticipants(b);

        end
        
        function b = loadData(b)
            % Internal Function run at initiation.
            %
            % Loads and organizes data from bucket/folder. Particularly,
            % this attemps to find and load following files into the BIDS
            % class object: 
            %
            %       - dataset_description.json -> structure
            %       - participants.tsv         -> table
            %       - participants.json        -> structure
            %
            % Importantly, loadData also generates folder structure within 
            % the specified bucket/folder, and attempts to find all other
            % file contents. 

            % base directory
            dir_base = "s3://" + b.encoding.bucket + b.encoding.ID;
            b.encoding.dir = dir_base;

            % search important files in root directory
            root_dir = dir(dir_base);

            focus_files = [1, 1, 1];
            for i = 1:height(root_dir)
                file_name = string(root_dir(i).name);
                parent_folder = string(root_dir(i).folder);
                dir_file = parent_folder + "/" + file_name;
                switch file_name
                    case "participants.tsv"
                        temp = readtable(dir_file, 'FileType', 'delimitedtext');
                        if ~isempty(temp); b.participants = temp;end
                        % update focus files
                        focus_files(1) = 0;
                    case "dataset_description.json"
                        b.about_dataset = jsondecode(fileread(dir_file));
                        % update
                        focus_files(2) = 0;
                    case "participants.json"
                        b.info = jsoncode(fileread(dir_file));
                        % update
                        focus_files(3) = 0;
                end 
            end
            
            % check for specific files
            idx = find(focus_files);
            for j = idx
                switch j
                    case 1
                        warning("participants.tsv not found. Continuing...")
                    case 2
                        warning("dataset_description.json not found. Continuing...")
                    case 3
                        warning("participants.json not found. Continuing...")
                end
            end

        end
        
        function b = loadParticipants(b)
            % Creates and initializes BIDSDatastore objects based on
            % typical folder convention of given modality

            % modality extensions
            extensions = b.encoding.modality_properties("extensions");

            % initialize BIDSDatastore
            data = cell(length(extensions{:}),1);
            index = 1;  % index for resizing
            for i = 1:length(extensions{:})
                extension = extensions{1}{i};
                temp = BIDSDataStore(extension, ...
                                     b.encoding.modality, ...
                                     b.encoding.dir);
                % determine if successful load
                if temp.hasdata
                    data{index} = temp;
                    index = index + 1;      % update index
                end
            end
            
            % set BIDSData
            b.BIDSData = data(1:index-1);

        end

        function b = checkInput(b, bucket, ID, modality)
            % Check arguments into the constructor
            % Default values:
            %                bucket = "openneuro.org"
            %                    ID = ""
            %              modality = ""
            %   modality_properties = dictionary()
            %
            % Note: modality currently only supports "EEG" and "MRI"
            
            % fix case
            input = lower([bucket, ID, modality]);

            % initialize modality properties
            b.encoding.modality_properties = create_moprop(input(3));

            % bucket
            if input(1).endsWith("/")
                temp = char(input(1));
                input(1) = string(temp(1:end-1));
            end

            if ~input(1).endsWith([".org", ".com", ".edu"])
                warning("Bucket domain '" + input(1) + "' not recognized.")
            end
            
            % ID
            if ~input(2).endsWith("/")
                input(2) = input(2) + "/";
            end

            if ~startsWith(input(2), "ds")
                if length(input{2}) == 7
                    input(2) = "ds" + input(2);
                else
                    warning("Unusual ID for 'openneuro.org' bucket. Continuing.")
                end
            end
            
            % modality
            modal_comp = string(vertcat(b.modality.compatible));
            if isempty(input(3)) || any(strcmp(input(3), modal_comp))
                warning("Modality " + input(3) + "not recognized or not yet supported.")
            else
                b.encoding.modality = "";
            end
                
            % set the modality, bucket and folder properties
            b.encoding.bucket   = input(1) + "/";
            b.encoding.ID       = input(2);
            b.encoding.modality = input(3);
        end
    
    end

end