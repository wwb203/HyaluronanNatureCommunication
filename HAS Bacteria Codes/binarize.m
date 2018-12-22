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

% figure('name', 'Low Pass'); imshow(A_lp, []);
A_hp = A - A_lp;  % high pass filter
% figure('name', 'High Pass'); imshow(A_hp, []);
% A_hp = medfilt2(A_hp,[2,2]);
% Binarize
A_binary = ones(size(A_hp));
A_binary(A_hp < threshold) = 0;
% figure('name', 'Binary'); imshow(A_binary, []);

%Morphological object closure
se = strel('disk', 1);
A_binary = imclose(A_binary, se);

% figure('name', 'Binary'); imshow(A_binary, []);


A_binary = bwareaopen(A_binary, 3);
binary_image = logical(A_binary);



% Next steps: region sizes (delete small regions, or perform closures)
% Alternative approaches: Look for local maxima, use these to seed
% segmentation
