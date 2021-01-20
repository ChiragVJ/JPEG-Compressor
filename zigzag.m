function out = zigzag(in)

[number_of_rows number_of_columns]=size(in);

out=zeros(1,number_of_rows*number_of_columns);
current_row=1;	current_column=1;	index=1;

while current_row<=number_of_rows & current_column<=number_of_columns
	if current_row==1 & mod(current_row+current_column,2)==0 & current_column~=number_of_columns
		out(index)=in(current_row,current_column);
		current_column=current_column+1;							%move right at the top
		index=index+1;
		
	elseif current_row==number_of_rows & mod(current_row+current_column,2)~=0 & current_column~=number_of_columns
		out(index)=in(current_row,current_column);
		current_column=current_column+1;							%move right at the bottom
		index=index+1;
		
	elseif current_column==1 & mod(current_row+current_column,2)~=0 & current_row~=number_of_rows
		out(index)=in(current_row,current_column);
		current_row=current_row+1;							%move down at the left
		index=index+1;
		
	elseif current_column==number_of_columns & mod(current_row+current_column,2)==0 & current_row~=number_of_rows
		out(index)=in(current_row,current_column);
		current_row=current_row+1;							%move down at the right
		index=index+1;
		
	elseif current_column~=1 & current_row~=number_of_rows & mod(current_row+current_column,2)~=0
		out(index)=in(current_row,current_column);
		current_row=current_row+1;		current_column=current_column-1;	%move diagonally left down
		index=index+1;
		
	elseif current_row~=1 & current_column~=number_of_columns & mod(current_row+current_column,2)==0
		out(index)=in(current_row,current_column);
		current_row=current_row-1;		current_column=current_column+1;	%move diagonally right up
		index=index+1;
		
	elseif current_row==number_of_rows & current_column==number_of_columns	%obtain the bottom right element
        out(end)=in(end);							%end of the operation
		break										%terminate the operation
    end
end