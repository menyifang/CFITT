sty = 'paint';
src = 'Gogh';
trg = 'Seth';

imgpath = 'imgs/';
outputpath= 'results/';           

% === Weighting parameters ===
optS.lambdaText  = 10;              
optS.lambdaRep   = 0.005;         

% === Iterative parameters ===
optS.useReflect=0;
optS.useRotation=1;
optS.useStruct=1;
if optS.useStruct
    optS.lambdaStruct = 0.5; 
else
    optS.lambdaStruct = 0; 
end

optS.useDistPatch=false;
optS.initByColorOn = false;

[targetStylizedFinal,optS] = texture_transfer(sty, src, trg, imgpath, optS);   
% record parameters used
imwrite(targetStylizedFinal, sprintf('%s\\%s_%d%d%d_%d_%d.png',outputpath,optS.name, optS.useReflect,optS.useRotation,optS.useStruct,optS.lambdaText,optS.lambdaStruct));
% imwrite(textEffectFinal, [imgpath, trg, '-', sty, '-', src, '.png']);
