#  OpenNEURO for MATLAB  

A MATLAB® toolbox for accessing remote datasets stored on [OpenNEURO](https://openneuro.org/search) data archive. OpenNEURO only stores [BIDS](https://bids.neuroimaging.io)-compliant datasets, so [OpenNEURO for MATLAB](https://github.com/MATLAB-Community-Toolboxes-at-INCF/openneuro-matlab) is also BIDS-aware.


**OpenNeuro Matlab Interface** — A lightweight interface for accessing and reading participant-level data from OpenNeuro datasets in MATLAB.

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=likeajumprope/OpenNEURO-toolbox)


##  Usage


```matlab
>> ds = openneuro.Dataset('ds001415');
>> anatDS = ds.Participantwise('JSON Files');
```


### Input Arguments

- **`'dsXXXXX'`**: OpenNeuro dataset ID (e.g., `'ds001415'`).
- (`data type`) can be one of the following:

| Type                | Folder      | File Extensions      | Read Function      |
|---------------------|-------------|-----------------------|--------------------|
| `'Anatomical NIfTI'` | `anat`     | `.nii`, `.nii.gz`     | `niftiread`        |
| `'EEG EDF'`          | `eeg`      | `.edf`                | `edfread`          |
| `'Functional NIfTI'` | `func`     | `.nii`, `.nii.gz`     | `niftiread`        |
| `'DWI'`              | `dwi`      | `.nii`, `.nii.gz`     | `niftiread`        |
| `'Fieldmap'`         | `fmap`     | `.nii`, `.nii.gz`     | `niftiread`        |
| `'JSON Files'`       | `anat`     | `.json`               | `@(f) jsondecode(fileread(f))` |
| `'TSV Files'`        | `anat`     | `.tsv`, `.txt`        | `readtable`        |

### Example: Read a JSON file

```matlab
if anatDS.hasdata()
    [data, info] = anatDS.read();  % No arguments as required
    fprintf('    ✓ MVP read successful: %s\n', info.Filename);
else
    fprintf('    ✗ No data available (normal if dataset folder doesn''t exist)\n');
end
```

##  Requirements

- MATLAB **R2023a** or later

##  License

(C) 2023 Johanna Bayer  
