function tofile=ranDe(toDerand)
persistent randStorage andres
if isempty(andres)
ini = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0];
rndPRBS = zeros(1,1503*8);
for i = 1 : 1503*8
    rndPRBS(i) = xor(ini(15),ini(14));
    ini  = circshift(ini,1);
    ini(1) = rndPRBS(i);
end
rndPRBS=[zeros(1,8),rndPRBS];
En=[zeros(1,8),ones(1,187*8)];
Enable = repmat(En,1,8);
andres = and(Enable,rndPRBS);
end
randStorage =[randStorage;toDerand];
Len=floor(size(randStorage)/8);
tofile = [];
for i=1:Len(1)
    bits2derand=de2bi(randStorage(1:8,:)','left-msb');
    bits2derand=reshape(bits2derand',1,188*8*8);
    temptofile=xor(bits2derand,andres);
    temptofile = reshape(temptofile,8,1504);
    tofile=[tofile;bi2de(temptofile','left-msb')];
    randStorage=randStorage(9:end,:);
end
remComp =find(tofile(1:188:end)==184);
tofile(188*(remComp-1)+1)=71;

    
     
    