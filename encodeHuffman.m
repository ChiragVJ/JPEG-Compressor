function [zipped,info] = encodeHuffman(vector)



% ensure to handle uint8 input vector
if ~isa(vector,'uint8'),
	error('input argument must be a uint8 vector')
end

% vector as a row
vector = vector(:)';

% frequency
f = frequency(vector);

% symbols presents in the vector are
symbols = find(f~=0); % first value is 1 not 0!!!
f = f(symbols);

% sort using the frequency
[f,sorti] = sort(f);
symbols = symbols(sorti);

% generate the codeWs as the 52 bits of a double
len = length(symbols);
simbols_i = num2cell(1:len);
codeW_tmp = cell(len,1);
while length(f)>1,
	i1 = simbols_i{1};
	i2 = simbols_i{2};
	codeW_tmp(i1) = addnode(codeW_tmp(i1),uint8(0));
	codeW_tmp(i2) = addnode(codeW_tmp(i2),uint8(1));
	f = [sum(f(1:2)) f(3:end)];
	simbols_i = [{[i1 i2]} simbols_i(3:end)];
	% resort data in order to have the two nodes with lower frequency as first two
	[f,sorti] = sort(f);
	simbols_i = simbols_i(sorti);
end

% arrange cell array to have correspondance simbol <-> codeW
codeW = cell(256,1);
codeW(symbols) = codeW_tmp;

% calculate full string length
len = 0;
for i=1:length(vector),
	len = len+length(codeW{double(vector(i))+1});
end
	
% create the full 01 sequence
string = repmat(uint8(0),1,len);
pointer = 1;
for i=1:length(vector),
	code = codeW{double(vector(i))+1};
	len = length(code);
	string(pointer+(0:len-1)) = code;
	pointer = pointer+len;
end

% calculate if it is necessary to add padding zeros
len = length(string);
pad = 8-mod(len,8);
if pad>0,
	string = [string uint8(zeros(1,pad))];
end

% now save only usefull codeWs
codeW = codeW(symbols);
codelen = zeros(size(codeW));
weights = 2.^(0:51);
maxcodelen = 0;
for i = 1:length(codeW),
	len = length(codeW{i});
	if len>maxcodelen,
		maxcodelen = len;
	end
	if len>0,
		code = sum(weights(codeW{i}==1));
		code = bitset(code,len+1);
		codeW{i} = code;
		codelen(i) = len;
	end
end
codeW = [codeW{:}];

% calculate zipped vector
columns = length(string)/8;
string = reshape(string,8,columns);
weights = 2.^(0:7);
zipped = uint8(weights*double(string));

% store data into a sparse matrix
huffcodes = sparse(1,1); % init sparse matrix
for i = 1:numel(codeW),
	huffcodes(codeW(i),1) = symbols(i);
end

% create info structure
info.pad = pad;
info.huffcodes = huffcodes;
info.ratio = columns./length(vector);
info.length = length(vector);
info.maxcodelen = maxcodelen;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function codeW_new = addnode(codeW_old,item)
codeW_new = cell(size(codeW_old));
for i = 1:length(codeW_old),
	codeW_new{i} = [item codeW_old{i}];
end