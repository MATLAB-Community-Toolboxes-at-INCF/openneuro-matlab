# OpenNeuro-Toolbox

OpenNeuro Matlab Interface.

## Usage

`>> OpenNeuroDataSet = OpenNeuroDataSet(ID, modality)`

Input Arguments:

- `ID` OpenNeuro data set ID, of format 'dsXXXXX'
- `modality` (optional) data set type

Output:
- `dataset` a OpenNeuroDataSet Class Object

## Properties
- `Participants` Data table created from 'participants.tsv' file
- `About_Dataset` Data taken from the 'dataset_description.json; file
- `Info` Data taken from the 'participant.jsoon' file


## Methods
- `addParticipantwiseDataStore(OpenNeuroDataSet, sub-ID)` loads all available files (.json, .tsv) for a selected subject 'sub-ID'.

### OpenNeuroDataStore Syntax

`XDatastore = addParticipantwiseDataStore(OpenNeuroDataSet, sub-ID)`

##### Input:
- `OpenNeuroDataSet` Class Object
- `sub-ID` Subject ID of one of the participants in the data set as displayed in `Participants`

##### Output:

- `Xdatastore` Structure containing files of `sub-ID`
  
 ## Example

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=likeajumprope/OpenNEURO-toolbox&file=OpenNeuroDemo.mlx) Open in MATLAB online to run Life Script of OpenNeuro toolbox usage example.

## Requirements
Compatible with R2023a
