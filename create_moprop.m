function modality_properties = create_moprop()
%create_moprop(): creates the dictionary containing properties of each
%                 modality from openneuro.org
%   Initializes dictionary keys and values of common folder nomenclature
%   from openneuro.org datasets. Created into a function for ease of
%   updating along with new dataset standards/updates.
%
% :returns: - : modality_properties
%         type: dictionary: 
%         keys   - compatible modalities
%         values - common desired folders names that contain data files
%
% Alex Estrada 6.1.2023

% keys
modalities = ["eeg", "mri", "all"];

% values
eeg = "eeg.beh";
mri = "anat.func.fmap";

% combine all
all = eeg + "." + mri;

% folder names
folder_names = [eeg, mri, all];

% % create dictionary
modality_properties = dictionary(modalities, folder_names);

end