%code snippet from codeUsedForResearch/HAS Bacteria Codes/binarize.m
%binaize image of floursecent bacteria so that we can compute bacteria
%total volume which is proportional to number of bright voxel
function binary_image = binarize(image, threshold)
A = image;
A = double(A);
% figure('name', 'Original'); imshow(A, []);
A = medfilt2(A,[2,2]);
%% filtering

hsize = 7;
sigma = 2;
hGaussian = fspecial('gaussian', hsize, sigma);
A_lp = imfilter(A, hGaussian, 'same', 'symmetric');  % low pass filter

A_hp = A - A_lp;  % high pass filter
% Binarize
A_binary = ones(size(A_hp));
A_binary(A_hp < threshold) = 0;
%Morphological object closure
se = strel('disk', 1);
A_binary = imclose(A_binary, se);
A_binary = bwareaopen(A_binary, 3);
binary_image = logical(A_binary);
