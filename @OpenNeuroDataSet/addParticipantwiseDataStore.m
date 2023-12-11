function datastore = addParticipantwiseDataStore(obj, sub_ID)
% input sub_ID from participant.tsv, if available

% path table
     arguments 
        obj     OpenNeuroDataSet  = OpenNeuroDataSet
        sub_ID  string              = string
      end

        datastore.filepaths = [];
        datastore.files = [];
        datastore.ds_ID = obj.encoding.ID;
        datastore.participants = obj.participants;
        datastore.sub_ID = sub_ID;
  

    % modality extensions
            extensions = obj.encoding.modality_properties("extensions");
    
    % initialize BIDSDatastore
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

    datastore.filepaths = data;

    %jsondecode(fileread(tbl2load.FileName(i)))
    jsonencode("s3://openneuro.org/ds004866/sub-sid001401/ses-a005515/anat/sub-sid001401_ses-a005515_acq-mprage_T1w.json");


end