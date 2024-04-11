function modality_properties = get_value(modality)


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Keys
switch modality
    % values based on modality
    case "eeg"
        folders = {"eeg";
                   "beh"};
        extension_list = {".json";
                          ".tsv";
                          ".eeg";
                          ".vhdr";
                          ".vmrk";
                          ".csv";
                          ".fdt";
                          ".set";
                          ".edf"};
         
    case "mri"
        session_labels = {"ses-"};
        folders = {"anat";
                   "func";
                   "fmap";
                    "dwi"};
        task_lables = {"task-"};
        run_labels  = {"run-"};
        extension_list = {".json";
                          %".gz";
                          %".nii";
                          ".tsv"};
    case ""
        warning("Modality not specified.")
        folders = {"eeg";
                   "beh";
                   "anat";
                   "func";
                   "fmap"};
        modality_properties = dictionary("folders", {folders});
        return
end


% dictionary
modality_properties = dictionary("folders", {folders}, ...                                
                                  "sessions", {session_labels}, ...
                                  "tasks", {task_lables}, ...
                                  "runs", {run_labels}), ...
                                  "extensions",{extension_list};
end
