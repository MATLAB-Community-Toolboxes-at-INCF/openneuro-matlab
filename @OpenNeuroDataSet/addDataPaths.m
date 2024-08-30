function b = addDataPaths(b)

if isprop(b, "data_paths");
    warning('A data paths directory has already been added')
else 
    b.addprop("data_paths");
end

dir(b.econding.dir)

end

