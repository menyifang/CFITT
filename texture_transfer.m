function [targetStylizedFinal,optS] = texture_transfer(sty, src, trg, imgpath, optS)
% texture_transfer
%     semantic texture transfer such that S:S'::T:T'
%
% Input:
% 	- sty: name of the source style
% 	- src: name of the source
% 	- trg: name of the target
% 	- imgpath: image path
% 	- optS: parameters
% Output:
%	- targetStylizedFinal: target stylized image
%
% Example:
%   targetStylizedFinal = texture_transfer('paint', 'Gogh', 'Seth', 'imgs/', optS);
%
%

% Option parameters
optS = init_opt(optS,src);
optS.name = [src, '-', sty,'-', trg];
srcimgFileName = [ src, '-', sty, '.png'];
srcsemFileName = [ src, '-sem.png'];
trgsemFileName = [ trg, '-sem.png'];

% Read images
fprintf('- Read images \n');
trgsem = im2double(rgb2gray(imread([imgpath,trgsemFileName])));
trgimg = zeros(size(trgsem,1), size(trgsem, 2), 3);

srcimg = im2double(imread([imgpath,srcimgFileName]));
sw=round(size(trgimg,1) *size(srcimg,2)/size(srcimg,1));% optinal
srcimg = imresize(srcimg, [size(trgimg,1),sw]);
srcsem = imread([imgpath,srcsemFileName]);
srcsem  = imresize(srcsem, [size(trgimg,1),sw]);
srcsem = im2double(rgb2gray(srcsem));

optS.Htrg = size(trgsem,1);
optS.Wtrg = size(trgsem,2);
optS.Hsrc = size(srcsem,1);
optS.Wsrc = size(srcsem,2);

%% Construct image pyramid for coarse-to-fine image completion
fprintf('- Construct image pyramid \n');
[trgimgPyr, scaleImgPyr] = create_img_pyramid(trgimg, optS);
[trgsemPyr, ~] = create_img_pyramid(trgsem, optS);
srcsemPyr = create_img_pyramid_by_scale(srcsem, optS, scaleImgPyr);
srcimgPyr = create_img_pyramid_by_scale(srcimg, optS, scaleImgPyr);

%% === Structure extraction ===
srcSaliency = saliencyExtraction( imgpath,src,sty );
srcSaliency = imresize(srcSaliency,[optS.Hsrc,optS.Wsrc]);
srcStructMask = zeros(optS.Hsrc,optS.Wsrc);
srcStructMask(srcSaliency > 0.2) = 1;
% figure;imshow(srcStructMask);

% recomanded the label with salient structure
% can also be user-specified color
[srcmask,color_top] = salient_label(srcsem,srcStructMask);
srcmask = logical(srcmask);

trgmask = zeros(size(trgsem));
trgmask((trgsem==color_top)) = 1;
trgmask = logical(trgmask);
[trgmaskPyr, ~] = create_img_pyramid(trgmask, optS);

%% === Structure propagation ===
trgstruct=zeros(size(trgimg));
if optS.useStruct
    [trgmorph,ifv_ind,ifv_sub,trgStructMask] = structProp(srcsem, trgsem, srcimg,srcmask,trgmask,srcStructMask,optS);
    trgmask=trgmask & trgStructMask;
    for i=1:size(trgimg,3)
        temp_m=trgmorph(:,:,i);
        temp_s=zeros(size(temp_m));
        temp_s(trgmask)=temp_m(trgmask);
        trgstruct(:,:,i)=temp_s;
    end
    ifv_sub = padarray(ifv_sub,[optS.pRad,optS.pRad]);
    NNF_struct = getInitUvTform(ifv_sub,scaleImgPyr{1}.imgSize,scaleImgPyr{optS.numPyrLvl}.imgSize, optS.pRad);
    optS.NNF_struct = NNF_struct;
end
figure;imshow(trgstruct)
[trgstructPyr, ~] = create_img_pyramid(trgstruct, optS);

%% === Texture stylization ===
% synthesis
fprintf('- Texture transfer \n');
[trgimgPyr, ~] = synthesis(srcimgPyr, srcsemPyr, trgimgPyr, trgsemPyr, trgstructPyr, trgmaskPyr, optS);
% return the top level
targetStylizedFinal = trgimgPyr{optS.topLevel};

end
