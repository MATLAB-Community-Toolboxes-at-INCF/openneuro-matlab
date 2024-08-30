function b = addRootDir(b)

if isprop(b, "root_dir");
    warning('A root directory has already been added')
else 
    b.addprop("root_dir");
    b.root_dir = dir(b.encoding.dir);
end

% check for files in the root directory

root_table =  struct2table(b.root_dir);
if sum(contains(root_table.name,'derivatives'))
    disp("Derivatives found")
end
%path = b.encoding.dir + "/" + b.sub_IDs{1}

%dir(b.econding.dir)
end

