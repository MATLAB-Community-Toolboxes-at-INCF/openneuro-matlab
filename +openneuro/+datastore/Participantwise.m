classdef Participantwise < matlab.io.Datastore
    %PARTICIPANTWISE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden)
        % Dictionary mapping type names to read settings
        Type = containers.Map( ...
            {'Anatomical NIfTI', 'EEG EDF', 'Functional NIfTI', 'DWI', 'Fieldmap', 'JSON Files', 'TSV Files'}, ...
            {struct('ReadFcn', @niftiread, 'FileExtensions', {{'.nii.gz', '.nii'}}, 'FolderPath', 'anat'), ...
            struct('ReadFcn', @edfread, 'FileExtensions', {{'.edf'}}, 'FolderPath', 'eeg'), ...
            struct('ReadFcn', @niftiread, 'FileExtensions', {{'.nii.gz', '.nii'}}, 'FolderPath', 'func'), ...
            struct('ReadFcn', @niftiread, 'FileExtensions', {{'.nii.gz', '.nii'}}, 'FolderPath', 'dwi'), ...
            struct('ReadFcn', @niftiread, 'FileExtensions', {{'.nii.gz', '.nii'}}, 'FolderPath', 'fmap'), ...
            struct('ReadFcn', @(f) jsondecode(fileread(f)), 'FileExtensions', {{'.json'}}, 'FolderPath', 'anat'), ...
            struct('ReadFcn', @readtable, 'FileExtensions', {{'.tsv', '.txt'}}, 'FolderPath', 'anat') ...
            } ...
        )
    end

    properties (Dependent)
        AvailableTypes  % List of supported type keys
    end

    properties
        fileDatastoreObj  % Public fileDatastore object for MVP mode
    end
    
    properties (Access = private)
        CurrentFileIndex    double;
        FileSet matlab.io.datastore.DsFileSet;
        isMVPMode           logical = false;  % Track which mode we're in
    end
    
    methods
        function keys = get.AvailableTypes(obj)
            % List available types from the Type dictionary
            keys = obj.Type.keys;
        end

        function obj = Participantwise(dataset,spec)
            % Constructor supporting both MVP mode and original mode
            %
            % MVP Mode (dictionary-based spec):
            %   obj = Participantwise("Anatomical NIfTI")
            %
            % Original Mode (structure-based spec):
            %   obj = Participantwise(dataset, filesetSpec)

            if isStringScalar(spec) || (ischar(spec) && isvector(spec))
                % MVP MODE: dictionary-based spec
                %typeName = varargin{1};
                
                % Validate type name against the Type dictionary using keys() method
                if ~isKey(obj.Type, spec)
                    error('Invalid type specified. Available types are: %s', strjoin(obj.AvailableTypes, ', '));
                end
                
                obj.isMVPMode = true;
                obj = createMVPDatastore(obj, dataset, spec);
                
            else %if nargin == 2
                % ORIGINAL MODE: structure-based spec
                %dataset = varargin{1};
                filesetSpec = spec; %varargin{2};
                
                % Validate arguments (original validation)
                if ~isa(dataset, 'openneuro.Dataset')
                    error('First argument must be an openneuro.Dataset object');
                end
                if ~isstruct(filesetSpec)
                    error('Second argument must be a struct');
                end
                
                obj.isMVPMode = false;
                obj = createOriginalDatastore(obj, dataset, filesetSpec);
                
            % else
            %     error('Constructor requires either 1 argument (MVP mode) or 2 arguments (original mode). Got %d arguments.', nargin);
            end
        end

        function reset(obj)
            % Reset to the start of the data.
            if obj.isMVPMode && ~isempty(obj.fileDatastoreObj)
                reset(obj.fileDatastoreObj);
            else
                reset(obj.FileSet);
            end
            obj.CurrentFileIndex = 1;
        end
      
        function tf = hasdata(obj)
            % Return true if more data is available.
            if obj.isMVPMode && ~isempty(obj.fileDatastoreObj)
                tf = hasdata(obj.fileDatastoreObj);
            else
                tf = hasfile(obj.FileSet);
            end
        end

        function [data, info] = read(obj)
            % MVP read method - no arguments, dispatches appropriately
            if obj.isMVPMode && ~isempty(obj.fileDatastoreObj)
                % MVP mode: dispatch to fileDatastore.read()
                [data, info] = read(obj.fileDatastoreObj);
            else
                % Original mode: use FileSet reading
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
                    obj.CurrentFileIndex = obj.CurrentFileIndex + 1;
                end
            end
        end
    end

    methods (Access = private)
        function obj = createMVPDatastore(obj, dataset, typeName)
            % Create MVP mode datastore using Type dictionary
            
            % Get the specification for this type
            spec = obj.Type(typeName);
            
            % Construct fileDatastore object using the Type specification
            %defaultPath = fullfile(pwd, "ds001415/");
            %searchPath = fullfile(defaultPath, 'sub-01', spec.FolderPath);
            searchPath = fullfile(dataset.URI,dataset.ParticipantIDs(1), spec.FolderPath);
            
            try
                obj.fileDatastoreObj = fileDatastore( ...
                    searchPath, ...
                    'ReadFcn', spec.ReadFcn, ...
                    'IncludeSubfolders', true, ...
                    'FileExtensions', spec.FileExtensions ...
                );
            catch e
                warning('Failed to create MVP datastore:\n%s', getReport(e));
                % Create empty datastore as fallback
                obj.fileDatastoreObj = fileDatastore(pwd, 'ReadFcn', @readtable);
                obj.fileDatastoreObj.Files = {};
            end
        end
        
        function obj = createOriginalDatastore(obj, dataset, filesetSpec)
            % Create original mode datastore (unchanged logic)
            
            obj.FileSet = matlab.io.datastore.DsFileSet(computeLocations(dataset,filesetSpec),'FileExtensions',filesetSpec.extensionList);
            obj.CurrentFileIndex = 1;
            reset(obj);
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