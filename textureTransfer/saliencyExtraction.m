function [ delta_saliency ] = saliencyExtraction( imgpath,src,sty )
% SALIENCY_EXTRACTION
%      dectect salient inner strcuture of source stylized image
%
% Input:
% 	- sty: name of the source style
% 	- src: name of the source 
% 	- imgpath: image path
% Output:
%	- delta_saliency: defined saliency
%

% read the cache if have been stored
saliencySavefileName = ['cache/saliency/',src,'-',sty,'-saliency.png'];
if(exist(fullfile(saliencySavefileName), 'file'))
    img_saliency = im2double(imread(saliencySavefileName));
else
    file_names{1} = [imgpath,  src,'-',sty,'.png'];
    MOV = saliency(file_names);
    img_saliency = MOV{1}.SaliencyMap;
    imwrite(img_saliency, saliencySavefileName);
end

% saliency detection for srctext
saliencySavefileName = ['cache/saliency/',src,'-sem-saliency.png'];
if(exist(fullfile(saliencySavefileName), 'file'))
    text_saliency = im2double(imread(saliencySavefileName));
else
    file_names{1} =[imgpath, src,'-sem.png'];
    MOV = saliency(file_names);
    text_saliency = MOV{1}.SaliencyMap;
    imwrite(text_saliency, saliencySavefileName);
end
 % saliency map
delta_saliency = img_saliency - 4*text_saliency;


end

