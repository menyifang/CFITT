% Demonstration of Thin-Plate-Spline Warping
%
% Inputs:
% imgInFilename - input image filename
% mapFilename - colormap data file for display
% lmFilename - landmark data file for display
%
% Output:
% Display of warped image
%
% Example:
% tpsWarpDemo('..\data\0505_02.jpg','map.mat','tpsDemoLandmark.mat')
%
% Author: Fitzgerald J Archibald
% Date: 07-Apr-09

function tpsWarpDemo(imgInFilename, mapFilename, lmFilename, imgInsrctextFilename, imgIntrgtextFilename)
%% Get inputs
%imgInFilename = '..\data\0505_02.jpg'; %'..\data\HermannGrid.1.gif'; %

interp.method = 'invdist'; %'nearest'; %'none' % interpolation method
interp.radius = 5; % radius or median filter dimension
interp.power = 2; %power for inverse wwighting interpolation method

srcimg = imread(imgInFilename);
srctext = imread(imgInsrctextFilename);
trgtext = imread(imgIntrgtextFilename);
load(mapFilename); % load map

%% Get the landmark points
if 0 % Get points interactively
    NPs = input('Enter number of landmark points : ');
    fprintf('Select %d correspondence / landmark points with mouse on Fig.2.\n',NPs);
    
    figure(2);
    Hp=subplot(1,2,1); % for landmark point selection
    image(srctext);
    colormap(map);
    hold on;
    
    Hs=subplot(1,2,2); % for correspondence point selection
    imagesc(trgtext);
    colormap(map);
    hold on;
    
    Xp=[]; Yp=[]; Xs=[]; Ys=[];
%     axis(Hp);
%     [Yp,Xp]=ginput; % get the landmark point
%     scatter(Yp,Xp,32,'y','o','filled');
% %     text(Yp,Xp,num2str(1:5),'FontSize',6);
%     savefile='p';
%     save(savefile,'Yp','Xp');
%     
%     axis(Hs);
%     [Ys,Xs]=ginput; % get the corresponding point
%     scatter(Ys,Xs,32,'y','*'); % display the point
%     savefile='q';
%     save(savefile,'Ys','Xs');
    
        for ix = 1:NPs
            axis(Hp);
            [Yp(ix),Xp(ix)]=ginput(1); % get the landmark point
            scatter(Yp(ix),Xp(ix),32,'y','o','filled'); % display the point
            text(Yp(ix),Xp(ix),num2str(ix),'FontSize',6);
            savefile='p';
            save(savefile,'Yp','Xp');
    
            axis(Hs);
            [Ys(ix),Xs(ix)]=ginput(1); % get the corresponding point
            scatter(Ys(ix),Xs(ix),32,'y','*'); % display the point
            text(Ys(ix),Xs(ix),num2str(ix),'FontSize',6);
            savefile='q';
            save(savefile,'Ys','Xs');
        end
    
else % load stored landmark positions
    %     load(lmFilename);
    loadfilep='p';
    load(loadfilep);
    loadfileq='q';
    load(loadfileq);
end

%% Warping
[imgW, imgWr]  = tpswarp(srcimg,[size(trgtext,2) size(trgtext,1)],[Xp' Yp'],[Xs' Ys'],interp); % thin plate spline warping
imgW = uint8(imgW);
imgWr = uint8(imgWr);

%% Display
figure(1)

subplot(1,3,1); imshow(srcimg,[]);
for ix = 1 : length(Xp),
    impoint(gca,Yp(ix),Xp(ix));
end
colormap(map);
subplot(1,3,2); imshow(imgWr,[]);
for ix = 1 : length(Xs),
    impoint(gca,Ys(ix),Xs(ix));
end
colormap(map);
subplot(1,3,3); imshow(imgW,[]);
for ix = 1 : length(Xs),
    impoint(gca,Ys(ix),Xs(ix));
end
colormap(map);

return;
