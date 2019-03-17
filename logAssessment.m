%logAssessment
clear;clc;
clear channelEstimate
clear consDemod
clear outerDeinterleaver
clear ranDe
clear RSdecoder
clear symbolDeinterleaver
clear innerDecoder
clear bitDeinterleaver
addpath('OFDM Demodulator')
addpath('TPS detector')
addpath('constelation Demodulator')
addpath('Channel Coding Layer')
%% read Row data
sec = 4; % amount of signal to be proccesed (in Sec)
sampRate = 10e6;
fidr = fopen('650_shiraz','r');
%fidr = fopen('d:\testBB1.bin','r');
a = fread(fidr,4e6,'float'); % 2*sampRate*sec
a = a(1:2:end)+1i*a(2:2:end);
%% change sample time to "elemntary period" for 8MHz channels = 7/64 us
ofdm_samples=[zeros(1,1);a];clear a;
%% Determine OFDM Mode (2k or 8k) and guard interval (1/4 1/8 1/16 1/32)
fprintf('MODE Detection started\n')
inisig = ofdm_samples(1:(10*8192));
% load signal
% inisig = signal;
guard =[1/4,1/8,1/16,1/32];
Ni =[2048,8192];
C  = cell(9,3);
C(1,1:3) = {'name','testOut','varToAve'};
Co=2;
for i = Ni
    for j = guard
        C{Co,1} = [num2str(i),'_',num2str(j)];
        [C{Co,2},C{Co,3}] = correlator(inisig,j,i);
        Co = Co+1;
    end
end
modDetect = sum([C{2,3},C{3,3},C{4,3},C{5,3}]>[C{6,3},C{7,3},C{8,3},C{9,3}]);
if modDetect > 2
    fprintf('Mode detected successfully as 2K \n')
    modDetect=0;
elseif modDetect < 2
    fprintf('Mode detected successfully as 8K \n')
    modDetect=1;
else
    disp('Mode detection Faild\n')
