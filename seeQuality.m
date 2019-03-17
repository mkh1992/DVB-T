clear;clc;
%% define parameters:
mode = 8192;
guard = 1/8;
modulation = '64QAM';
%% End Define
addpath('OFDM Demodulator')
addpath('TPS detector')
radio = comm.SDRuReceiver(...
      'Platform', 'B200', ...
      'SerialNum', '3103D11', ...
      'MasterClockRate', 10e6);
radio.CenterFrequency  = 746e6;
radio.Gain = 50;
radio.DecimationFactor = 1;
radio.SamplesPerFrame = (mode*(1+guard));
radio.OutputDataType = 'double';
radio.EnableBurstMode = 1;
radio.NumFramesInBurst= 300;
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
scope = dsp.SpectrumAnalyzer('SampleRate',radio.MasterClockRate);
firstTime = 1;
while (scope.isVisible || firstTime == 1)
    firstTime = 0;
    addpath('OFDM Demodulator')
    addpath('TPS detector')
    data = zeros(radio.SamplesPerFrame*radio.NumFramesInBurst,1);
    for i=1:radio.NumFramesInBurst
        data(((i-1)*radio.SamplesPerFrame+1):(i*radio.SamplesPerFrame))=radio();
    end
    signal = resample(data,64,70);
    inisig = signal(1:8192*10);
    C=correlator(inisig,guard,mode);
    [timeOffset,fFrequencyOffset,cFrequencyOffset]=Synchronizer(inisig,...
        C,mode,guard);
    TPSdata=zeros(136,1);
        for i =1:136
            [ofdmData] = ofdmDemodulator(i,signal,mode,guard,-1,timeOffset,fFrequencyOffset,...
                cFrequencyOffset);
            TPSdata(i) = TPSdetector(ofdmData,mode);
        end
    BPSKdemod = comm.DBPSKDemodulator;
    TPSbits  = BPSKdemod(TPSdata);
    pattern  = [0 0 1 1 0 1 0 1 1 1 1 0 1 1 1 0];
    TPSynch  =abs(conv(2*TPSbits-1, 2*pattern(end:-1:1)-1, 'valid'));
    [~,TPSindex] = max(TPSynch(2:68));
    [decoded,NumCorrected] = bchdec(gf([TPSbits(TPSindex:TPSindex+67);zeros(59,1)].'),127,113);
    decoded = decoded(1:54);
    clc;
    TPStable(decoded.x)
    GL = guard*mode;
    OSN = 0;
    endingFlag = 0;
    while(endingFlag == 0)
        lastSample = timeOffset-1+(TPSindex+OSN)*(mode+GL);
        if lastSample <=length(signal)
           ofdmData = ofdmDemodulator(TPSindex+OSN,signal,mode,guard,mod(OSN,68),...
                timeOffset,fFrequencyOffset,cFrequencyOffset);
            OSN = OSN+1;
            if OSN >=4
                constdiag(ofdmData)
            end
        else
            endingFlag =1;
            scope(data);
        end
    end
end
release(radio)
        