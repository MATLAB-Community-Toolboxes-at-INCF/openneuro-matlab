function folderStructure = generateFolderStructureRecursive(folderPath, folderStructure, num)
    % Get list of files and folders within the current folder
    contents = dir(folderPath);
    
    % Remove hidden files/folders (starting with a dot)
    contents = contents(~startsWith({contents.name}, '.'));

    % Iterate over each entry
    for i = 1:numel(contents)
        entry = contents(i);
        
        if entry.isdir
            if num < 2
                % If the entry is a folder, create a nested structure and
                % recursively generate structure for the subfolder
                subfolderPath = fullfile(folderPath, entry.name);
                subfolderStructure = struct('name', entry.name, 'files', [], 'subfolderStructure', {struct});
                subfolderStructure = generateFolderStructureRecursive(subfolderPath+"/", subfolderStructure, num+1);

                % Append subfolder structure to the parent folder structure
                folderStructure.subfolderStructure = {folderStructure.subfolderStructure, subfolderStructure};
            else
                return
            end

        else
            % If the entry is a file, append its name to the current folder structure
            folderStructure.name = entry.folder;
            folderStructure.files = [folderStructure.files, entry.name];
        end
    end
end

