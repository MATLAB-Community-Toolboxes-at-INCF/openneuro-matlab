function datastore = addParticipantwiseDataStore(obj, sub_ID)
% input sub_ID from participant.tsv, if available
% (C) Johanna Bayer 07.12.2023

% path table
     arguments 
        obj     OpenNeuroDataSet  = OpenNeuroDataSet
        sub_ID  string              = string
      end

 % initialize data store
        datastore.filepaths = [];
        datastore.loaded_data = [];
        datastore.ds_ID = obj.encoding.ID;
        datastore.participants = obj.participants;
        datastore.sub_ID = sub_ID;
  

    % modality extensions
            extensions = obj.encoding.modality_properties("extensions");
    
    % initialize OpenNeuroDataStore
            data = cell(length(extensions{:}),1);
            index = 1;  % index for resizing
            for i = 1:length(extensions{:})
                extension = extensions{1}{i};
                temp = OpenNeuroDataStore(extension, ...
                                     obj.encoding.modality, ...
                                     obj.encoding.ID,...
                                     datastore.sub_ID);
                % determine if successful load
                if temp.hasdata
                    data{index} = temp;
                    index = index + 1;      % update index
                end
            end

    % add to data store
    datastore.filepaths = data;

    % read files for subject
            loaded_data = cell(length(extensions{:}),1);
            index = 1;  % index for resizing
            for i = 1:length(extensions{:})
                if ~isempty(datastore.filepaths{i})
                    temp = read(datastore.filepaths{i});
                end
                % determine if successful load
                if ~isempty(datastore.filepaths{i})
                    loaded_data{index} = temp;
                    index = index + 1;      % update index
                end
            end

    % add loaded data to data store
    datastore.loaded_data =loaded_data;

end