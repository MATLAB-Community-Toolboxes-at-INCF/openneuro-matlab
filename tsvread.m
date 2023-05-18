function x = tsvread(filename, delim, header)
% Read delimiter-separated values file into a structure array
% * header line of column names will be used if detected
% * 'n/a' fields are replaced with NaN
%
% USAGE:
%
%       x = tsvread('filename.tsv', '/t/' [optional], true [optional])
%
% :param filename: filename (can be gzipped) {txt,mat,csv,tsv,json}ename
% :type filename: string
%
% :param delim: delimeter [default: '\t']
% :type delim char
%
% :param header: detect the presence of a header row for csv/tsv [default: ``true``]
% :type hdr: boolean
%
% :returns: - :x: type: struct: corresponding data array or structure
%
%
% Adapted from bids-standard / bids-matlab
% https://github.com/bids-standard/bids-matlab/blob/master/%2Bbids/%2Butil/tsvread.m
%
% Alex Estrada 4.30.2023

% arguments
    arguments
        filename    string
        delim       char    = '/t'
        header      logical = true
    end

% -Check input arguments
  % --------------------------------------------------------------------------
  if nargin < 1
    error('no input file specified');
  end

  if ~exist(filename, 'file')
    error('Unable to read file ''%s'': file not found', filename);
  end

% -Input arguments
% --------------------------------------------------------------------------
if nargin < 2
    delim = '\t';
end
if nargin < 3
    header = true;
end % true: detect, false: no
delim = sprintf(delim);
eol = sprintf('\n'); %#ok<SPRINTFN>

% -Read file
% --------------------------------------------------------------------------
S = fileread(filename);
if isempty(S)
    x = [];
    return
end

if S(end) ~= eol
    S = [S eol];
end
S = regexprep(S, {'\r\n', '\r', '(\n)\1+'}, {'\n', '\n', '$1'});

% -Get column names from header line (non-numeric first line) 
% --------------------------------------------------------------------------
h = find(S == eol, 1);
hdr = S(1:h - 1);
var = regexp(hdr, delim, 'split');
N = numel(var);
n1 = isnan(cellfun(@str2double, var));
n2 = cellfun(@(x) strcmpi(x, 'NaN'), var);
if header && any(n1 & ~n2)
    hdr = true;
    try
      var = genvarname(var);
    catch
      var = matlab.lang.makeValidName(var, 'ReplacementStyle', 'hex');
      var = matlab.lang.makeUniqueStrings(var);
    end
    S = S(h + 1:end);
else
    hdr = false;
    fmt = ['Var%0' num2str(floor(log10(N)) + 1) 'd'];
    var = arrayfun(@(x) sprintf(fmt, x), (1:N)', 'UniformOutput', false);
end

% -Parse file 
% --------------------------------------------------------------------------
if ~isempty(S)
    d = textscan(S, '%s', 'Delimiter', delim);
else
    d = {[]};
end
if rem(numel(d{1}), N)
    error('Invalid TSV file ''%s'': Varying number of delimiters per line.', ...
          filename);
end
d = reshape(d{1}, N, [])';
allnum = true;
for i = 1:numel(var)
    sts = true;
    dd = zeros(size(d, 1), 1);
    for j = 1:size(d, 1)
        if strcmp(d{j, i}, 'n/a')
            dd(j) = NaN;
        else
            dd(j) = str2double(d{j, i}); % i,j considered as complex
        if isnan(dd(j))
          sts = false;
          break
        end
        end
    end
    if sts
      x.(var{i}) = dd;
    else
      x.(var{i}) = d(:, i);
      allnum = false;
    end
end

if ~hdr && allnum
    x = struct2cell(x);
    x = [x{:}];
end

end % End of function

