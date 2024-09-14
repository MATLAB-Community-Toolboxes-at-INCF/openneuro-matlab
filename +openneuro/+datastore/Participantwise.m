classdef Participantwise < matlab.io.Datastore
    %PARTICPANTWISE Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties (Access = private)
        CurrentFileIndex    double;
        FileSet matlab.io.datastore.DsFileSet;
    end
    
    methods
        function obj = Participantwise(dataset,filesetSpec)

            arguments
                dataset (1,1) openneuro.Dataset
                filesetSpec (1,1) struct
            end

            obj.FileSet = matlab.io.datastore.DsFileSet(computeLocations(dataset,filesetSpec),'FileExtensions',filesetSpec.extensionList);

            obj.CurrentFileIndex = 1;
            reset(obj);
        end

        function reset(obj)
            % Reset to the start of the data.
            reset(obj.FileSet);
            obj.CurrentFileIndex = 1;
        end
      
       function tf = hasdata(obj)
            % Return true if more data is available.
            tf = hasfile(obj.FileSet);
       end

       function [data,info] = read(obj)
            % Read data and information about the extracted data.
            if ~hasdata(obj)
                error(sprintf(['No more data to read.\nUse the reset ',...
                    'method to reset the datastore to the start of ' ,...
                    'the data. \nBefore calling the read method, ',...
                    'check if data is available to read ',...
                    'by using the hasdata method.']))
                
            end
            
            fileInfoTbl = nextfile(obj.FileSet);
            data = MyFileReader(fileInfoTbl);
            info.Size = size(data);
            info.FileName = fileInfoTbl.FileName;
            info.Offset = fileInfoTbl.Offset;
            
            % Update CurrentFileIndex for tracking progress
            if fileInfoTbl.Offset + fileInfoTbl.SplitSize >= ...
                    fileInfoTbl.FileSize
                obj.CurrentFileIndex = obj.CurrentFileIndex + 1 ;
            end
            
            
        end



    end

    methods (Access=protected)

       
    end
end

%% LOCAL FUNCTIONS
function data = MyFileReader(fileInfoTbl)
% create a reader object using the FileName
reader = matlab.io.datastore.DsFileReader(fileInfoTbl.FileName);

% seek to the offset
seek(reader,fileInfoTbl.Offset,'Origin','start-of-file');

% read fileInfoTbl.SplitSize amount of data
data = read(reader,fileInfoTbl.SplitSize);
end


function locations = computeLocations(dataset,filesetSpec)


fs = filesetSpec;
if all(cellfun(@isempty,{fs.sessions,fs.tasks,fs.runs},'UniformOutput',true))  % Maybe sessions is enough? Trigger an error if tasks/runs w/o sessions?
    % "Core modality" special case
    assert(isscalar(fs.extendedModality));
    assert(isa(dataset,'openneuro.Dataset'));
    locations = dataset.RootURI + "/" + string(dataset.ID) + "/" + dataset.ParticipantIDs + "/" + fs.extendedModality;


else % General case (TODO; may encompass core modality special case, i.e., removing need for IF/ELSE)
    %TODO
end

%
% dir(b.encoding.dir + "/" + subjects{1} + "/" + sessions{1} + "/" +folders{1} + "/*" );

end


