close all;

% choose quantization quality
quantQual = {'Enter quantization quality'};
dialogtitle = 'User Input';
dimens = [1 35];
definput = {'50'};
answer = inputdlg(quantQual,dialogtitle,dimens,definput);

quality = str2double(answer{1});

% input image
file_name=uigetfile({'*.bmp';'*.png'},'Select an Image File');
input = imread(file_name);
[pathstr,name,ext] = fileparts(file_name);

% check if grayscale or colour image
answer = questdlg('Is the image in grayscale or colour?', ...
    'Grayscale or Colour', ...
    'Grayscale','Colour', 'Colour');

% handle response from user
switch answer
    case 'Grayscale'
        is_grayscale = true;
        input = im2gray(input);
    case 'Colour'
        is_grayscale = false;
end

% set number of blocks for the quantization matrix
% and calculate dimensions. Also initialise variables for later use.
image_width = size(input,1); image_height = size(input,2);
no_of_channels = size(input,3);
[og_rows, og_columns] = size(input);


% map the images with ycbcr for downsampling later
if (no_of_channels > 1)
    y_d = rgb2ycbcr(im2double(input));
    hascolor = 1;
else
    % convert to double precision value
    y_d = im2double(input);
end

% output original image
% zero matrix that we will use later
output_image = zeros(size(input), 'double');

% create a standard DCT and set the scale (255) for quantization
n = 8;
T = dctmtx(n);
q_max = 255;

% quantization
% scale the matrices based on the scale factor calculated from quality
q = 100/quality;
% luminance
q_y = [ 16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99 ].*q; % 50% compression

% chrominance values
q_c = [ 17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99 ].*q;
% Block processing
% DCT and Inverse DCT functions
% computes 2d dct for each 8x8 block
DCT = @(block_struct) T * block_struct.data * T';
I_DCT = @(block_struct) T' * block_struct.data * T;

start_time = cputime; % use this to measure performance

% Downsampling, DCT, Quantization, Huffman Coding and Decoding,
if is_grayscale == false
    y_d(:,:,2) = 2*(y_d(:,:,2)/2);
    y_d(:,:,3) = 2*(y_d(:,:,3)/2);
end

for ch=1:no_of_channels
    % retrieve the channel for the color downsampling
    current_colourmap = y_d(:,:,ch);
    
    fprintf("Downsampling and DCT %d\n", ch);
    
    
    
    % apply DCT and add padding to the partial blocks to make them full
    % size
    channel_dct = blockproc(current_colourmap, [n n], DCT, 'PadPartialBlocks', true).*q_max;
    
    fprintf("Quantization for channel %d\n", ch);
    % downsampling the colors and quantizing for the luminance and
    % chrominance values
    if (ch == 1)
        quant_chan = blockproc(channel_dct,[n n], @(block_struct)...
            round(block_struct.data./q_y));
    else
        quant_chan = blockproc(channel_dct,[n n], @(block_struct)...
            round(block_struct.data./q_c));
    end
    
    % zigzag encoding to convert to 1d array
    fprintf("Zigzag encode for channel %d\n", ch);
    zigzag_out= zigzag(quant_chan);
    zigzag_out = uint8(zigzag_out);
    % huffman encode converts reduces the pixel values that occur
    % frequently
    fprintf("Huffman encode for channel %d\n", ch);
    [dict,info] = encodeHuffman(zigzag_out);

    
    % hufman decode, use symbols stored in dictionary
    fprintf("Huffman decode for channel %d\n", ch);
    
    zigzag_out = decodeHuffman(dict,info);
    
    % inverse zigzag on the huffman vector
    fprintf("Zigzag inverse for channel %d\n", ch);
    inverse_zigzag_out=invzigzag(zigzag_out,image_width,image_height);
    
    quant_chan=inverse_zigzag_out;
    compressed=inverse_zigzag_out;
    % Dequantization and Inverse DCT
    % dequantization
    fprintf("Dequantization for channel %d\n", ch);
    if (ch == 1)
        quant_chan = blockproc(quant_chan,[n n],...
            @(block_struct)block_struct.data.*q_y);
    else
        quant_chan = blockproc(quant_chan,[n n],...
            @(block_struct)block_struct.data.*q_c);
    end
    
    % Inverse DCT
    output_data = blockproc(quant_chan./q_max,[n n],I_DCT);
    
    % Add the dimensions back into the image
    output_image(:,:,ch) = output_data(1:image_width, 1:image_height);
end

if (~is_grayscale)
    output_image = im2uint8(ycbcr2rgb(output_image));
end

decompressed = im2uint8(output_image);

% save image
finalName = sprintf('%s result_myown.jpg', name);
imwrite(output_image, finalName);
end_time = cputime;
total_time = end_time-start_time;

% calculate the bitrate for the image
og_dir = dir(file_name);
decomp_dir = dir(finalName);
og_imgsize = sprintf("Original size: %0.4f KB", og_dir.bytes/1024);
decomp_imgsize = sprintf("Decompressed size: %0.4f KB", decomp_dir.bytes/1024);

% compute computation time
computation_time = sprintf("Computation time: %0.4f", total_time);
% compute compression ratio
ratio = (og_dir.bytes/1024)/(decomp_dir.bytes/1024);
comp_ratio = sprintf("Compression Ratio: %0.7f", ratio*100);

% compute mse and psnr
mse = mean(mean((im2double(input) - im2double(output_image)).^2, 1), 2);
psnr = 10 * log10(1 ./ mean(mse,3));

% the lower the MSE the more close it is to the original
mean_squared_error = sprintf("MSE: %0.7f", mean(mse,3)*1000);

% the higher the PSNR the higher the quality of the decompressed image
peak_signal_noise_ratio = sprintf("PSNR: %9.7f dB", psnr);

% plot results
subplot(2,5,1), imshow(input), title(sprintf("Input " + og_imgsize));
subplot(2,5,2), imshow(current_colourmap), title("Grayscale")
subplot(2,5,3), imshow(channel_dct), title("DCT of image")
subplot(2,5,4), imshow(output_data), title("IDCT")
subplot(2,5,7), imshow(output_image), title(sprintf("Output " + ...
    decomp_imgsize + ". " + comp_ratio));

% dialog box with image info
f = msgbox({computation_time; mean_squared_error; peak_signal_noise_ratio;...
    comp_ratio; og_imgsize; decomp_imgsize});