% Convolutional Deinterleaver
function toRSdec=outerDeinterleaver(toOuterInterleaver)
persistent storage deinterleaver Deflag
if isempty(storage) && isempty(Deflag)
    curser = packetSynchronizer(toOuterInterleaver);
    storage = toOuterInterleaver(curser:end);
    Deflag = 1;
elseif ~isempty(Deflag)
    storage=[storage;toOuterInterleaver];
end
L=floor(length(storage)/(204*8));
toRSdec=[];
if L == 0
    return
end
todec = storage(1:L*204*8);
storage = storage((L*204*8+1):end);
todec=reshape(todec,8,length(todec)/8);
dec = bi2de(todec','left-msb');
if isempty(deinterleaver)
deinterleaver = comm.ConvolutionalDeinterleaver('NumRegisters',12,'RegisterLengthStep',17);
end
for i=1:L
    ind = ((i-1)*204+1):i*204;
    toRSdec = [toRSdec;deinterleaver(dec(ind))];
end
