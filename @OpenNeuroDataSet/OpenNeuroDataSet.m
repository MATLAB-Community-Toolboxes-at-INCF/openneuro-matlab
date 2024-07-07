classdef OpenNeuroDataSet < dynamicprops % & OpenNeuroDataStore  
% Creates data set summary
% (C) Johanna Bayer 01.12.2023

    properties
        participants    table   = table     % data table: participants.tsv
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
        encoding        struct  = struct    % data encoding information
                                            % .ID
                                            % .dir
                                            %% .modality
                                            %% .modality_properties
    end

    properties (Hidden = true)
        sub_IDs       cell                  % table with filepaths
        bucket        string = "openneuro.org";
        
        
    end
   
    methods
    
    function b = OpenNeuroDataSet(ds_ID)
    
            %b@OpenNeuroDataStore()
    
            % ds_ID
            b.encoding.ds_ID = ds_ID;
           

            % base directory
            dir_base = "s3://" + b.bucket +"/" + b.encoding.ds_ID;
            b.encoding.dir = dir_base;
        
        try
            b.participants = readtable(fullfile(dir_base + "/participants.tsv"), 'FileType', 'delimitedtext');
        catch
            warning("Partcipants.tsv  not found. Individualixed loading of" + ...
                 "participants will not be avaiable")
        end
    
        try 
         % search for about_dataset
            b.about_dataset = jsondecode(fileread(dir_base + "/dataset_description.json"));
        catch
            warning('Data set description not found.')
        end
   
        try 
         % serach for info (participant.json)
        b.info = jsondecode(fileread(dir_base + "/participants.json"));
        catch
             warning('Participants.json not found.')
        end

        % add sub_IDs 
        if ~isempty(b.participants)
             b.sub_IDs = table2cell(b.participants(:,"participant_id"));
        else
        end
    end


    b = infer_data(b)
    % b = checkinput(b, bucket, ds_ID);

     %dir("s3://openneuro.org/ds001499")

    %%% 
    % add a property dictionary into Data store
    % static method that can query the keys and then the crawl
    % addDataStore(MRI, etc)
    % function validation and returning of the values of the dic, generate
    % path

    %end


    %      %try 
    %      % search for derivatives 
    %      %b.derivatives = 
    % 
    %     % implementation of addParticipantwiseDataStore
    % 
    % 
    %     function ds = addParticipantwiseDataStore(obj, extension, modality, ID, subID)
    % 
    % 
    %     end
    % 
    %     end
    end
end
