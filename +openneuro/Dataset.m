classdef Dataset < handle %& OpenNeuroDataStore  
% Creates data set summary
% (C) Johanna Bayer 01.12.2023

    properties
        ID              (1,1) string
        ParticipantIDs    (1,:) string
        ParticipantsInfo table   = table     % data table: participants.tsv
        
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
    end

    properties (Dependent)
        URI          (1,1) string
    end

    properties (Hidden, Constant)
        RootURI        string = "s3://openneuro.org";
        coreModalityFilesetSpec = zinitCoreModalityFilesetSpec();
    end
   
    methods
        function obj = Dataset(ID)
            % Constructor
            obj.ID = ID;

            try
                obj.ParticipantsInfo = readtable(obj.URI + "/participants.tsv", 'FileType', 'text');
                obj.ParticipantIDs = string(obj.ParticipantsInfo{:,1});  %TODO: access by column name (for clarity & self-validation)
            catch
                warning("Participants.tsv not found. Individualized loading of " + ...
                    "participants will not be available")
            end

            try
                % Fixed: Use obj.URI instead of undefined dir_base
                obj.about_dataset = jsondecode(fileread(obj.URI + "/dataset_description.json"));
            catch
                warning('Dataset description not found.')
            end

            try
                % Fixed: Use obj.URI instead of undefined dir_base
                obj.info = jsondecode(fileread(obj.URI + "/participants.json"));
            catch
                warning('Participants.json not found.')
            end
        end

        function ds = addParticipantwiseDatastore(obj, modality)
            % Simple mode: one argument, a key to the 'easy' special cases where core modality gives all the required info to make the datastore
            % Future mode(s): additional arguments, e.g., of extended modalities, sessions, runs, etc as needed to make the datastore

            arguments
                obj
                modality (1,1) string {mustBeMember(modality,["mri" "eeg"])}
            end

            if nargin == 2 % simple mode (core modality-driven)
                filesetSpec = obj.coreModalityFilesetSpec(modality);
            elseif nargin > 2
                error("Currently only cases of MRI anatomical and EEG data types are supported. Other participantwise data subsets coming soon.")
            end

            ds = zprvAddParticipantwiseDatastore(obj,filesetSpec);
        end
        
        function ds = Participantwise(obj, typeName)
            % MVP method: Create participantwise datastore using Type dictionary
            %
            % Parameters:
            %   typeName - String from Type dictionary (e.g., "Anatomical NIfTI")
            %
            % Usage:
            %   ds = Dataset('ds001415');
            %   anatDS = ds.Participantwise("Anatomical NIfTI");
            
            arguments
                obj
                typeName (1,1) string
            end
            
            % Create Participantwise datastore using the dataset's ID and path
            ds = openneuro.datastore.Participantwise(obj,typeName);
        end
    end

    methods
        function uri = get.URI(obj)
            uri = obj.RootURI + "/" + obj.ID;
        end
    end

    methods (Access=protected)
        function ds = zprvAddParticipantwiseDatastore(obj,filesetSpec)
            ds = openneuro.datastore.Participantwise(obj,filesetSpec);
        end
    end
end

%% LOCAL FUNCTIONS

function dict = zinitCoreModalityFilesetSpec()
    % Fixed: Use containers.Map instead of configureDictionary for compatibility
    dict = containers.Map();

    % modality = MRI
    s = struct;
    s.extendedModality = "anat";
    s.sessions = string.empty();
    s.tasks = string.empty();
    s.runs = string.empty();
    s.extensionList = [".nii.gz" ".json"];
    dict("mri") = s;

    % modality = EEG
    s = struct;
    s.extendedModality = "eeg";
    s.sessions = string.empty();
    s.tasks = string.empty();
    s.runs = string.empty();
    s.extensionList = [".eeg" ".edf" ".json"];
    dict("eeg") = s;

    % Thus far, (just) these two cases have been identified where datastore contents can be inferred w/ just a modality hint
