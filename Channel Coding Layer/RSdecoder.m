%Reed Solomon Decoder
function [toDerand,syncErrorFlag]=RSdecoder(toRSdec)
persistent RStorage RSflag RSdec
syncErrorFlag = 0;
cdec = 0;
toDerand=[];
RStorage=[RStorage;toRSdec];
if isempty(RSflag) && length(RStorage) > 2244
    RStorage=RStorage(2245:end);
    RSdec = comm.RSDecoder ('CodewordLength',255,'MessageLength',239,...
        'ShortMessageLength',188, 'GeneratorPolynomialSource','Property',...
        'GeneratorPolynomial',rsgenpoly(255,239,285,0));
    RSflag = 1;
end
if ~isempty(RSflag) && length(RStorage)>204 
    L=floor(length(RStorage)/204);
    for i = 1:L
           coded = RStorage((204*(i-1)+1):(204*i)); 
           [toDerand(i,:),cdec(i)]=RSdec(coded);
    end
    RStorage=RStorage((204*L+1):end);
    toDerand=toDerand(:,1:188);%toDerand(:,52:end);
end
if sum(cdec==-1)>=4
    syncErrorFlag = 1;
end
