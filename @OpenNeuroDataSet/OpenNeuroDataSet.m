classdef OpenNeuroDataSet
% Creates data set summary

    properties
        participants    table   = table     % data table: participants.tsv
        about_dataset   struct  = struct    % dataset_description.json
        info            struct  = struct    % participants.json
        encoding        struct  = struct    % data encoding information
                                            % .bucket 
                                            % .ID
                                            % .dir
                                            % .modality
                                            % .modality_properties
    end


    % properties (Hidden = true)
    %     filepaths       struct  = table    % table with filepaths
    % end

    methods

        function b = OpenNeuroDataSet(ID, modality)

            arguments
                ID          string      = string
                modality    string      = string
            end
       
         bucket = "openneuro.org";

         b = checkinput(b, bucket, ID, modality);


         % base directory
            dir_base = "s3://" + b.encoding.bucket +"/" + b.encoding.ID;
            b.encoding.dir = dir_base;

          
         % search for participants.tsv
         try
            b.participants = readtable(fullfile(dir_base + "/participants.tsv"), 'FileType', 'delimitedtext');
         catch
             warning("Partcipants.tsv  not found. Individualixed loading of" + ...
                 "participants will not be avaiable")
         end
         
         try 
         % search for about_dataset
         b.about_dataset = jsondecode(fileread(dir_base + "/dataset_description.json"));
         catch
             warning('Data set description not found.')
         end

         try 
         % serach for info (participant.json)
         b.info = jsondecode(fileread(dir_base + "/participants.json"));
         catch
             warning('Participants.json not found.')
         end

        % implementation of addParticipantwiseDataStore

        function ds = addParticipantwiseDataStore(obj, sub_ID)
       
        end

        % fprintf("Partcipants available are:" )
        % disp(b.participants(1,1))

          
        end
    end
end
