function f = frequency(vector)
% ensure to handle uint8 input v
if ~isa(vector,'uint8'),
	error('input argument must be a uint8 v')
end
% create f
f = histcounts(vector(:), 0:255); f = f(:)'/sum(f); % always make a row of it
