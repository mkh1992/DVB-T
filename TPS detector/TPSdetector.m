%TPS DETECT
function TPSdata = TPSdetector(ofdmData,mode)
persistent TPScells PRBSequence
if isempty(TPScells)
    TPScells = [34,50,209,346,413,569,595,688,...
        790,901,1073,1219,1262,1286,1469,1594,...
        1687,1738,1754,1913,2050,2117,2273,2299,...
        2392,2494,2605,2777,2923,2966,2990,3173,...
        3298,3391,3442,3458,3617,3754,3821,3977,...
        4003,4096,4198,4309,4481,4627,4670,4694,...
        4877,5002,5095,5146,5162,5321,5458,5525,...
        5681,5707,5800,5902,6013,6185,6331,6374,...
        6398,6581,6706,6799]';
    switch mode
        case 2048
             numOut = 1705;
        case 8192
             numOut = 6817;
    end
    ini = ones(1,11);
    PRBSequence = zeros(1,numOut);
    for i = 1 : numOut
        PRBSequence(i) = ini(11);
        temp = xor(ini(11),ini(9));
        ini  = circshift(ini,1);
        ini(1) = temp;
    end
    if mode == 2048
        TPScells = TPScells(1:17);
    end
end
initialPolarity = (2*PRBSequence(TPScells+1)-1).';
TPSdata = sum(initialPolarity.*ofdmData(TPScells+1))/length(TPScells);

