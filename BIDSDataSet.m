classdef BIDSDataSet


    properties
        participants    table   = table     % data table
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
        encoding        struct  = struct    % data encoding information
                                            % .bucket 
                                            % .ID
                                            % .dir
                                            % .modality
                                            % .modality_properties
    end

    methods

        function b = BIDSDataSet(bucket, ID, modality)

            arguments
                bucket      string      = "openneuro.org"
                ID          string      = string
                modality    string      = string
            end
       
          
         b = checkinput(b, bucket, ID, modality);


         % base directory
            dir_base = "s3://" + b.encoding.bucket +"/" + b.encoding.ID;
            b.encoding.dir = dir_base;
            
            % create repository structure
            try
                pass
                %[dir_tree, b.encoding, b.modality] = generateFolderStructure(dir_base, b.modality, b.encoding);
                %b.folder_files = dir_tree;
            catch
                %error(['Unable to access or find given bucket/ID. Check for ' ...
                       %'typos or permissions and try again.'])
            end

         % search for participants.tsv
         b.participants = readtable(fullfile(dir_base + "/participants.tsv"), 'FileType', 'delimitedtext');
         
        end
    end
end
