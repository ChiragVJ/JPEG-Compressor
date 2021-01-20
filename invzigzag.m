function out=invzigzag(in,number_of_rows,number_of_columns)

total_elements=length(in);
if nargin>3
	error('Too many input arguments');
elseif nargin<3
	error('Too few input arguments');
end
% Check if matrix dimensions correspond
if total_elements~=number_of_rows*number_of_columns
	error('Matrix dimensions do not coincide');
end
% Initialise the output matrix
out=zeros(number_of_rows,number_of_columns);
current_row=1;	current_column=1;	index=1;
% First element
%out(1,1)=in(1);
while index<=total_elements
	if current_row==1 & mod(current_row+current_column,2)==0 & current_column~=number_of_columns
		out(current_row,current_column)=in(index);
		current_column=current_column+1;							%move right at the top
		index=index+1;
		
	elseif current_row==number_of_rows & mod(current_row+current_column,2)~=0 & current_column~=number_of_columns
		out(current_row,current_column)=in(index);
		current_column=current_column+1;							%move right at the bottom
		index=index+1;
		
	elseif current_column==1 & mod(current_row+current_column,2)~=0 & current_row~=number_of_rows
		out(current_row,current_column)=in(index);
		current_row=current_row+1;							%move down at the left
		index=index+1;
		
	elseif current_column==number_of_columns & mod(current_row+current_column,2)==0 & current_row~=number_of_rows
		out(current_row,current_column)=in(index);
		current_row=current_row+1;							%move down at the right
		index=index+1;
		
	elseif current_column~=1 & current_row~=number_of_rows & mod(current_row+current_column,2)~=0
		out(current_row,current_column)=in(index);
		current_row=current_row+1;		current_column=current_column-1;	%move diagonally left down
		index=index+1;
		
	elseif current_row~=1 & current_column~=number_of_columns & mod(current_row+current_column,2)==0
		out(current_row,current_column)=in(index);
		current_row=current_row-1;		current_column=current_column+1;	%move diagonally right up
		index=index+1;
		
	elseif index==total_elements						%input the bottom right element
        out(end)=in(end);							%end of the operation
		break										%terminate the operation
    end
end