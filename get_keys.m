function dic = get_keys(modality, folder)

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
        switch folder
            case "anat"
                folders = "anat";
            case "func"
                folders  = "func";
            case "fmap"
                folders = "fmap";
            case "dwi"
                folders = "dwi";
            otherwise

        end

        extension_list = {".json";
                          ".gz";
                          ".nii";
                          ".tsv"};
    case ""
        warning("Modality not specified.")
        folders = {"eeg";
                   "beh";
                   "anat";
                   "func";
                   "fmap"};
    otherwise

end


% dictionary
dic = dictionary("folders", {folders}, ...                                
                  "sessions", {"all"}, ...
                  "tasks", {"all"}, ...
                  "runs", {"all"}, ...
                   "extensions", {extension_list});


end
