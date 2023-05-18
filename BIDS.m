classdef BIDS
    %BIDS implements the skeleton for the interface between a file folder
    %validly organized to the BIDS data organization standard. Utilizes
    %MATLAB table and datastore types to load/show data within theg given
    %AWS S3 bucket and folder.
    %
    % Alex Estrada 4.2023

    properties
        encoding        struct  = struct    % data encoding information
                                            % .bucket 
                                            % .ID
                                            % .dir
        about_dataset   struct  = struct    % dataset_description.json
        participants    table   = table     % data table
        BIDSDatastore   cell    = {}        % cell for BIDSDataStore
        info            struct  = struct    % participants.json
    end
    
    properties (Access = private)
        modalities      cell    = {'egg'}   % compatabilities
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
            dir_tree = generateFolderStructure(dir_base);

            % about dataset
            try
                dir_about = dir_base + "dataset_description.json";
                b.about_dataset = jsondecode(fileread(dir_about));
            catch
                warning('dataset_description.json not found.')
            end

            % participants.tsv
            try
                dir_participants = dir_base + "participants.tsv";
                temp = tsvread(dir_participants);
                % set up table using participants.tsv data
                if ~isempty(temp)
                    b.participants = struct2table(temp);
                end
            catch
                warning('participant.tsv not found')
            end

            % participants.json
            try 
                dir_participants_json = dir_base + "participants.json";
                b.info = jsondecode(fileread(dir_participants_json));
            catch
                warning('participants.json not found.')
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
            %       bucket = "openneuro.org"
            %           ID = ""
            %     modality = ""
            %
            % Note: modality currently only supports "EEG"
            
            input = lower([bucket, ID, modality]);

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
            if isempty(input(3)) || any(strcmp(input(3), b.modalities))
                warning("Modality " + input(3) + "not recognized or not yet supported.")
            else
                b.encoding.modality = "";
            end

            % set the bucket and folder properties
            b.encoding.bucket = input(1) + "/";
            b.encoding.ID = input(2);
            b.encoding.modality = input(3);
        end
    
    end

end