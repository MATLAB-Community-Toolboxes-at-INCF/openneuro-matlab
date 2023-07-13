function modality_properties = create_moprop(modality)
%create_moprop(): creates the dictionary containing properties of each
%                 modality from openneuro.org
%   Initializes dictionary keys and values of common folder nomenclature
%   from openneuro.org datasets. Created into a function for ease of
%   updating along with new dataset standards/updates.
%
% :returns: - : modality_properties
%     type: dictionary: 
%           +keys   - compatible modalities properties
%           +values - common desired folders names and extensions
%
% 6.1.2023 - Alex Estrada - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
        folders = {"anat";
                   "func";
                   "fmap"};
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
        modality_properties = dictionary("folders", {folders});
        return
end

% dictionary
modality_properties = dictionary("folders", ...
                                  {folders}, ...
                                  "extensions", ...
                                  {extension_list});
end