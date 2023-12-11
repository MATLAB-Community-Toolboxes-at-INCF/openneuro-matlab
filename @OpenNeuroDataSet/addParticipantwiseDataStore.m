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
    
    % TODO: add conversion from modality and loop
    extension = ".json";
    modality = "mri";
    
    modality_properties = get_value(obj.encoding.modality)
   
    datastore.filepaths = OpenNeuroDataStore(extension ,modality,obj.encoding.ID,datastore.sub_ID);

    paths = datastore.filepaths;

    %jsondecode(fileread(tbl2load.FileName(i)))
    jsonencode("s3://openneuro.org/ds004866/sub-sid001401/ses-a005515/anat/sub-sid001401_ses-a005515_acq-mprage_T1w.json");


end