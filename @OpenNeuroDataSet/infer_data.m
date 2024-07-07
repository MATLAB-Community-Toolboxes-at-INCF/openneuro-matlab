function b = infer_data(b)

if isprop(b, "root_dir");
    warning('A root directory has already been added')
else 
    b.addprop("root_dir");
    b.root_dir = dir(b.encoding.dir)
end



b.addprop("data_paths");
path = b.encoding.dir + "/" + b.sub_IDs{1}

dir(b.econding.dir)


% get the dictionary


%datastorequey(path_for_sessionID)
end

