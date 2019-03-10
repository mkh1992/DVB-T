%symbol Deinterleaver
function yp=symbolDeinterleaver(demodOut,mode,symNum)
persistent Hq Nmax
y = de2bi(demodOut,'left-msb');
if isempty(Hq)
    Nr = log2(mode);
    Rip=zeros(mode,Nr-1);
    Rip(3,1)=1;
    for i = 4:mode
        Rip(i,1:end-1) = Rip(i-1,2:end);
        if mode == 2048
            Rip(i,10) = xor(Rip(i-1,1),Rip(i-1,4));
        elseif mode == 8192
            xor1=xor(Rip(i-1,1),Rip(i-1,2));
            xor2=xor(Rip(i-1,5),Rip(i-1,7));
            Rip(i,12) = xor(xor1,xor2);
        end
    end
    if mode ==2048
        Nmax = 1512;
        Ri = Rip(:,[9,6,4,1,0,7,3,8,5,2]+1);
    elseif mode == 8192
        Nmax = 6048;
        Ri = Rip(:,[8,1,3,9,2,11,5,0,6,4,7,10]+1);
    end
    q = 1;
    for i=1:mode
        Hq(q) = mod(i-1,2).*2^(Nr-1) + sum(Ri(i,:).*2.^(0:(log2(mode)-2)),2);
        if Hq(q)<Nmax
            q=q+1;
        end
    end
end
if mod(symNum,2)==0
    yp(1:Nmax,:) = y((Hq(1:Nmax)+1),:);
elseif mod(symNum,2)==1
    yp((Hq(1:Nmax)+1),:) = y(1:Nmax,:);
end
    