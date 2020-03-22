function [trgimgPyr, imgPyrNNF] = ...
    synthesis(srcimgPyr, srcsemPyr, trgimgPyr, trgsemPyr, trgstructPyr, trgmaskPyr, optS)

% SYNTHESIS:
%
% Patch-based synthesis using patchmatch algorithm
%
% Input:
%   - srcimgPyr, srcsemPyr, trgimgPyr, trgsemPyr, trgstructPyr, trgmaskPyr
%   - optS
% Output:
%   - trgimgPyr
%   - imgPyrNNF
%

imgPyrNNF = cell(optS.numPyrLvl, 1);
% nearest neighbor field, for each p, store the matched q
NNF = [];
numIterLvl = optS.numIter;
pyrLvl = optS.numPyrLvl: -1 : optS.topLevel;

% Coarse-to-fine text effects transfer
for iLvl = pyrLvl
    % Initialize level   
%     srcedgeCur = srcedgePyr{iLvl};  
    srcimgCur = srcimgPyr{iLvl};
    trgsemCur = trgsemPyr{iLvl};
    trgmaskCur = trgmaskPyr{iLvl};
    srcsemCur = srcsemPyr{iLvl};
    % === Prepare img and NNF for the current level ===
    fprintf('--- Initialize NNF: ');
    [trgimgPyr, NNF, wDistPatchC, wDistPatch,wStructPatch,~] = ...
        init_lvl_nnf(trgimgPyr, srcimgCur, NNF, trgsemCur, trgmaskCur,srcsemCur, iLvl, optS);
    
    % used when there is great size difference for S and T
    optS.repCostRatio = (NNF.validPix.numValidPix / NNF.uvPix.numUvPix).^2;
      
    % Number of iterations at the currect level
    numIterLvl = max(numIterLvl - optS.numIterDec, optS.numIterMin);
    
    fprintf('--- Pass... level: %d, #Iter: %d, #uvPixels: %7d\n', iLvl, numIterLvl, NNF.uvPix.numUvPix);
    fprintf('--- %3s\t%12s\t%12s\t%12s\t%10s\n', 'iter', '#PropUpdate', '#RandUpdate', '#RegUpdate', 'AvgCost');
    if optS.useRotation==true
       tempLockRotate=0;
    else
        tempLockRotate=1;
    end
    % patchmatch (interation of random search and propagation)
    [trgimgPyr, NNF] = one_pass(trgimgPyr, trgsemPyr, trgstructPyr, srcimgPyr, srcsemPyr, NNF, wStructPatch,wDistPatchC,wDistPatch, numIterLvl, iLvl, optS, tempLockRotate);

    fprintf('Max cost & min cost: %f, %f\n', max(NNF.uvCost.data), min(NNF.uvCost.data));
    % Save the result
    imgPyrNNF{iLvl} = NNF;
end

end