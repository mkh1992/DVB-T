% Constellation to Bits
%persistent 
function demodOut=consDemod(ofdmData,mode,symbolNumber,modulation,showConstellation)
persistent continualPilot scatterPilot TPSdataIndex dataIndex consPoints constdiag
if isempty(TPSdataIndex)
TPSdataIndex = [34,50,209,346,413,569,595,688,790,901,...
    1073,1219,1262,1286,1469,1594,1687,1738,...
    1754,1913,2050,2117,2273,2299,2392,2494,...
    2605,2777,2923,2966,2990,3173,3298,3391,...
    3442,3458,3617,3754,3821,3977,4003,4096,...
    4198,4309,4481,4627,4670,4694,4877,5002,...
    5095,5146,5162,5321,5458,5525,5681,5707,...
    5800,5902,6013,6185,6331,6374,6398,6581,6706,6799]';
end
%% Continual Pilots
if isempty(continualPilot)
    continualPilot=[0,48,54,87,141,156,192,201,255,279,...
    282,333,432,450,483,525,531,618,636,...
    714,759,765,780,804,873,888,918,939,...
    942,969,984,1050,1101,1107,1110,1137,...
    1140,1146,1206,1269,1323,1377,1491,1683,...
    1704,1752,1758,1791,1845,1860,1896,1905,...
    1959,1983,1986,2037,2136,2154,2187,2229,...
    2235,2322,2340,2418,2463,2469,2484,2508,...
    2577,2592,2622,2643,2646,2673,2688,2754,...
    2805,2811,2814,2841,2844,2850,2910,2973,...
    3027,3081,3195,3387,3408,3456,3462,3495,...
    3549,3564,3600,3609,3663,3687,3690,3741,...
    3840,3858,3891,3933,3939,4026,4044,4122,...
    4167,4173,4188,4212,4281,4296,4326,4347,...
    4350,4377,4392,4458,4509,4515,4518,4545,...
    4548,4554,4614,4677,4731,4785,4899,5091,...
    5112,5160,5166,5199,5253,5268,5304,5313,...
    5367,5391,5394,5445,5544,5562,5595,5637,...
    5643,5730,5748,5826,5871,5877,5892,5916,...
    5985,6000,6030,6051,6054,6081,6096,6162,...
    6213,6219,6222,6249,6252,6258,6318,6381,...
    6435,6489,6603,6795,6816]';
end
    %% location of Scattered pilot Cells
if isempty(scatterPilot)
    switch mode
        case 2048
            pmax = ceil(1705/12)+1;
            for symNum = 0:3
                for p =0:pmax
                    scatterPilot{symNum+1,1}(p+1,1) = 3*symNum+12*p;
                end
                scatterPilot{symNum+1,1}=scatterPilot{symNum+1,1}(scatterPilot{symNum+1,1}<1705);
            end
        case 8192
            pmax = ceil(6817/12)+1;
            for symNum = 0:3
                for p =0:pmax
                    scatterPilot{symNum+1,1}(p+1,1) = 3*symNum+12*p;
                end
                scatterPilot{symNum+1,1}=scatterPilot{symNum+1,1}(scatterPilot{symNum+1,1}<6817);
            end
    end
end
if isempty(dataIndex)
    for i = 1:4
        notIndex{i,1} = [TPSdataIndex;continualPilot;scatterPilot{i,1}];
        notIndex{i,1} = sort(notIndex{i,1});
        notIndex{i,1} = unique(notIndex{i,1});
    end
    for j = 1:4
        dataIndex{j,1} = setdiff((1:max(scatterPilot{1,1})+1),notIndex{j,1}+1);
    end
end
if isempty(consPoints)
    if strcmp(modulation,'64QAM')
        consPoints = -7:2:7;
        [X,Y] = meshgrid(consPoints);
        consPoints = X+1i*Y;
        consPoints=consPoints(:)./sqrt(42);
    elseif strcmp(modulation,'16QAM')
        consPoints = -3:2:3;
        [X,Y] = meshgrid(consPoints);
        consPoints = X+1i*Y;
        consPoints=consPoints(:)./sqrt(10);
    elseif strcmp(modulation,'QPSK')
        consPoints = -1:2:1;
        [X,Y] = meshgrid(consPoints);
        consPoints = X+1i*Y;
        consPoints=consPoints(:)./sqrt(2);
    end
    constdiag = comm.ConstellationDiagram('ReferenceConstellation',consPoints);
end       
ofdmData = ofdmData(dataIndex{mod(symbolNumber,4)+1});
if strcmp(modulation,'64QAM')
    dvbtSymorder = [32,33,37,36,52,53,49,48,34,35,39,...
        38,54,55,51,50,42,43,47,46,62,63,59,58,40,41,...
        45,44,60,61,57,56,8,9,13,12,28,29,25,24,10,11,...
        15,14,30,31,27,26,2,3,7,6,22,23,19,18,0,1,5,4,...
        20,21,17,16];
    demodOut = qamdemod(ofdmData,64,dvbtSymorder,'UnitAveragePower', true);
end
if strcmp(modulation,'16QAM')
    dvbtSymorder = [8,9,13,12,10,11,15,14,2,3,7,6,0,1,5,4];
    demodOut = qamdemod(ofdmData,16,dvbtSymorder,'UnitAveragePower', true);
end
if strcmp(modulation,'QPSK')
    dvbtSymorder = [2,3,0,1];
    demodOut = qamdemod(ofdmData,4,dvbtSymorder,'UnitAveragePower', true);
end
if strcmp(showConstellation,'on')
    constdiag(ofdmData)
    pause(0.001)
end
