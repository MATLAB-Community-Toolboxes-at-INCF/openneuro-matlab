function [encoding, modality] = find_folders(folder_name, modality, encoding)
% Checks folders of focus (i.e "eeg", "beh", "anat", etc) as folder
% generation is taking place.
%   Property 'modality.focus_files' = true/false depending on whether
%   folder of interest is found as specified by the modality. 
% 
%   TODO: correct user if specified modality was wrong.
%
% 6.5.2023 - Alex Estrada - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Case: Already found
    if modality.focus_files; return; end
    
    %% Case: Correct/No modality specified

    % assist determining modality
    assist = 0;

    % check encoding modality
    if strcmp(encoding.modality, ""); assist = 1; end

    % folders of interest
    temp = encoding.modality_properties("folders");
    folder_list = temp{:};

    % compare
    if any(strcmpi(folder_name, [folder_list{:}])) && ~modality.focus_files

        % assist in determining modality if not specified
        if assist
            idx = find(strcmpi(folder_name, [folder_list{:}]));
            switch true
                % assuming: all = eeg beh anat func fmap
                case idx > 0 && idx < 2
                    encoding.modality = "eeg";
                case idx > 2 && idx < 5
                    encoding.modality = "mri";
            end

            % inform user
            txt = "System detected dataset type: ";
            disp(txt+upper(encoding.modality))

            % update encoding for extensions
            encoding.modality_properties = create_moprop(encoding.modality);
        end

        % update
        modality.focus_files = true;
    end
end
