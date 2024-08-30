function dic = bidsDictionary(datastoreType, folder)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Keys
switch datastoreType
    % values based on modality
    case "eeg" % make more specific edf-eeg (find some data sets where those are present)
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
dic = dictionary( "subjects", {"*"}, ...
                  "folders", {folders}, ... 
                  "sessions", {"*"}, ...
                  "tasks", {"*"}, ...
                  "runs", {"*"}, ...
                   "extensions", {extension_list});


end
