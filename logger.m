clear;clc;
radio = comm.SDRuReceiver(...
      'Platform', 'B200', ...
      'SerialNum', '3103D11', ...
      'MasterClockRate', 20e6);
radio.CenterFrequency  = 746e6;
radio.Gain = 40;
radio.DecimationFactor = 2;
radio.SamplesPerFrame = 1e4;
radio.OutputDataType = 'double';
radio.EnableBurstMode = 1;
radio.NumFramesInBurst= 5000;
data = zeros(radio.SamplesPerFrame*radio.NumFramesInBurst,1);
for i=1:radio.NumFramesInBurst
    data(((i-1)*radio.SamplesPerFrame+1):(i*radio.SamplesPerFrame))=radio();
end
data = resample(data,64,70);
toFile = [real(data),imag(data)];
toFile=reshape(toFile.',length(toFile)*2,1);
fid = fopen('650_shiraz','w');
fwrite(fid,toFile,'float');
fclose(fid);
release(radio)