end
clear mod_test i j Co
fprintf('-------------------\n')
%% Pre FFT Time offset and frequency offset Estimation
for guardAssumed = guard
    fprintf('###Synchronization Parameters for Guard Assumed as %0.3f ###  \n',guardAssumed)
    ni = Ni(modDetect+1);
    %GL = guardAssumed*ni;
    cInd = find(guard == guardAssumed)+4*modDetect+1;
    [timeOffset,fFrequencyOffset,cFrequencyOffset]=Synchronizer(inisig,...
        C{cInd,2},ni,guardAssumed);
    fprintf('Coarse Time Offset Estimated = %d \n',timeOffset)
    fprintf('Fine Frequency Offset Estimated = %0.3f \n',fFrequencyOffset)
    fprintf('Coarse Frequency Offset Estimated = %d \n ------------------\n',cFrequencyOffset)
    %% provide data from i'th OFDMSymbol for dciesion Devise (i = windowIndex)
    TPSdata=zeros(136,1);
    for i =1:136
        [ofdmData] = ofdmDemodulator(i,ofdm_samples,ni,guardAssumed,-1,timeOffset,fFrequencyOffset,...
            cFrequencyOffset);
        TPSdata(i) = TPSdetector(ofdmData,ni);
    end
    %% TPS for confirmation or reconfiguration
    BPSKdemod = comm.DBPSKDemodulator;
    TPSbits  = BPSKdemod(TPSdata);
    pattern  = [0 0 1 1 0 1 0 1 1 1 1 0 1 1 1 0];
    TPSynch  =abs(conv(2*TPSbits-1, 2*pattern(end:-1:1)-1, 'valid'));
    [~,TPSindex] = max(TPSynch(2:68));
    [decoded,NumCorrected] = bchdec(gf([TPSbits(TPSindex:TPSindex+67);zeros(59,1)].'),127,113);
    decoded = decoded(1:54);
    informationTable=TPStable(decoded.x);
    if str2num(informationTable{7,2}) == guardAssumed &&...
            (strcmp(informationTable{8,2},'8K') && ni == 8192) && ~strcmp(informationTable{1,2},'NOLL')
        fprintf('Guard %s is Approved by TPS data\n',num2str(guardAssumed))
        Inform = cell2table(informationTable,'VariableNames',{'signalParameters' 'status'});
        break
    elseif str2num(informationTable{7,2}) == guardAssumed &&...
       (strcmp(informationTable{8,2},'2K') && ni == 2048) && ~strcmp(informationTable{1,2},'NOLL')
        fprintf('Guard %s is Approved by TPS data\n',num2str(guardAssumed))
        Inform = cell2table(informationTable,'VariableNames',{'signalParameters' 'status'});
        break
    else
        fprintf('Guard %s didn''t Approve by TPS data\n------------------\n',num2str(guardAssumed))
    end
end
%% data Extracting ...
TPSdata = zeros(68,1);
s = dir('650_shiraz');         
filesize = s.bytes/(32*2)*8;
fidw = fopen('test.ts','w');
conutFirstPlace = 4e6;
count = conutFirstPlace;
GL = guardAssumed*ni;
OSN = 0;
endingFlag = 0;
while(endingFlag == 0)
    lastSample = timeOffset-1+(TPSindex+OSN)*(ni+GL);
    if lastSample <=length(ofdm_samples)
        [ofdmData,H] = ofdmDemodulator(TPSindex+OSN,ofdm_samples,ni,guardAssumed,mod(OSN,68),...
            timeOffset,fFrequencyOffset,cFrequencyOffset);
        TPSdata(mod(OSN,68)+1,1) = TPSdetector(ofdmData,ni);
        demodOut=consDemod(ofdmData,ni,mod(OSN,68),Inform{4,2},'off');
        if mod(OSN,68) == 0 && OSN ~= 0
            BPSKdemod = comm.DBPSKDemodulator;
            TPSbits  = BPSKdemod(TPSdata(1:68));
            [decoded,NumCorrected] = bchdec(gf([TPSbits;zeros(59,1)].'),127,113);
            decoded = decoded(1:54);
            infoTab=TPStable(decoded.x);
            fprintf('%s \n',infoTab{3,2});
        end
        if  OSN > 4
        yp=symbolDeinterleaver(demodOut,ni,mod(OSN,68));
        [b,v]=bitDeinterleaver(yp,ni);
        x=muxer(b,v);
        toOuterInterleaver=innerDecoder(x,informationTable{6,2});
        toRSdec=outerDeinterleaver(toOuterInterleaver);
        [toDerand,syncErrorFlag]=RSdecoder(toRSdec);
            if syncErrorFlag ==0
                tofile=ranDe(toDerand);
                fwrite(fidw,tofile,'uint8');
                OSN = OSN+1;
            elseif syncErrorFlag==1
                fprintf('syncError\n')
                if count == conutFirstPlace
                    [a,count] = fread(fidr,count,'float');
                    a = a(1:2:end)+1i*a(2:2:end);
                    if lastSample>68*ni
                        ofdm_samples=[ofdm_samples((lastSample-68*ni):end);a];
                    elseif lastSample<68*ni
                        ofdm_samples=[ofdm_samples((lastSample):end);a];
                    end
                elseif count ~= conutFirstPlace
                      endingFlag = 1;
                end
                clear channelEstimate
                clear consDemod
                clear outerDeinterleaver
                clear ranDe
                clear RSdecoder
                clear symbolDeinterleaver
                clear innerDecoder
                clear bitDeinterleaver
                inisig = ofdm_samples(1:(6*8192));
                corrinfo=correlator(inisig,guardAssumed,ni);
                [timeOffset,fFrequencyOffset,cFrequencyOffset]=Synchronizer(inisig,...
                corrinfo,ni,guardAssumed);
                TPSdata=zeros(136,1);
                for i =1:136
                    [ofdmData] = ofdmDemodulator(i,ofdm_samples,ni,guardAssumed,-1,timeOffset,fFrequencyOffset,...
                        cFrequencyOffset);
                    TPSdata(i) = TPSdetector(ofdmData,ni);
                end
                BPSKdemod = comm.DBPSKDemodulator;
                TPSbits  = BPSKdemod(TPSdata);
                pattern  = [0 0 1 1 0 1 0 1 1 1 1 0 1 1 1 0];
                TPSynch  =abs(conv(2*TPSbits-1, 2*pattern(end:-1:1)-1, 'valid'));
                [~,TPSindex] = max(TPSynch(2:68));
                [decoded,NumCorrected] = bchdec(gf([TPSbits(TPSindex:TPSindex+67);zeros(59,1)].'),127,113);
                decoded = decoded(1:54);
                infoTab=TPStable(decoded.x);
                OSN = 0;            
            end
        elseif OSN <= 4
            OSN=OSN+1;
        end
    elseif lastSample>length(ofdm_samples)
        if count == conutFirstPlace
        [a,count] = fread(fidr,count,'float');
        a = a(1:2:end)+1i*a(2:2:end);
        ofdm_samples=[ofdm_samples;a];
        elseif count ~= conutFirstPlace
            endingFlag = 1;
        end
    end
end
fclose(fidr);
fclose(fidw);