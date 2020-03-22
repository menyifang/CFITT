function     [trgimgPyr, NNF, wDistPatchC, wDistPatch,wStructPatch, wDistImg] = init_lvl_nnf(trgimgPyr, srcimgCur, NNF, trgsemCur,trgmaskCur ,srcsemCur, iLvl, optS)

% INIT_LVL_NNF
%
% Initialize the nearest neighbor field for the current level
%
% Input: 
%   - trgimgPyr, srcimgCur, NNF, trgsemCur,trgmaskCur ,srcsemCur, iLvl, optS
% Output:
%   - trgimgPyr
%   - NNF 
%   - wDistPatch
%   - wDistImg

if optS.useDistPatch == false
    distMap = ones(size(trgsemCur));
else
    cannyBW=edge(trgsemCur,'canny');
    [distMap, ~] = bwdist(cannyBW, 'euclidean');
end

if(iLvl == optS.numPyrLvl)
    % Initialize the NNF for the coarest level using color-based random sampling 
    NNF = init_nnf(trgsemCur,trgmaskCur, srcsemCur, optS);    
    % patch weighting
    [wDistPatch,wDistPatchC, wDistImg] = prep_dist_patch(distMap, NNF.uvPix.sub, iLvl, optS);
    % structure-patch weighting
    wStructPatch  = prep_struct_patch(trgmaskCur, NNF.uvPix.sub, iLvl, optS);
    % update the image using NNF
    trgimgPyr{iLvl} = voting(trgimgPyr{iLvl}, srcimgCur, NNF, NNF.uvPix, wDistPatch, wDistImg, optS);figure;imshow(trgimgPyr{iLvl});
    
else
    % Initialize the NNF upsampling of NNF from previous level
    NNF = upsample(NNF, trgsemCur, srcsemCur, optS);
    [wDistPatch,wDistPatchC, wDistImg] = prep_dist_patch(distMap, NNF.uvPix.sub, iLvl, optS);
   % structure-patch weighting
    wStructPatch  = prep_struct_patch(trgmaskCur, NNF.uvPix.sub, iLvl, optS);
    trgimgPyr{iLvl} = voting(trgimgPyr{iLvl}, srcimgCur, NNF, NNF.uvPix, wDistPatch, wDistImg, optS);
end

% get multi-scale images (used for the Appearance Term)
for i = optS.numPyrLvl:-1:iLvl+1
    trgimgPyr{i} = imresize(trgimgPyr{iLvl}, [size(trgimgPyr{i},1), size(trgimgPyr{i},2)], optS.resampleKernel);
end

NNF.uvDtBdPixPos = double(distMap(NNF.uvPix.ind));

end