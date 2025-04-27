classdef Dataset < handle %& OpenNeuroDataStore  
% Creates data set summary
% (C) Johanna Bayer 01.12.2023

    properties
        ID               (1,1) string

        ParticipantIDs    (1,:) string
        ParticipantsInfo table   = table     % data table: participants.tsv
        
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
        %encoding        struct  = struct    % data encoding information
        % .ID
        % .dir
        %% .modality
        %% .modality_properties
    end

    properties (Dependent)
        URI          (1,1) string
    end
    % properties (Hidden = true)
    %     sub_IDs       cell                  % table with filepaths             
    % end

    properties (Hidden, Constant)
        RootURI        string = "s3://openneuro.org/";
        coreModalityFilesetSpec = zinitCoreModalityFilesetSpec();
    end

    % properties (Hidden, SetAccess = immutable)
    % end
   
    methods
    
        function obj = Dataset(ID)

            %b@OpenNeuroDataStore()

            % ds_ID
            obj.ID = ID;

            try
                obj.ParticipantsInfo = readtable(fullfile(obj.URI + "/participants.tsv"), 'FileType', 'delimitedtext');
                obj.ParticipantIDs = string(obj.ParticipantsInfo{:,1});  %TODO: access by column name (for clarity & self-validation)
            catch
                warning("Partcipants.tsv  not found. Individualixed loading of" + ...
                    "participants will not be avaiable")
            end

            try
                % search for about_dataset
                obj.about_dataset = jsondecode(fileread(dir_base + "/dataset_description.json"));
            catch
                warning('Data set description not found.')
            end

            try
                % serach for info (participant.json)
                obj.info = jsondecode(fileread(dir_base + "/participants.json"));
            catch
                warning('Participants.json not found.')
            end

            % % add sub_IDs
            % if ~isempty(obj.participants)
            %     obj.sub_IDs = table2cell(obj.participants(:,"participant_id"));
            % else
            % end
        end




        function ds = addParticipantwiseDatastore(obj, modality)

            % Simple mode:  one argument, a key to the 'easy' special cases where core modality gives all the required info to make the datastore
            % Future mode(s): additional arguments, e.g., of extended modalities, sessions, runs, etc as needed to make the datastore

            arguments
                obj (1,1) openneuro.Dataset;
                modality (1,1) string {mustBeMember(modality,["mri" "eeg"])}
            end


            if nargin == 2 % simple mode (core modality-driven)
                filesetSpec = obj.coreModalityFilesetSpec(modality);
            elseif nargin > 2
                error("Currently only cases of MRI anatomical and EEG data types are supported. Other participantwise data subsets coming soon.")
            end

            ds = zprvAddParticipantwiseDatastore(obj,filesetSpec);


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



    dict = configureDictionary("string","struct");

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


% 
% 
% % Keys
% switch datastoreType
%     % values based on modality
%     case "eeg" % make more specific edf-eeg (find some data sets where those are present)
%         folders = {"eeg";
%                    "beh"};
%         extension_list = {".json";
%                           ".tsv";
%                           ".eeg";
%                           ".vhdr";
%                           ".vmrk";
%                           ".csv";
%                           ".fdt";
%                           ".set";
%                           ".edf"};
% 
%     case "mri"
%         switch folder
%             case "anat"
%                 folders = "anat";
%             case "func"
%                 folders  = "func";
%             case "fmap"
%                 folders = "fmap";
%             case "dwi"
%                 folders = "dwi";
%             otherwise
% 
%         end
% 
%         extension_list = {".json";
%                           ".gz";
%                           ".nii";
%                           ".tsv"};
%     case ""
%         warning("Modality not specified.")
%         folders = {"eeg";
%                    "beh";
%                    "anat";
%                    "func";
%                    "fmap"};
%     otherwise
% 
% end
% 
% 
% % dictionary
% dic = dictionary( "subjects", {"*"}, ...
%                   "folders", {folders}, ... 
%                   "sessions", {"*"}, ...
%                   "tasks", {"*"}, ...
%                   "runs", {"*"}, ...
%                    "extensions", {extension_list});
% 
% 
% end
% 
% 
% 
% end