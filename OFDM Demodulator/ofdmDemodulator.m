% ofdmDemodulator
function [ofdmData,H] = ofdmDemodulator(windowIndex,signal,...
    mode,guard,symbolnum,timeOffset,fFrequencyOffset,cFrequencyOffset)
GL = guard*mode;
interval =((timeOffset+GL):(timeOffset+mode+GL-1)) + (windowIndex-1)*(mode+GL);
    ff = exp(-2*pi*1i*(interval)'*(cFrequencyOffset+fFrequencyOffset)/mode);
    correctedSignal = signal(interval).*ff;
    ofdmSymbols=fft(correctedSignal);
    H = channelEstimate(ofdmSymbols,mode,symbolnum);
    ofdmData = ofdmSymbols(1:length(H))./H.';
% 
% windowIndex=1,signal=ofdm_samples;,...
%     mode=2048,guard=1/4,symbolnum=0,timeOffset,fFrequencyOffset,...
%     cFrequencyOffset)

