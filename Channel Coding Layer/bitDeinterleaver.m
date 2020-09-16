%bit deinterleaver
function [b,v]=bitDeinterleaver(yp,mode)
persistent bitPermu
 [~,v] = size(yp);
if isempty(bitPermu)
    w=(0:125);
    H0 = w;
    H1(w+1) = mod((w + 63),126);
    H2(w+1) = mod((w + 105),126);
    H3(w+1) = mod((w + 42),126);
    H4(w+1) = mod((w + 21), 126);
    H5(w+1) = mod((w + 84),126);
    bitPermu = [H0;H1;H2;H3;H4;H5]';
    constAdopt = bitPermu(:,1:v);
    if mode == 8192
        for i = 1 :47
        bitPermu((126*i+1):(126*(i+1)),1:v)=126*i+constAdopt;
        end
        for j = 1:v
           bitPermu(:,j) =126*48*(j-1)+bitPermu(:,j);
        end
    elseif mode ==2048
        for i = 1 :11
        bitPermu((126*i+1):(126*(i+1)),1:v)=126*i+constAdopt;
        end
        for j = 1:v
           bitPermu(:,j)= 126*12*(j-1)+bitPermu(:,j);
        end
    end
    bitPermu = bitPermu(:,1:v);
end
b(bitPermu+1)=yp;
b=reshape(b,numel(b)/v,v);