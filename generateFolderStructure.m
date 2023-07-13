function [dirTree, encoding, modality] = generateFolderStructure(base, modality, encoding)
    % Recursively create a directory tree from the base path up to a depth
    % specified by parameter.
    %
    % :param base: base path
    % :type base: string
    % 
    % :param modality: structure handling compatabilities and depth search
    % :type depth: struct with properties: .compatible
    %                                      .depth_initiation
    %                                      .focus_files
    %
    % :param encoding: structure with encoding information about file
    % :type encoding
    %
    % :returns: - :dirTree: type: struct: corresponding to directory folder
    % and file tree to root folder specified by base parameter
    %
    %
    % 5.15.2023 - Alex Estrada - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % get list of files and oflders within root folder
    contents = dir(base);
    if isempty(contents)
        warning('Directory search not found.')
        return
    end

    % remove hidden files/folders (starting with a dot)
    contents = contents(~startsWith({contents.name}, '.'));

    % seperating and appending files/folders
    files_tbl = struct2table(contents(~[contents.isdir]));
    folders_tbl = struct2table(contents([contents.isdir]));
    files = files_tbl(:,1:2);
    folders = folders_tbl(:,1:2);
    
    % creating dirTree structure
    dirTree = struct('name', contents(1).folder,...
                     'files', files,...
                     'folders', folders, ...
                     'substructures', {cell(height(folders))});
    
    % generate folder structure for substructure
    if modality.depth_initiation > 0

        for i = 1:height(dirTree.substructures)
            if height(folders.name) == 1
                folder_name = string(folders.name);
            else
                try
                    folder_name = string(folders.name{i});
                catch
                    disp(folder_name)
                end
            end
            new_dir = string(dirTree.name) + "/" + folder_name + "/";
            % check for desired folders
            [encoding, modality] = find_folders(folder_name, modality, encoding);
            % generating substructure tree
            [subTree, encoding, ~] = generateFolderStructure(new_dir, modality, encoding);
            dirTree.substructures(i) = {subTree};
        end

        % update depth
        modality.depth_initiation = modality.depth_initiation - 1;
    end
end
