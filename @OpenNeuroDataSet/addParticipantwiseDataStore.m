function datastore = addParticipantwiseDataStore(obj, participants)
% input sub_ID from participant.tsv, if available
% (C) Johanna Bayer 07.12.2023

% path table
     arguments 
        obj             OpenNeuroDataSet  = OpenNeuroDataSet
        participants    table             = table
        %folders        dictionary        = dictionary
        
      end

 % initialize data store
        datobjastore.filepaths = [];
        datastore.loaded_data = [];
        datastore.ds_ID = obj.encoding.ID;
        datastore.participants = obj.participants;
        datastore.sub_IDs = obj.participants{:, "participant_id"};
  

    % modality extensions
            extensions = obj.encoding.modality_properties("extensions");
            sub_IDs = obj.participants{:, "participant_id"};
    % participant IDs
            for IDs = 1:length(sub_IDs)
    % initialize OpenNeuroDataStore
            data = cell(length(extensions{:}),1);
            index = 1;  % index for resizing
            for i = 1:length(extensions{:})
                extension = extensions{1}{i};
                temp = OpenNeuroDataStore(extension, ...
                                     obj.encoding.modality, ...
                                     obj.encoding.ID,...
                                     datastore.sub_IDs{IDs});
                % determine if successful load
                if temp.hasdata
                    data{index} = temp;
                    index = index + 1;      % update index
                end
            end
            

    % add to data store
    datastore.filepaths{IDs} = data;

    % read files for subject
            loaded_data = cell(length(extensions{:}),1);
            index = 1;  % index for resizing
            for i = 1:length(extensions{:})
                if ~isempty(datastore.filepaths{IDs}{i})
                    temp = read(datastore.filepaths{IDs}{i});
                end
                % determine if successful load
                if ~isempty(datastore.filepaths{IDs}{i})
                    loaded_data{index} = temp;
                    index = index + 1;      % update index
                end
            end
            

    % add loaded data to data store
    datastore.loaded_data{IDs} =loaded_data;
            end

end