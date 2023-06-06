function [encoding, modality] = find_folders(folder_name, modality, encoding)
    % determine if key folders have been found
    
    try
        % assist determining modality
        assist = 0;

        % check encoding modality
        if strcmp(encoding.modality, "")
            assist = 1;
            temp = encoding.modality_properties("all");
        else
            % explicit modality at initiation
            temp = encoding.modality_properties(encoding.modality);
        end

        % split string
        folder_list = strsplit(temp, '.');
    
        % compare
        if any(strcmp(folder_name, folder_list))
            modality.focus_files = true;

            % assist in determining modality if not specified
            if assist
                idx = find(strcmp(folder_name, folder_list));
                switch true
                    % assuming: all = "eeg beh anat func fmap"
                    case idx > 0 && idx < 2
                        encoding.modality = "eeg";
                    case idx > 2 && idx < 5
                        encoding.modality = "mri";
                end
            end
        end

    catch
        % unspecified modality
        warning("Unspecified modality. Something went wrong.")
    end
end

