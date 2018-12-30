function [radiusR,centroid,radial_average_R,p]=funBeadRadiusR3(Ic,centroid,imgSize,pxlSize,idSlice,baseline,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process particles channel
levelR = graythresh(Ic);
RBW = im2bw(Ic,levelR);
RBWC =1 - imclose(RBW,strel('disk',20));
BWforeground = RBWC;
RBWC = imclearborder(RBWC);
%if centroid(1)<1
%props = regionprops(RBWC,'Centroid','area');%get centroid
%end
% if isempty(props)
%         radiusR = 0;
%     centroid = [NaN,NaN];
%     p = NaN;
%     radial_average_R = NaN;
%     errorFlag = true;
%     return
% else
% centroid = props.Centroid;
% end
BG = 1 - imdilate(BWforeground,strel('disk',40));
BGlevel = Ic(BG==1);
BGlevel = trimmean(BGlevel(:),10);
%radiusRBW = sqrt(bwarea(RBWC)/pi);
if debug
    %overlay1 = imoverlay(imadjust(Ic),bwperim(BG),[.3 1 .3]);
    h_fig=figure(1000+idSlice*2)
    hold on
    Irgb=zeros(imgSize,imgSize,3); %initialize the image
    Irgb(:,:,2)=imadjust(Ic.*BG);
    Irgb(:,:,1)=imadjust(Ic.*(1-BG));
    imshow(Irgb)
    
    %viscircles(centroid,3);
    axis equal
    saveas(h_fig,'PEA_background.tiff');
    hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%estimate exclusion radius
%rEstimate = sqrt(bwarea(RBWC)/pi)+60;
rEstimate = min([abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = 10:rEstimate;
radial_average_R = zeros(length(R_r),1);
%resample radially
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
   sampleR = interp2(X,Y,Ic,x,y);
   radial_average_R(i) = trimmean(sampleR,10);
end
%normalize
%radial_average_R = radial_average_R/BGlevel;
%radial_average_R = ;
radial_average_R = (radial_average_R-mean(radial_average_R(1:10)))/(BGlevel-mean(radial_average_R(1:10)));
%find midpoint
idmax = find(radial_average_R==max(radial_average_R),1,'first');
array = abs(radial_average_R(1:idmax)-baseline);
id = find(array==min(array));
if id<4||(id+4)>length(array)
    radiusR = NaN;
    centroid = NaN;
    radial_average_R = NaN;
    p = NaN;
    errorFlag = true;
    figure(6+idSlice*2)
    plot(R_r,radial_average_R,'r-');
    return
end
x = R_r(id-4:id+4)';
y = radial_average_R(id-4:id+4)-baseline;
p = polyfit(x,y,1);
radiusR = -p(2)/p(1);
radiusR = radiusR*pxlSize;
errorFlag = false;

if debug
    h_fig = figure(6+idSlice*2);
    hold on
    plot(R_r*pxlSize,radial_average_R,'r-','LineWidth',2);
    plot(R_r(1:10)*pxlSize,radial_average_R(1:10),'k-','LineWidth',2);
    plot(radiusR,0.5,'ko','MarkerSize',10,'LineWidth',2);
    plot([4.042,4.042],[-1.2,1.2],'g--','LineWidth',2);
    ylabel('Intensity (A.U.)');
    xlabel('Distance to Center (\mum)');
    hold off
    set(gca,'FontSize',18);
    ylim([-.03,1.1]);
    box on;
                ax = gca;
ax.LineWidth = 1;
    saveas(h_fig,'PEAProfile.tiff');
end