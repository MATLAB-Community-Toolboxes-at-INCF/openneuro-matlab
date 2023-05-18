classdef BIDSDataStore < matlab.io.Datastore
    % BIDSDataStore inherits from matlab.io.Datastore and implements an 
    % interface between a file folder validly organized to the BIDS 
    % (https://bids.neuroimaging.io/) data organization standard and the 
    % MATLAB datastore type

    properties
        Participant_ID  cell    = {}
        dir             string  = ""
    end

    methods
        
        function ds = BIDSDataStore(ID, dir)
            %BIDSDataStore contains subject data
            %   Initialized with BIDS class to hold pointers to location of
            %   individual data files.

            arguments
                ID      cell    = {}
                dir     string  = ""
            end

            % create datastore object
            ds = ds@matlab.io.Datastore();
            
            % setting subject ID
            ds.Participant_ID = ID;

            % setting individual directory
            ds.dir = dir + ID + "/";
        end

        function data = read(ds)
            % implement reader method for data files
            % read one data file at a time and return it
        end
        
        function reset(ds)
            % implement reset method
            % reset the datastore to the first file
        end
        
        function [info, err] = preview(ds)
            % implement preview method
            % preview the first file in the datastore
        end
        
        function tf = hasdata(ds)
            % implement hasdata method
            % check if there is more data to read
        end

    end
end