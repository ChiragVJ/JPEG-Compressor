function vector = decodeHuffman(zipped,info)

if ~isa(zipped,'uint8'),
	error('input argument must be a uint8 vector')
end

len = length(zipped);
string = repmat(uint8(0),1,len.*8);
b_index = 1:8;
for index = 1:len,
	string(b_index+8.*(index-1)) = uint8(bitget(zipped(index),b_index));
end
	

string = logical(string(:)');
len = length(string);
string((len-info.pad+1):end) = []; 
len = length(string);

w = 2.^(0:51);
vector = repmat(uint8(0),1,info.length);
v_index = 1;
c_index = 1;
code = 0;
for index = 1:len,
	code = bitset(code,c_index,string(index));
	c_index = c_index+1;
	byte = decode(bitset(code,c_index),info);
	if byte>0, 
		vector(v_index) = byte-1;
		c_index = 1;
		code = 0;
		v_index = v_index+1;
	end
end

function byte = decode(code,info)
byte = info.huffcodes(code);
