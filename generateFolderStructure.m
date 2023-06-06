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
    % Alex Estrada 5.15.2023

    % get list of files and oflders within root folder
    contents = dir(base);

    % remove hidden files/folders (starting with a dot)
    contents = contents(~startsWith({contents.name}, '.'));
    
    % seperating and appending files/folders
    files = contents(~[contents.isdir]);
    folders = contents([contents.isdir]);
    
    % creating dirTree structure
    dirTree = struct('name', contents(1).folder,...
                     'files', files,...
                     'folders', folders, ...
                     'substructures', {cell(length(folders),1)});
    
    % generate folder structure for substructure
    if modality.depth_initiation > 0

        for i = 1:numel(dirTree.substructures)
            new_dir = string(dirTree.name)+"/"+string(folders(i).name)+"/";
            % check for desired folders
            [encoding, modality] = find_folders(folders(1).name, modality, encoding);
            % generating substructure tree
            [subTree, ~, ~] = generateFolderStructure(new_dir, modality, encoding);
            dirTree.substructures(i) = {subTree};
        end

        % update depth
        modality.depth_initiation = modality.depth_initiation - 1;
    end
end

