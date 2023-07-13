# BIDS Toolbox#
A Matlab Toolbox for Brain Imaging Data Structure (BIDS) Standard

## Description ##
BIDS Class object implements the skeleton for the interface between a file folder validly organized to the BIDS data organization standard and the representation of its information in structures and tables. Moreover, it utilizes MATLAB table and datastore types to load/show data within a given Amazon S3 bucket and folder.

## USAGE ##
> `>> dataset = BIDS(bucket, ID,modality)`

Input Arguments: 
* `bucket` base AWS S3 path
* `ID` folder within AWS S3 bucket
* `modality` (optional) dataset type

Output:
* `dataset` a BIDS Class Object


## Properties ##
* `Participants` Data table taken from 'participants.tsv' file
* `BIDSData` Cell for # BIDSDataStore # objects
* `About_Dataset` Data from root 'dataset_description.json' file
* `Info` Data taken from root 'participants.json' file
* `Folder_Files` Complete directory folder and files structure
* `Encoding` Data encoding information (bucket, ID, root dir, modality, modality_properties)

## BIDSDataStore Syntax ##
> `>> myBIDSDataStore = dataset.BIDSData{num}`

## Methods ##
* `read` Read data in datastore
* `readall` Read all data in datastore
* `viewall` View all files in datastore
* `reset` Reset datastore to initial stage
* `hasdata` Determine if data is available to read

## Example ##
Run MATLAB Online to run Live Script of BIDS Usage Example

### Requirements ###
Compatible with R2023a  
