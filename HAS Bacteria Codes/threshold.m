function threshold = threshold(image, threshold_std)
A = image;
A = double(A);
% figure('name', 'Original'); imshow(A, []);

%% filtering

hsize = 7;
sigma = 2;
hGaussian = fspecial('gaussian', hsize, sigma);
A_lp = imfilter(A, hGaussian, 'same', 'symmetric');  % low pass filter

% figure('name', 'Low Pass'); imshow(A_lp, []);
A_hp = A - A_lp;  % high pass filter
% figure('name', 'High Pass'); imshow(A_hp, []);

% Binarize
A_binary = ones(size(A_hp));
medianvalA_hp = median(A_hp(:));
stdvalA_hp = std(A_hp(:));
threshold = medianvalA_hp +threshold_std*stdvalA_hp;



% Next steps: region sizes (delete small regions, or perform closures)
% Alternative approaches: Look for local maxima, use these to seed
% segmentation
