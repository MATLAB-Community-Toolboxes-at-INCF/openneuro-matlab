function b = checkinput(b, bucket, ID, modality)
    
    % make the input compatible 
    input = lower([bucket, ID, modality]);
    
    b.encoding.modality_properties = get_value(input(3));
   
    % add more checking
    b.encoding.bucket = input(1) + "/";
    b.encoding.ID = input(2);
    b.encoding.modality = input(3);
end
