%% Testing BIDSDatastore 
bucket = "openneuro.org";

% Select dataset
% ID = "ds004560";                % MR (https://openneuro.org/datasets/ds004560/versions/1.0.0)
ID = "ds004551";                % iEEG (https://openneuro.org/datasets/ds004551/versions/1.0.5)
ID_yijay = "ds004529";  % work with folder trees
ds = BIDSDatastore(bucket, ID);