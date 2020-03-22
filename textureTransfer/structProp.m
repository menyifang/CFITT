function [imgWr,ifv_ind,ifv_sub,trgStructMask] = structProp(srcsem, trgsem, srcimg,srcmask,trgmask,srcStructMask,optS)
% STRUCT_PROPAGATION
%    propagate salient structure for source to target

% Input:
%   - srcsem, srcimg,srcmask, srcStructMask
%   - trgsem, trgmask
%   - optS

% Output:
%   - imgWr,ifv_ind,ifv_sub,trgStructMask

%% Get inputs
interp.method = 'invdist'; %'nearest'; %'none' % interpolation method
interp.radius = 5; % radius or median filter dimension
interp.power = 2; %power for inverse wwighting interpolation method
load('map.mat'); % load map

%% Get the landmark points
path = 'cache/kp-matching/';
kpSavefileName = [path,optS.name,'.mat'];
if(exist(fullfile(kpSavefileName), 'file'))
    load(kpSavefileName);
else
    if optS.automatch
        keypoints_match = cpd_keypoints(srcsem,srcmask,trgsem,trgmask);
        ax = keypoints_match(1,:);
        ay = keypoints_match(2,:);
        bx = keypoints_match(3,:);
        by = keypoints_match(4,:);
    else
        NPs = input('Enter number of key points : ');
        fprintf('Select %d correspondence points (point a in source and b in target) with mouse on Fig.2.\n',NPs);
        
        figure(2);
        Hp=subplot(1,2,1); % for landmark point selection
        imagesc(srcsem);
        colormap(map);
        hold on;
        
        Hq=subplot(1,2,2); % for correspondence point selection
        imagesc(trgsem);
        colormap(map);
        hold on;
        
        ay=[]; ax=[]; by=[]; bx=[];
        for ix = 1:NPs
            axis(Hp);
            [ax(ix),ay(ix)]=ginput(1); % get the landmark point
            scatter(ax(ix),ay(ix),32,'y','o','filled'); % display the point
            text(ax(ix),ay(ix),num2str(ix),'FontSize',6);
            
            axis(Hq);
            [bx(ix),by(ix)]=ginput(1); % get the corresponding point
            scatter(bx(ix),by(ix),32,'y','*'); % display the point
            text(bx(ix),by(ix),num2str(ix),'FontSize',6);
        end
        
    end
    savefile=[path,optS.name];
    save(savefile,'ax','ay','bx','by');
end

%% Dense Correspondences Mathcing
% if nargin==7
    [imgWr,ifv_ind,ifv_sub,trgStructMask]  = tpswarp(srcimg,[size(trgsem,2) size(trgsem,1)],[ay' ax'],[by' bx'],interp, optS.pRad,srcStructMask); % thin plate spline warping
% else
%     [imgWr,ifv_ind,ifv_sub]  = tpswarp(srcimg,[size(trgsem,2) size(trgsem,1)],[ay' ax'],[by' bx'],interp, optS.pRad);
% end

end