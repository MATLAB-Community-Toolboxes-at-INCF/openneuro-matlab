classdef OpenNeuroDataStore < matlab.io.Datastore

    % Customized matlab.io.Datastore class. 
    % accepts the data set ID and the subject ID as input parameters.
    %


    properties (Access = public)
        extension           string
        modality            string
        files               table % might set this to private
    end

    properties (Access = private)
        CurrentFileIndex    double
        FileSet             matlab.io.datastore.DsFileSet
        TblReadSettings     struct
    end

    methods
        
        function ds = OpenNeuroDataStore(extension, modality, dsID, subID)
            %BIDSDataStore contains subject data
            %   Initialized with BIDS class to hold pointers to location of
            %   individual data files.
            %   

            arguments
                extension       string
                modality        string
                dsID            string
                subID           string
            end
            
            % set extension / modality
            ds.extension = extension;
            ds.modality = modality;
            
            % set table reading settings
            ds.TblReadSettings = getTblSet(ds);

            path = 's3://openneuro.org/'+dsID+'/'+subID;
            %path = 's3://openneuro.org/ds003104/derivatives/'
                   
            % create datastore object
            try
                ds.FileSet = matlab.io.datastore.DsFileSet(path, ...
                             'IncludeSubfolders',true, ...
                             'FileExtensions',extension);
                ds.CurrentFileIndex = 1;

                ds.files = viewall(ds);
                reset(ds);
            catch
                warning("File extension "+ extension + " not found. Continuing...");
            
            end
        end

       function [data,info] = read(ds)
            %Read data and information about the extracted data.
            if ~hasdata(ds)
                error(sprintf(['No more data to read.\nUse the reset ',...
                    'method to reset the datastore to the start of ' ,...
                    'the data. \nBefore calling the read method, ',...
                    'check if data is available to read ',...
                    'by using the hasdata method.']))

            end

            fileInfoTbl = nextfile(ds.FileSet);
            data = MyFileReader(fileInfoTbl);
            info.Size = size(data);
            info.FileName = fileInfoTbl.FileName;
            info.Offset = fileInfoTbl.Offset;

            Update CurrentFileIndex for tracking progress
            if fileInfoTbl.Offset + fileInfoTbl.SplitSize >= ...
                    fileInfoTbl.FileSize
                myds.CurrentFileIndex = myds.CurrentFileIndex + 1 ;
            end
       end  
    
       function reset(ds)
            % implement reset method
            % reset the datastore to the first file
            reset(ds.FileSet);
            ds.CurrentFileIndex = 1;
       end

       function tf = hasdata(ds)
            % implement hasdata method
            % check if there is more data to read

            % Return true if more data is available.
            tf = hasfile(ds.FileSet);
       end

       function table = viewall(ds)
            % Implements 'resolve' function to view all files
            table = resolve(ds.FileSet);
       end

       function t = getTblSet(ds)
            % Set table search settings for reading data
            t = struct;
            switch ds.modality
                case 'mri'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
                case 'eeg'
                    t.colNames = {'participant_id',...
                                  'sub_id'};
            end
            
       end
                
       % function data = MyFileReader(fileInfoTbl)
       %      % create a reader object using FileName
       %      reader = matlab.io.datastore.DsFileReader(fileInfoTbl.FileName);
       % 
       %      % seek to the offset
       %      seek(reader,fileInfoTbl.Offset,'Origin','start-of-file');
       % 
       %      % read fileInfoTbl.SplitSize amount of data
       %      data = read(reader,fileInfoTbl.SplitSize);
       % 
       %  end

    end

    methods (Hidden = true)          
        % Define the progress method
        function frac = progress(myds)
            % Determine percentage of data read from datastore
            if hasdata(myds) 
               frac = (myds.CurrentFileIndex-1)/...
                             myds.FileSet.NumFiles; 
            else 
               frac = 1;  
            end 
        end
    end
end