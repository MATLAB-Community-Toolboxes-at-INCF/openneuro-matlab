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
    % within specified S3 bucket and folder location
    %
    %
    % Alex Estrada 4.2023

    properties
        encoding        struct  = struct    % data encoding information
                                            % .bucket 
                                            % .ID
                                            % .dir
                                            % .modality
                                            % .modality_properties
        about_dataset   struct  = struct    % dataset_description.json
        participants    table   = table     % data table
        BIDSDatastore   cell    = {}        % cell for BIDSDataStore
        info            struct  = struct    % participants.json
        folder_files    struct  = struct    % complete folder structure
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
            % Load and organize data from the bucket/folder. Particularly,
            % this attemps to find and load following files into the BIDS
            % class object: 
            %       - dataset_description.json -> structure
            %       - participants.tsv         -> table
            %       - participants.json        -> structure
            % Also attempts to find ./derivative folders and its contents. 

            % base directory
            dir_base = "s3://" + b.encoding.bucket + b.encoding.ID;
            b.encoding.dir = dir_base;
            
            % create repository structure
            [dir_tree, b.encoding, b.modality] = generateFolderStructure(dir_base, b.modality, b.encoding);
            b.folder_files = dir_tree;

            % look for wanted files
            for i = 1:numel(dir_tree.files)
                file_name = string(dir_tree.files(i).name);
                parent_folder = string(dir_tree.files(i).folder);
                dir = parent_folder + "/" + file_name;
                
                switch file_name
                    case "participants.tsv"
                        temp = readtable(dir, 'FileType', 'delimitedtext');
                        % set up table using participants.tsv data
                        if ~isempty(temp)
                            b.participants = temp;
                        end
                    case "dataset_description.json"
                        b.about_dataset = jsondecode(fileread(dir));
                    case "participants.json"
                        b.about_dataset = jsoncode(fileread(dir));
                end 
            end
        end
        
        function b = loadParticipants(b)
            % Initializes datastore object within folder for each subject
            
            num = height(b.participants);
            out = cell(num, 1);
            for i = 1:num
                id = b.participants.participant_id(i);  % ID
                dir = b.encoding.dir;                   % base dir
                bids_obj = BIDSDataStore(id, dir);
                out{i} = bids_obj;
            end
            b.BIDSDatastore = out;

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
            b.encoding.modality_properties = create_moprop();

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