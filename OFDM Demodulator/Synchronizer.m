%Synchronizer
function [timeOffset,fFrequencyOffset,cFrequencyOffset]=Synchronizer(signal,correlatorOut,mode,guard)
%signal=inisig,correlatorOut=C{3,2},mode=2048,guard=1/8
%% PRB Secuence
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
%% Continual pilot locations
CPC=[0,48,54,87,141,156,192,201,255,279,...
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
    6435,6489,6603,6795,6816];
%% coarse Time
LS=mode+guard*mode;  % Length of a OFDM simbol
NS=floor(length(correlatorOut)/LS); % Number of OFDM symbols
TO = zeros(LS,1);
for i=1:NS
    TO = TO + (correlatorOut(((i-1)*LS+1):i*LS));
end
[~,CtimeOffset] = max(abs(TO));
%% Fine frequency
fO = zeros(NS,1);
for i=1:NS
    ind = ((i-1)*LS+CtimeOffset):((i-1)*LS+CtimeOffset+guard*mode-1);
    fO(i) =signal(ind)'*signal(ind+mode);
end
fFrequencyOffset = 1/(2*pi) *angle(sum(fO));
%% Coarse Frequency
inter = CtimeOffset:(CtimeOffset+LS-1);
correctedSignal = signal(inter).*...
    exp(-2*pi*1i*(inter)'*fFrequencyOffset/mode); % correct
% signal with coarce time offset and fine frequency offset
correctedSignal = correctedSignal((guard*mode+1):end); % remove Guard
receivedSymbols = fft(correctedSignal);
PRBSequence=4/3*2*(1/2-PRBSequence);
if mode == 2048
    pilotSymbols = zeros(2048,1);
    CPC = CPC(1:45);
    pilotSymbols(CPC+1)=PRBSequence(CPC+1);
    CFO = zeros(2048,1);
    for i = 1:2048
        CFO(i)=circshift(receivedSymbols,i)'*pilotSymbols;
    end
elseif mode == 8192
    pilotSymbols = zeros(8192,1);
    pilotSymbols(CPC+1)=PRBSequence(CPC+1);
    CFO = zeros(8192,1);
    for i = 1:8192
        CFO(i)=circshift(receivedSymbols,i)'*pilotSymbols;
    end
end
[~,cFrequencyOffset] = max(abs(CFO));
cFrequencyOffset=-(cFrequencyOffset);
%% Fine time
correctedSignal = signal(inter).*...
    exp(-2*pi*1i*(inter)'*(fFrequencyOffset+cFrequencyOffset)/mode);
correctedSignal = correctedSignal((guard*mode+1):end);
receivedSymbols = fft(correctedSignal);
Ttr=ifft(conj(pilotSymbols).*receivedSymbols);
Ttr=Ttr.*[ones(20,1);zeros(length(Ttr)-40,1);ones(20,1)];
[~,fTimeOffset] = max(abs(Ttr));
if fTimeOffset>500
    fTimeOffset=fTimeOffset-mode;
end
timeOffset = fTimeOffset+ CtimeOffset - 1;
% %% PhaseOffset Frequency Second time
% ind = timeOffset:(timeOffset+LS-1);
% correctedSignal = signal(ind).*exp(-2*pi*1i*(ind)'*(fFrequencyOffset+cFrequencyOffset)/mode); % correct
% % signal with coarce time offset and fine frequency offset
% correctedSignal = correctedSignal((guard*mode+1):end); % remove Guard
% receivedSymbols = fft(correctedSignal);
% constantPhase = phase(sum(pilotSymbols./receivedSymbols));