end

% classdef Dataset < handle %& OpenNeuroDataStore  
% % Creates data set summary
% % (C) Johanna Bayer 01.12.2023
% 
%     properties
%         ID              (1,1) string
%         ParticipantIDs    (1,:) string
%         ParticipantsInfo table   = table     % data table: participants.tsv
% 
%         about_dataset   struct  = struct    % dataset_description.json
%         info            struct  = struct    % participants.json
%     end
% 
%     properties (Dependent)
%         URI          (1,1) string
%     end
% 
%     properties (Hidden, Constant)
%         RootURI        string = "s3://openneuro.org";
%         coreModalityFilesetSpec = zinitCoreModalityFilesetSpec();
%     end
% 
%     methods
%         function obj = Dataset(ID)
%             % Constructor
%             obj.ID = ID;
% 
%             try
%                 obj.ParticipantsInfo = readtable(obj.URI + "/participants.tsv", 'FileType', 'text');
%                 obj.ParticipantIDs = string(obj.ParticipantsInfo{:,1});  %TODO: access by column name (for clarity & self-validation)
%             catch
%                 warning("Participants.tsv not found. Individualized loading of " + ...
%                     "participants will not be available")
%             end
% 
%             try
%                 % Fixed: Use obj.URI instead of undefined dir_base
%                 obj.about_dataset = jsondecode(fileread(obj.URI + "/dataset_description.json"));
%             catch
%                 warning('Dataset description not found.')
%             end
% 
%             try
%                 % Fixed: Use obj.URI instead of undefined dir_base
%                 obj.info = jsondecode(fileread(obj.URI + "/participants.json"));
%             catch
%                 warning('Participants.json not found.')
%             end
%         end
% 
%         function ds = addParticipantwiseDatastore(obj, modality)
%             % Simple mode: one argument, a key to the 'easy' special cases where core modality gives all the required info to make the datastore
%             % Future mode(s): additional arguments, e.g., of extended modalities, sessions, runs, etc as needed to make the datastore
% 
%             arguments
%                 obj (1,1) openneuro.Dataset;
%                 modality (1,1) string {mustBeMember(modality,["mri" "eeg"])}
%             end
% 
%             if nargin == 2 % simple mode (core modality-driven)
%                 filesetSpec = obj.coreModalityFilesetSpec(modality);
%             elseif nargin > 2
%                 error("Currently only cases of MRI anatomical and EEG data types are supported. Other participantwise data subsets coming soon.")
%             end
% 
%             ds = zprvAddParticipantwiseDatastore(obj,filesetSpec);
%         end
%     end
% 
%     methods
%         function uri = get.URI(obj)
%             uri = obj.RootURI + "/" + obj.ID;
%         end
%     end
% 
%     methods (Access=protected)
%         function ds = zprvAddParticipantwiseDatastore(obj,filesetSpec)
%             ds = openneuro.datastore.Participantwise(obj,filesetSpec);
%         end
%     end
% end
% 
% %% LOCAL FUNCTIONS
% 
% function dict = zinitCoreModalityFilesetSpec()
%     % Fixed: Use containers.Map instead of configureDictionary for compatibility
%     dict = containers.Map();
% 
%     % modality = MRI
%     s = struct;
%     s.extendedModality = "anat";
%     s.sessions = string.empty();
%     s.tasks = string.empty();
%     s.runs = string.empty();
%     s.extensionList = [".nii.gz" ".json"];
%     dict("mri") = s;
% 
%     % modality = EEG
%     s = struct;
%     s.extendedModality = "eeg";
%     s.sessions = string.empty();
%     s.tasks = string.empty();
%     s.runs = string.empty();
%     s.extensionList = [".eeg" ".edf" ".json"];
%     dict("eeg") = s;
% 
%     % Thus far, (just) these two cases have been identified where datastore contents can be inferred w/ just a modality hint
% end