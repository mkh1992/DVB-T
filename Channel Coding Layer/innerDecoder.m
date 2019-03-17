%innerDecoder
function toOuterInterleaver=innerDecoder(x,cr)
persistent vitdec
if isempty(vitdec)
    switch cr
        case '1/2'
            PT = [1,1]';
        case '2/3'
            PT = [1,1,0,1]';
        case '3/4'
            PT = [1,1,0,1,1,0]';
        case '5/6'
            PT = [1,1,0,1,1,0,0,1,1,0]';
        case '7/8'
            PT = [1,1,0,1,0,1,0,1,1,0,0,1,1,0]';
    end
     vitdec = comm.gpu.ViterbiDecoder(poly2trellis(7, [171 133]), ...
       'InputFormat', 'Hard','PuncturePatternSource','Property',...
       'PuncturePattern',PT);
%    vitdec = comm.ViterbiDecoder(poly2trellis(7, [171 133]), ...
%      'InputFormat', 'Hard','PuncturePatternSource','Property',...
%      'PuncturePattern',PT);
end
x=gpuArray(x);
toOuterInterleaver = vitdec(x);
toOuterInterleaver = gather(toOuterInterleaver);
