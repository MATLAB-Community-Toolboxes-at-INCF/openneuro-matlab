function folderStructure = generateFolderStructure(rootFolder)
    % Initialize folder structure
    folderStructure = struct('name', '', 'files', [], 'subfolderStructure', {struct});

    % Generate folder structure recursively
    num = 0;
    folderStructure = generateFolderStructureRecursive(rootFolder, folderStructure, num);
end

