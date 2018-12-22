%process PEA image
%glass beads
G0 = imread('C001.tif');
G0 = G0(:,:,2);
level = graythresh(G0);
GBW = im2bw(G0,level*2.3);
GBW = bwareaopen(GBW,10);
GBW = imclose(GBW,strel('disk',5));
GBW = imfill(GBW,'holes');
props = regionprops(GBW,'Centroid','Perimeter');
centroid = round(props.Centroid);
GBWB = bwperim(GBW);
overlay1 = imoverlay(imadjust(G0),GBWB,[.3 1 .3]);
figure(1)
imshow(overlay1)
hold on;
plot(contour(:,2),contour(:,1),'g','LineWidth',2);
axis equal
