function [trgimg] = voting(trgimg, srcimg,NNF, uvPix, wDistPatch, wDistImg, optS,usePoint)

% VOTING: update the image using NNF
%
% Input: 
%   - wDistPatch
%   - srcimgCur
%   - NNF
%   - uvPix
%   - wDistPatch
%   - wDistImg, optS
% Output:
%   - img

[imgH, imgW, nCh] = size(trgimg);

% Prepare source patch
numUvPix = size(uvPix.ind, 2);
uvValid.ind = true(1, numUvPix);    uvValid.pos = 1:numUvPix;
srcPatch = prep_source_patch(srcimg, NNF.uvTform.data, optS);

% Apply bias correction
if(optS.useBiasCorrection)
    temp = NNF.uvBias.data;
    temp(:,NNF.uvPix.dist<=1.2) = 0;
    biasPatch = reshape(temp, 1, nCh, numUvPix);
    srcPatch = bsxfun(@plus, srcPatch, biasPatch);
end

% Patch weight
wDistPatchC = reshape(wDistPatch(optS.pMidPix, :), 1, 1, numUvPix);

srcPatch = bsxfun(@times, srcPatch, wDistPatchC);    

% Compute weighted average from source patches
srcPatch = reshape(srcPatch, optS.pNumPix*nCh, numUvPix);
imgAcc = zeros(imgH, imgW, 3, 'single');
for i = 1:numUvPix
    imgAcc(NNF.trgPatchInd(:,i)) = imgAcc(NNF.trgPatchInd(:,i)) + srcPatch(:,i);
end

trgimg = imgAcc./wDistImg(:,:,ones(1,1,nCh));

end

