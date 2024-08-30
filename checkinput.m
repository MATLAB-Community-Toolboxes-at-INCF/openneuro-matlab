function b = checkinput(b, bucket, ds_ID, varargin)
    
% TODO between varagin and encoding

    if nargin > 2

    % make the input compatible 
    input = lower([bucket, ds_ID, b.encoding.modality]);
    
    b.encoding.modality_properties = get_value(input(3));
   
    % add more checking
    b.encoding.bucket = input(1) + "/";
    b.encoding.ID = input(2);
    b.encoding.modality = input(3);
    elseif nargin > 3
        b.encoding.extension = varargin{:};
    else
    end

end
