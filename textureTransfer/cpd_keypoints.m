function [ featureMap ] = cpd_keypoints( srctext,srcmask,trgtext,trgmask )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
trg=zeros(size(trgtext));
trg(trgmask)=trgtext(trgmask);
src=zeros(size(srctext));
src(srcmask)=srctext(srcmask);

trg_bw=im2bw(trg);
trgskel = bwmorph(trg_bw,'thin',Inf); %提取骨架线
src_bw=im2bw(src);
srcskel = bwmorph(src_bw,'thin',Inf); %提取骨架线

% Extract feature points. Here we use a simple edge detector.
% Most likely you'll have to use a more advanced feature detector here.
[j,i]=find(edge(trg,'canny'));
% [j,i]=find(trgskel);
X=[i j]; % first point set

[j,i]=find(edge(src,'canny'));
% [j,i]=find(srcskel);
Y=[i j]; % second point set


% Set the options
opt.method='nonrigid'; % use rigid registration
opt.viz=1;          % show every iteration

% registering Y to X
[Transform,C] = cpd_register(X,Y,opt);
dx=floor(size(C,1)/10);
selectp=1:dx:size(C,1);
C2 = C(selectp);
Y2 = Y(selectp,:);
bx=X(C2,1)';
by=X(C2,2)';
ax=Y2(:,1)';
ay=Y2(:,2)';
bx = bx+size(srctext,2);
%%
figure
imshow(cat(2, srctext, trgtext)) ;
hold on;  
h = line([ax ; bx], [ay ; by]) ;
set(h,'linewidth', 0.1, 'color', 'b') ;
hold off;  
bx=bx-size(srctext,2);
featureMap=[ax;ay;bx;by];

end

